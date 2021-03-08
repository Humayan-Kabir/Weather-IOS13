//
//  ViewController.swift
//  Clima
//
//  Created by Angela Yu on 01/09/2019.
//  Copyright © 2019 App Brewery. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchInput: UITextField!
    
    
    let locationManager = CLLocationManager()
    let weatherManager = WeatherManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchInput.delegate = self
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
        
        weatherManager.delegate = self
    }

    @IBAction func searchWeatherPressed(_ sender: UIButton) {
        print("cityname: \(searchInput.text!)")
        if let cityName = searchInput.text {
            weatherManager.fetchWeather(cityName: cityName)
        }
    }
    
    @IBAction func currentLocationWeatherPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
}

//MARK: - UITextFieldDelegate

extension WeatherViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let searchText = searchInput.text {
            if searchText != "" {
                let cityName = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                weatherManager.fetchWeather(cityName: cityName)
            }
            searchInput.resignFirstResponder()
        } else {
            searchInput.placeholder = "enter city"
        }
        return true
    }
    
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            let lat: String = newLocation.coordinate.latitude.description
            let long: String = newLocation.coordinate.longitude.description
            print("got new location data\(newLocation.coordinate) \(lat) \(long)")
            weatherManager.fetchWather(latitude: lat, longitude: long)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error occurred")
    }
}

//MARK: - WeatherModelDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weatherModel: WeatherModel) {
        print("weatehr updated")
        print(weatherModel.conditionName)
        print(weatherModel)
        DispatchQueue.main.async {
            self.temperatureLabel.text = weatherModel.temperatureString
            self.cityLabel.text = weatherModel.cityName
            self.conditionImageView.image = UIImage(systemName: weatherModel.conditionName)
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
        print("errrr")
    }
}

