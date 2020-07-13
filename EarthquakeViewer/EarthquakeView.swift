//
//  EarthquakeView.swift
//  EarthquakeViewer
//
//  Created by Zebin Yang on 7/12/20.
//  Copyright © 2020 ZebinYang. All rights reserved.
//

import Foundation
import UIKit

final class EarthquakeView: UIView {
    private lazy var stackView: UIStackView = {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.alignment = .top
        container.spacing = 7.0
        container.addArrangedSubview(titleLabel)
        container.addArrangedSubview(timeLabel)
        container.addArrangedSubview(detailsButton)
        return container
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var detailsButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isEnabled = true
        button.setTitle("Details", for: .normal)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.addTarget(self, action: #selector(detailsButtonTapped), for: .touchUpInside)
        
        return button
    }()
    
    private var detailsButtonAction: ((String) -> Void)?
    private var earthquake: EarthquakeModel?
    
    func configureView(_ item: EarthquakeModel,
                       _ timeString: String,
                       _ detailsAction: @escaping ((String) -> Void)) {
        earthquake = item

        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = .flexibleHeight
        addSubview(stackView)
        stackView.pinSuperViewEdges()

        titleLabel.text = item.title
        timeLabel.text = "Occurance Time: \(timeString)"
        detailsButtonAction = detailsAction
    }
    
    @objc func detailsButtonTapped() {
        detailsButtonAction?(earthquake?.url ?? "")
    }
}
