//
//  EarthquakeManager.swift
//  EarthquakeViewer
//
//  Created by Zebin Yang on 7/12/20.
//  Copyright © 2020 ZebinYang. All rights reserved.
//

import Foundation

class EarthquakeManager: NSObject {
    static let shared = EarthquakeManager()
    
    var lat: String {
        set(value) {
            UserDefaults.standard.set(value, forKey: "latitude")
        }
        get {
            return UserDefaults.standard.string(forKey: "latitude") ?? "33.6853333"
        }
    }
    
    var lon: String {
        set(value) {
            UserDefaults.standard.set(value, forKey: "longitude")
        }
        get {
            return UserDefaults.standard.string(forKey: "longitude") ?? "-116.7875"
        }
    }
    
    private var urlSession: URLSession {
        let sessionConfiguration = URLSessionConfiguration.default
        return URLSession(configuration: sessionConfiguration)
    }

    func getEarthquakeData(completion: @escaping ([EarthquakeModel]?) -> Void) {
        makeRequst { [weak self] jsonDict in
            guard let strongSelf = self else { return }
            guard let jsonDict = jsonDict else {
                completion(nil)
                return
            }
            let earthquakes = strongSelf.convertToModel(jsonDict)
            completion(earthquakes)
        }
    }

    func makeRequst(completion: @escaping ([String: Any]?) -> Void) {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "earthquake.usgs.gov"
        urlComponents.path = "/fdsnws/event/1/query"
        urlComponents.queryItems = [
           URLQueryItem(name: "format", value: "geojson"),
           URLQueryItem(name: "latitude", value: lat),
           URLQueryItem(name: "longitude", value: lon),
           URLQueryItem(name: "maxradiuskm", value: "50") // default to 50km search radius
        ]

        let url = urlComponents.url!
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60.0
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        let dataTask = urlSession.dataTask(with: request as URLRequest) { (data, response, error) in
            guard let _ = response, let data = data, error == nil else {
                completion(nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data)
                if let jsonDict = json as? [String: Any] {
                    completion(jsonDict)
                } else {
                    completion(nil)
                    print("JSONSerialization error")
                }
            } catch {
                completion(nil)
                print("JSONSerialization error")
            }
            
        }
        dataTask.resume()
        
    }
    
    private func convertToModel(_ jsonDict: [String: Any]) -> [EarthquakeModel] {
        var earthquakes: [EarthquakeModel] = []
        if let features = jsonDict["features"] as? [Any] {
            for feature in features {
                if let feature = feature as? [String: Any],
                    let properties = feature["properties"] as? [String: Any],
                    let earthquake = EarthquakeModel(json: properties) {
                    earthquakes.append(earthquake)
                }
            }
        }
        return earthquakes
    }
    
    func setCenterLocation(_ lat: String, _ lon: String) {
        self.lat = lat
        self.lon = lon
    }

    
}


