//
//  WeatherManager.swift
//  Clima
//
//  Created by SRBD on 5/3/21.
//  Copyright © 2021 App Brewery. All rights reserved.
//

import Foundation

enum ErrorHandler: Error {
    case clientError(String)
    case responseErrorWithCode(Int)
    case jsonParsingError(String)
    case handle(Error)
}

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weatherModel: WeatherModel)
    func didFailWithError(error: Error)
}


class WeatherManager {
    let openWeatherUrl = "https://api.openweathermap.org/data/2.5/weather?appid=924fd7801f5a3ba17f2b9a6807608595&units=metric"
    
    var delegate: WeatherManagerDelegate? = nil
    
    func fetchWeather(cityName: String) -> Void {
        let urlString = "\(openWeatherUrl)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWather(latitude: String, longitude: String) {
        let urlString = "\(openWeatherUrl)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    self.delegate?.didFailWithError(error: ErrorHandler.handle(error))  //handle client error
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      (200...299).contains(httpResponse.statusCode) else {
                    let urlResponse = response as! HTTPURLResponse
                    self.delegate?.didFailWithError(error: ErrorHandler.responseErrorWithCode(urlResponse.statusCode))
                    return
                }
                
                if let mimeType = httpResponse.mimeType, mimeType == "application/json",
                   let data = data, let string = String(data: data, encoding: .utf8) {
                    
                    if let weatherModel = self.parseJson(data) {
                        self.delegate?.didUpdateWeather(self, weatherModel: weatherModel)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(_ data: Data) -> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let weatehrData = try decoder.decode(WeatherData.self, from: data)
            let cityname = weatehrData.name
            let conditionId = weatehrData.weather[0].id
            let temperature = weatehrData.main.temp
            
            let weatherModel = WeatherModel(cityName: cityname, temperature: temperature, coditionId: conditionId)
            
            return weatherModel
            
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
    
}
