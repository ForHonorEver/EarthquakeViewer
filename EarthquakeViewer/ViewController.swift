//
//  EarthquakeMainVC.swift
//  EarthquakeViewer
//
//  Created by Zebin Yang on 7/12/20.
//  Copyright © 2020 ZebinYang. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {
    private lazy var viewModel: ViewModel = ViewModel()
    private let locationManager = CLLocationManager()

    private var isFetchingCurrentLocation = false
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.backgroundColor = UIColor.white
        return scrollView
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 20
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }()
    
    private lazy var loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .gray)
        loader.translatesAutoresizingMaskIntoConstraints = false
        loader.hidesWhenStopped = true
        return loader
    }()
    
    private lazy var inputLocationView: UIView = {
        let view = UIView()
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 5
        stackView.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.backgroundColor = UIColor.yellow
        
        stackView.addArrangedSubview(latTextField)
        stackView.addArrangedSubview(lonTextField)
        stackView.addArrangedSubview(useAboveLocationButton)
        stackView.addArrangedSubview(useCurrentLocationButton)
        
        view.addSubview(stackView)
        view.backgroundColor = UIColor.gray
        stackView.pinSuperViewEdges()
        return view
    }()
    
    private lazy var latTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Latitude, between -180.0 and 180.0 "
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 2.0
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private lazy var lonTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = " Longitude, between -180.0 and 180.0 "
        textField.layer.borderColor = UIColor.blue.cgColor
        textField.layer.borderWidth = 2.0
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    private lazy var useAboveLocationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use Location Above", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(useAboveLocationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var useCurrentLocationButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Use Current Location", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(useCurrentLocationButtonTapped), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.setupInitialLocationIfNeeded()
        setupUI()
        refreshData()
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        view.addSubview(loader)
        scrollView.pinSuperViewEdges()
        loader.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        loader.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        scrollView.addSubview(stackView)
        stackView.pinSuperViewEdges()
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
    }
    
    private func refreshData() {
        removeOldViewsAndUpdateInfo()
        loader.startAnimating()
        viewModel.getEarthquakeData { [weak self] earthquakes in
            DispatchQueue.main.async { [weak self] in
                self?.loader.stopAnimating()
            }
            guard let earthquakes = earthquakes else {
                self?.showError()
                return
            }
            self?.addEarthquakesToView(earthquakes)
        }
    }
    
    private func removeOldViewsAndUpdateInfo() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
        stackView.addArrangedSubview(inputLocationView)
        latTextField.text = viewModel.lat
        lonTextField.text = viewModel.lon
    }
    
    private func showNoEarthquakesView() {
        let alertController = UIAlertController(title: "Congrats", message: "No earthquakes near your location within 30 days", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func showError() {
        let alertController = UIAlertController(title: "Error", message: "Some errors occured", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        DispatchQueue.main.async { [weak self] in
            self?.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func addEarthquakesToView(_ earthquakes: [EarthquakeModel]) {
        guard earthquakes.count != 0 else {
            showNoEarthquakesView()
            return
        }
        
        for earthquake in earthquakes {
            let timeString = viewModel.convertTimeLabel(earthquake.time)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                let earthquakeView = EarthquakeView()
                earthquakeView.configureView(earthquake, timeString) { [weak self] detailsUrl in
                    self?.open(detailsUrl)
                }
                let width = strongSelf.view.frame.size.width - 120.0
                earthquakeView.widthAnchor.constraint(equalToConstant: width).isActive = true
                earthquakeView.translatesAutoresizingMaskIntoConstraints = false
                earthquakeView.backgroundColor = UIColor.gray
                strongSelf.stackView.addArrangedSubview(earthquakeView)
            }
        }

    }
    
    private func open(_ urlString: String) {
        if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("URL can not be open")
        }
    }
    
    @objc func useAboveLocationButtonTapped() {
        if let lat = latTextField.text, let lon = lonTextField.text {
            viewModel.setCenterLocation(lat, lon)
            refreshData()
        }
    }
    
    @objc func useCurrentLocationButtonTapped() {
        isFetchingCurrentLocation = true
        locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        let newLat = locValue.latitude
        let newLon = locValue.longitude
        let oldLat = (viewModel.lat as NSString).doubleValue
        let oldLon = (viewModel.lon as NSString).doubleValue
        if isFetchingCurrentLocation, abs(newLat - oldLat) > 0.0001 || abs(newLon - oldLon) > 0.0001 {
            print("location: \(locValue.latitude) \(locValue.longitude)")
            viewModel.lat = "\(newLat)"
            viewModel.lon = "\(newLon)"
            isFetchingCurrentLocation = false
            refreshData()
        }
        
    }
}


