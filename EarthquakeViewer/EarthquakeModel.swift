//
//  EarthquakeModel.swift
//  EarthquakeViewer
//
//  Created by Zebin Yang on 7/12/20.
//  Copyright © 2020 ZebinYang. All rights reserved.
//

struct EarthquakeModel {
    let magnitude: Double
    let place: String
    let url: String
    let title: String
    let time: Int
}

extension EarthquakeModel {
    init?(json: [String: Any]) {
        guard let magnitude = json["mag"] as? Double,
            let place = json["place"] as? String,
            let url = json["url"] as? String,
            let title = json["title"]as? String,
            let time = json["time"] as? Int
        else {
            return nil
        }

        self.magnitude = magnitude
        self.place = place
        self.url = url
        self.title = title
        self.time = time
    }
}

