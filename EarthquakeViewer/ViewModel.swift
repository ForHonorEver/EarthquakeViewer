//
//  ViewModel.swift
//  EarthquakeViewer
//
//  Created by Zebin Yang on 7/12/20.
//  Copyright © 2020 ZebinYang. All rights reserved.
//

import Foundation
import CoreLocation

class ViewModel {
    private(set) var earthquakeManager: EarthquakeManager

    var lat: String {
        set(value) {
            earthquakeManager.lat = value
        }
        get {
            return earthquakeManager.lat
        }
    }
    var lon: String {
        set(value) {
            earthquakeManager.lon = value
        }
        get {
            return earthquakeManager.lon
        }
    }
    
    init(earthquakeManager: EarthquakeManager = EarthquakeManager.shared) {
        self.earthquakeManager = earthquakeManager
    }
    
    func setupInitialLocationIfNeeded() {
        let userDefaults = UserDefaults.standard
        if userDefaults.string(forKey: "latitude") == nil {
            userDefaults.set("33.6853333", forKey: "latitude")
        }
        if userDefaults.string(forKey: "longitude") == nil {
            userDefaults.set("-116.7875", forKey: "longitude")
        }
    }
    
    func getEarthquakeData(completion: @escaping ([EarthquakeModel]?) -> Void) {
        earthquakeManager.getEarthquakeData { earthquakes in
            // only the earthquakes with mag>1.9 will be shown
            let filtered = earthquakes?.filter({ $0.magnitude > 1.9 })
            completion(filtered)
        }
    }
    
    func convertTimeLabel(_ timeInterval: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mma MM/dd/yyyy" // 4:30PM 07/12/2020
        
        // back end API uses milliseconds, hence divide 1000 here
        let date = Date(timeIntervalSince1970: TimeInterval(timeInterval/1000))
        return formatter.string(from: date)
    }
    
    func setCenterLocation(_ lat: String, _ lon: String) {
        earthquakeManager.setCenterLocation(lat, lon)
    }
}
