//
//  ViewController.swift
//  WeatherApp
//
//  Template by Angela Yu on 24/08/2015.
//  Created by Mario Muhammad on 15/05/2018.
//  Image Copyright (c) 2015 London App Brewery. All rights reserved.
//  Copyright (c) 2018 Mario Muhammad. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "93da73ea2bc2a7f2efe68abbbbd640cd"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let weatherDatamodel = WeatherDataModel()
    var isInCelcius = true
    var temperatur : Double = 0
    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var degreeLabel: UILabel!
    
    @IBAction func degreeSwitch(_ sender: UISwitch) {
      
        if sender.isOn == true {
            isInCelcius = false
            degreeLabel.text = "℉"
            weatherDatamodel.temperatur = Int(temperatur)
        }
        else {
            isInCelcius = true
            degreeLabel.text = "℃"
            weatherDatamodel.temperatur = Int(temperatur - 273.15)
        }
        
        updateUIWithWeatherData()

        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //TODO:Set up the location manager here.
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    func getWeatherData(url: String, parameters: [String : String]) {
        Alamofire.request(url, method: .get, parameters : parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! Got the weather data")
                
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            }
            else {
                print("Error \(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }

    
    
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    func updateWeatherData(json : JSON) {
        if let tempResult = json["main"]["temp"].double {
            
            temperatur = tempResult
            
            if isInCelcius == true {
                weatherDatamodel.temperatur = Int(tempResult - 273.15)
            }
            else {
                weatherDatamodel.temperatur = Int(tempResult)
            }
            
            weatherDatamodel.city = json["name"].stringValue
            
            weatherDatamodel.condition = json["weather"][0]["id"].intValue
            
            weatherDatamodel.weatherIconName = weatherDatamodel.updateWeatherIcon(condition: weatherDatamodel.condition)
        
            updateUIWithWeatherData()
        }
        else {
            cityLabel.text = "Weather Unavailable"
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    func updateUIWithWeatherData() {
        
        cityLabel.text = weatherDatamodel.city
        temperatureLabel.text = "\(weatherDatamodel.temperatur)°"
        weatherIcon.image = UIImage(named: weatherDatamodel.weatherIconName)
    }
    
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            
            print("longitude = \(location.coordinate.longitude), latitude: \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params : [String : String] = ["lat" : latitude, "lon" : longitude, "appid" : APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    //Write the didFailWithError method here:
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    func unserEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
        
    }

    
    //Write the PrepareForSegue Method here
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            
            let  destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.delegate = self
        }
    }
    
    
    
    
}


