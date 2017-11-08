//
//  MSNearbyLocationDataService.swift
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/8/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

import UIKit

let fourSqureAPI = "https://api.foursquare.com/v2/venues/search?v=20161016"
let clientId = "WCUGWR3VYQH4KVTCQ3EKSDLK1LSHTTVQQGMNSOAKKGRBOK2P"
let clientSecret = "YFO050U1LALEVT5E2XIN1FUX0HUQ130WMXX1J5O4Y4PXNEQ4"

class MSNearbyLocationDataService: NSObject {
    public static func fetchLocations(latitude:Double, longitude:Double, completion:@escaping (_ locationArray:[AnyObject]?)-> Void ) {
        let apiUrl = String(format: "%@&client_id=%@&client_secret=%@&ll=%@,%@",fourSqureAPI, clientId, clientSecret,NSNumber(value: Double(latitude)), NSNumber(value: Double(longitude)))

        let url:URL = URL(string: apiUrl)!
        let request = URLRequest(url: url)
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
            if (error != nil) {
                //If error occurs return nil in completion
                completion(nil)
                return
            } else if (data != nil) {
                var array:[MSNearbyLocation] = [MSNearbyLocation]()
                let json = try? JSONSerialization.jsonObject(with: data!, options: [])
                //Check if json is type of dictionary as application expect a dictionary here
                if let jsonDictionary = json as? NSDictionary {
                    //Check jsonDictionary["candidates"] contains an array or not
                    if let locationDictionary = jsonDictionary["response"] as? NSDictionary {
                        
                        if let locationArray = locationDictionary["venues"] as? NSArray {
                            for locationInfo in locationArray {
                            //Generate candidate instance
                                let dictionary = locationInfo as? NSDictionary
                                let location:MSNearbyLocation = MSNearbyLocation(dictionary:dictionary!)
                                array.append(location)
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion(array)
                }
            }
        })
        task.resume()
    }
}
