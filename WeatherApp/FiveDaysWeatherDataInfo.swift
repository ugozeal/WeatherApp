//
//  FiveDaysWeatherDataInfo.swift
//  WeatherApp
//
//  Created by David U. Okonkwo on 9/15/20.
//  Copyright © 2020 Decagon HQ. All rights reserved.
//

import Foundation

struct WeatherData: Codable {
    let list: [List]
}
 
struct Main: Codable {
    let temp: Float
}
 
struct WeatherIcons: Codable {
    let icon: String
}
 
struct List: Codable {
    var main: Main
    var weather: [WeatherIcons]
    var dateText : String
    
    private enum CodingKeys : String, CodingKey {
        case main, dateText = "dt_txt", weather
    }
}
