//
//  ForcastedWeatherDataLoader.swift
//  WeatherApp
//
//  Created by David U. Okonkwo on 9/15/20.
//  Copyright © 2020 Decagon HQ. All rights reserved.
//

import Foundation
class ForcastedWeatherDataLoader {
    
    func getWeather(closure: @escaping (WeatherData) -> ()){
        let apiKey = "7a22797d0651a1c44a55227285888de5"
        let city = "owerri"
        let weatherUrl = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: weatherUrl) else {return}
        let session = URLSession.shared
        session.dataTask(with: url) { (data, response, error) in
            if response != nil {
            }
            if let data = data {
                do{
                    let jsonDecoder = JSONDecoder()
                    let dataFromJson =  try jsonDecoder.decode(WeatherData.self, from: data)
                    closure(dataFromJson)
                }
                catch {
                    print(error)
                }
            }
        }.resume()
    }
    
}
