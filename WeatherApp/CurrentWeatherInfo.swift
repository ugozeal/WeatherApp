//
//  WeatherInfo.swift
//  WeatherApp
//
//  Created by David U. Okonkwo on 9/13/20.
//  Copyright © 2020 Decagon HQ. All rights reserved.
//

import Foundation

struct  WeatherMain: Codable {
    var main: Weather
    var weather: [WeatherType]
}

struct WeatherType: Codable {
    var main: String
}
struct Weather : Codable {
    var temp : Double
    var maxTemp: Double
    var minTemp: Double
    
    private enum CodingKeys : String, CodingKey {
        case temp, minTemp = "temp_min", maxTemp = "temp_max"
    }
}

