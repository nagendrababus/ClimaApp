//
//  ViewController.swift
//  WeatherApp
//
//  Created by Angela Yu on 23/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON


class WeatherViewController: UIViewController, CLLocationManagerDelegate, changeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "f94021d114122207f71bc296b135765d"
    

    //TODO: Declare instance variables here
    let locationManager = CLLocationManager()
    let wetherDataModelObj = WeatherDataModel()

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO:Set up the location manager here.
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    
    
    //MARK: - Networking
    /***************************************************************/
    
    //Write the getWeatherData method here:
    
    func getWeatherData(url:String, parameters:[String : String]){
        
        Alamofire.request(url, method: .get, parameters:parameters).responseJSON { (response) in
            if response.result.isSuccess{
                print("Success! got wether data")
                let wetherJson : JSON = JSON(response.result.value!)
                self.updateWetherData(json: wetherJson)
            }else{
                print("Error: \(response.result.error)")
                self.cityLabel.text = "Connection Issues"
            }
        }
        
    }
    
    
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    
    //Write the updateWeatherData method here:
    
    func updateWetherData(json : JSON){
        
        if let tempResult = json["main"]["temp"].double{
            wetherDataModelObj.temprature = Int(tempResult - 273.15)
            wetherDataModelObj.city = json["name"].stringValue
            wetherDataModelObj.condition = json["weather"][0]["id"].intValue
            wetherDataModelObj.wetherIconName = wetherDataModelObj.updateWeatherIcon(condition: wetherDataModelObj.condition)
            updateUIWithWeatherData()
        }else{
            cityLabel.text = "Weather unavailable"
        }
    }
    

    
    
    
    //MARK: - UI Updates
    /***************************************************************/
    
    
    //Write the updateUIWithWeatherData method here:
    
    func updateUIWithWeatherData(){
        cityLabel.text = wetherDataModelObj.city
        temperatureLabel.text = "\(wetherDataModelObj.temprature)°"
        weatherIcon.image = UIImage(named: wetherDataModelObj.wetherIconName)
    }
    
    
    
    
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    
    //Write the didUpdateLocations method here:
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            print("Longitude : \(location.coordinate.longitude)")
            print("Latitude : \(location.coordinate.latitude)")
            
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            
            let params:[String:String] = ["lat" : latitude,"lon": longitude,"appid":APP_ID]
            
            getWeatherData(url: WEATHER_URL, parameters: params)
        }
    }
    
    
    
    //Write the didFailWithError method here:
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location is unavailable"
    }
    

    
    //MARK: - Change City Delegate methods
    /***************************************************************/
    
    
    //Write the userEnteredANewCityName Delegate method here:
    
    func userEnteredANewCityName(city: String) {
        
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    
    //Write the PrepareForSegue Method here
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "changeCityName"{
        
            let destinationVC = segue.destination as! ChangeCityViewController
            
            destinationVC.customDelegate = self
        }
    }
    
    
    
}


