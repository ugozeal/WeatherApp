//
//  ViewController.swift
//  WeatherApp
//
//  Created by David U. Okonkwo on 9/13/20.
//  Copyright © 2020 Decagon HQ. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var currentWeatherDetails: WeatherMain?
    var forcastWeatherDetails: WeatherData?
    @IBOutlet var currentTemperatureLabel: UILabel!
    @IBOutlet var weatherDescriptionLabel: UILabel!
    @IBOutlet var currentTemperatureLabel2: UILabel!
    @IBOutlet var minTemperatureLabel: UILabel!
    @IBOutlet var maxTemperatureLabel: UILabel!
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var dayOneLabel: UILabel!
    @IBOutlet var dayOneIconView: UIImageView!
    @IBOutlet var dayOneTemperatureLabel: UILabel!
    
    @IBOutlet var dayTwoLabel: UILabel!
    @IBOutlet var dayTwoTemperatureLabel: UILabel!
    @IBOutlet var dayTwoIconView: UIImageView!
    
    @IBOutlet var dayThreeLabel: UILabel!
    @IBOutlet var dayThreeIconView: UIImageView!
    @IBOutlet var dayThreeTemperatureLabel: UILabel!
    
    @IBOutlet var dayFourLabel: UILabel!
    @IBOutlet var dayFourIconView: UIImageView!
    @IBOutlet var dayFourTemperatureLabel: UILabel!
    
    @IBOutlet var dayFiveLabel: UILabel!
    @IBOutlet var dayFiveIconView: UIImageView!
    @IBOutlet var dayFiveTemperatureLabel: UILabel!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        getFiveDaysDataWithoutNetwork()
        getCurrentWeatherDataAtNetworkOff()
        CurrentWeatherDataLoader().getWeather { (weather) in
            self.currentWeatherDetails = weather
            self.loadCurrentWeather()
        }
        ForcastedWeatherDataLoader().getWeather { (weather) in
            self.forcastWeatherDetails = weather
            self.loadFiveDaysWeather()
        }
    }
    
    func loadCurrentWeather(){
        let queue = DispatchQueue(label: "")

        queue.async {
            DispatchQueue.main.async {
                if let details = self.currentWeatherDetails?.main {
                    let tempToInt = String(format: "%.0f", (details.temp))
                    let minTempToInt = String(format: "%.0f", (details.minTemp))
                    let maxTempToInt = String(format: "%.0f", (details.maxTemp))
                    self.currentTemperatureLabel.text = "\(tempToInt)°"
                    self.currentTemperatureLabel2.text = "\(tempToInt)°"
                    self.maxTemperatureLabel.text = "\(maxTempToInt)°"
                    self.minTemperatureLabel.text = "\(minTempToInt)°"
                }
                self.weatherInfoDescription()
                if let encoded = try? JSONEncoder().encode(self.currentWeatherDetails) {
                    UserDefaults.standard.set(encoded, forKey: "currentData")
                }
               
            }
        }
    }
    
    func loadFiveDaysWeather(){
        let queue = DispatchQueue(label: "")

        queue.async {
            DispatchQueue.main.async {
                self.filterFiveDaysForecast()
                if let fiveDaysData = try? JSONEncoder().encode(self.forcastWeatherDetails) {
                    UserDefaults.standard.set(fiveDaysData, forKey: "fiveDaysData")
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
    }
    
    func getCurrentWeatherDataAtNetworkOff() {
        if let current = UserDefaults.standard.object(forKey: "currentData") as? Data{
            if let currentData = try? JSONDecoder().decode(WeatherMain.self, from: current) {
                let tempToInt = String(format: "%.0f", (currentData.main.temp))
                let minTempToInt = String(format: "%.0f", (currentData.main.minTemp))
                let maxTempToInt = String(format: "%.0f", (currentData.main.maxTemp))
                self.currentTemperatureLabel.text = "\(tempToInt)°"
                self.currentTemperatureLabel2.text = "\(tempToInt)°"
                self.maxTemperatureLabel.text = "\(maxTempToInt)°"
                self.minTemperatureLabel.text = "\(minTempToInt)°"
                self.weatherDescriptionLabel.text = currentData.weather[0].main.uppercased()
                switch currentData.weather[0].main{
                    case "Clouds","Mist", "Haze" :
                        self.backgroundImageView.image = UIImage(named: ("sea_cloudy"))
                        let cloudyColour = #colorLiteral(red: 0.379460007, green: 0.5208922625, blue: 0.583759129, alpha: 1)
                        self.view.backgroundColor = cloudyColour
                    case "Rain","Thunderstorm" :
                        self.backgroundImageView.image = UIImage(named: ("sea_rainy"))
                        let rainyColour = UIColor(red: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0)
                        self.view.backgroundColor = rainyColour
                    default:
                        self.backgroundImageView.image = UIImage(named: ("sea_sunny"))
                }
            }
        }
    }
    
    func weatherInfoDescription() {
        if let weatherDescription = self.currentWeatherDetails?.weather{
            self.weatherDescriptionLabel.text = weatherDescription[0].main.uppercased()
            switch weatherDescription[0].main {
            case "Clouds","Mist", "Haze" :
                self.backgroundImageView.image = UIImage(named: ("sea_cloudy"))
                let cloudyColour = #colorLiteral(red: 0.379460007, green: 0.5208922625, blue: 0.583759129, alpha: 1)
                self.view.backgroundColor = cloudyColour
            case "Rain","Thunderstorm" :
                self.backgroundImageView.image = UIImage(named: ("sea_rainy"))
                let rainyColour = UIColor(red: 104/255.0, green: 104/255.0, blue: 104/255.0, alpha: 1.0)
                self.view.backgroundColor = rainyColour
            default:
                self.backgroundImageView.image = UIImage(named: ("sea_sunny"))
            }
        }
    }
    
    func filterFiveDaysForecast() {
        var temperatureArray: Array<Float> = Array()
        var dateArray: Array<String> = Array()
        var dateArray2: Array<String> = Array()
        var dayNumber = 0
        var readingNumber = 0
        if let forecastedData = self.forcastWeatherDetails{
            for data in forecastedData.list{
                let temp = data.main.temp
                let date = data.dateText
                if readingNumber == 0 {
                    temperatureArray.append(temp)
                    dateArray.append(date)
                } else if temp > temperatureArray[dayNumber] || date > dateArray[dayNumber]{
                    temperatureArray[dayNumber] = temp
                    dateArray[dayNumber] = date
                }
                readingNumber += 1
                if readingNumber == 8 {
                    readingNumber = 0
                    dayNumber += 1
                }
            }
            for dateString in dateArray {
                let dateFormatterGet = DateFormatter()
                dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateFormatterPrint = DateFormatter()
                dateFormatterPrint.dateFormat = "EEEE"
                
                if let date1 = dateFormatterGet.date(from: dateString) {
                    let dateToDay = dateFormatterPrint.string(from: date1)
                    dateArray2.append("\(dateToDay)")
                } else {
                    print("There was an error decoding the string")
                }
            }
            self.dayOneLabel.text = "\(dateArray2[0])"
            self.dayTwoLabel.text = "\(dateArray2[1])"
            self.dayThreeLabel.text = "\(dateArray2[2])"
            self.dayFourLabel.text = "\(dateArray2[3])"
            self.dayFiveLabel.text = "\(dateArray2[4])"
            self.dayFiveLabel.text = "\(dateArray2[4])"
            self.dayOneTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[0]))°"
            self.dayTwoTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[1]))°"
            self.dayThreeTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[2]))°"
            self.dayFourTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[3]))°"
            self.dayFiveTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[4]))°"
            if temperatureArray[0] >= 25{
                self.dayOneIconView.image = UIImage(named: "clear")
            }else {
                self.dayOneIconView.image = UIImage(named: "rain")
            }
            if temperatureArray[1] >= 25{
                self.dayTwoIconView.image = UIImage(named: "clear")
            }else {
                self.dayTwoIconView.image = UIImage(named: "rain")
            }
            if temperatureArray[2] >= 25{
                self.dayThreeIconView.image = UIImage(named: "clear")
            }else {
                self.dayThreeIconView.image = UIImage(named: "rain")
            }
            if temperatureArray[3] >= 25{
                self.dayFourIconView.image = UIImage(named: "clear")
            }else {
                self.dayFourIconView.image = UIImage(named: "rain")
            }
            if temperatureArray[4] >= 25{
                self.dayFiveIconView.image = UIImage(named: "clear")
            }else {
                self.dayFiveIconView.image = UIImage(named: "rain")
            }
            
            
        }
    }
    
    func getFiveDaysDataWithoutNetwork() {
        if let fiveDaysData = UserDefaults.standard.object(forKey: "fiveDaysData") as? Data{
            if let fiveDaysData = try? JSONDecoder().decode(WeatherData.self, from: fiveDaysData) {
                var temperatureArray: Array<Float> = Array()
                var readingNumber = 0
                var dayNumber = 0
                var dateArray: Array<String> = Array()
                var dateArray2: Array<String> = Array()
                for data in fiveDaysData.list{
                    let temp = data.main.temp
                    let date = data.dateText
                    if readingNumber == 0 {
                        temperatureArray.append(temp)
                        dateArray.append(date)
                    } else if temp > temperatureArray[dayNumber] || date > dateArray[dayNumber]{
                        temperatureArray[dayNumber] = temp
                        dateArray[dayNumber] = date
                    }
                    readingNumber += 1
                    if readingNumber == 8 {
                        readingNumber = 0
                        dayNumber += 1
                    }
                }
                for dateString in dateArray {
                    let dateFormatterGet = DateFormatter()
                    dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let dateFormatterPrint = DateFormatter()
                    dateFormatterPrint.dateFormat = "EEEE"
                    
                    if let date1 = dateFormatterGet.date(from: dateString) {
                        let dateToDay = dateFormatterPrint.string(from: date1)
                        dateArray2.append("\(dateToDay)")
                    } else {
                        print("There was an error decoding the string")
                    }
                }
                self.dayOneLabel.text = "\(dateArray2[0])"
                self.dayTwoLabel.text = "\(dateArray2[1])"
                self.dayThreeLabel.text = "\(dateArray2[2])"
                self.dayFourLabel.text = "\(dateArray2[3])"
                self.dayFiveLabel.text = "\(dateArray2[4])"
                self.dayFiveLabel.text = "\(dateArray2[4])"
                self.dayOneTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[0]))°"
                self.dayTwoTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[1]))°"
                self.dayThreeTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[2]))°"
                self.dayFourTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[3]))°"
                self.dayFiveTemperatureLabel.text = "\(String(format: "%.0f", temperatureArray[4]))°"
                if temperatureArray[0] >= 25{
                    self.dayOneIconView.image = UIImage(named: "clear")
                }else {
                    self.dayOneIconView.image = UIImage(named: "rain")
                }
                if temperatureArray[1] >= 25{
                    self.dayTwoIconView.image = UIImage(named: "clear")
                }else {
                    self.dayTwoIconView.image = UIImage(named: "rain")
                }
                if temperatureArray[2] >= 25{
                    self.dayThreeIconView.image = UIImage(named: "clear")
                }else {
                    self.dayThreeIconView.image = UIImage(named: "rain")
                }
                if temperatureArray[3] >= 25{
                    self.dayFourIconView.image = UIImage(named: "clear")
                }else {
                    self.dayFourIconView.image = UIImage(named: "rain")
                }
                if temperatureArray[4] >= 25{
                    self.dayFiveIconView.image = UIImage(named: "clear")
                }else {
                    self.dayFiveIconView.image = UIImage(named: "rain")
                }
                
                
            }
            
        }
    }

}

