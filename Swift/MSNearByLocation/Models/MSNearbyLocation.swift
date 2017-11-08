//
//  MSNearbyLocation.swift
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/8/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

import UIKit

class MSNearbyLocation: NSObject {
    var locationTitle:NSString!
    var iconUrl:NSString!
    var latitude:Double!
    var longitude:Double!
    
    init(dictionary:NSDictionary) {
        
        self.locationTitle = dictionary.value(forKey: "name") as! NSString
        if (dictionary["location"] as AnyObject).isKind(of:NSDictionary.self) {
            let locationDictionary:NSDictionary = dictionary.value(forKey: "location") as! NSDictionary

            var value = locationDictionary.value(forKey: "lat") as! NSNumber
            self.latitude = value.doubleValue
            value = locationDictionary.value(forKey: "lng") as! NSNumber
            self.longitude = value.doubleValue
        }
        
        if (dictionary["categories"] as AnyObject).isKind(of:NSArray.self) {
            let array:NSArray = dictionary["categories"] as! NSArray
            if array.count > 0 {
                var infoDictionary:NSDictionary = array.object(at: 0) as! NSDictionary;
                if (infoDictionary["icon"] as AnyObject).isKind(of:NSDictionary.self) {
                    infoDictionary = infoDictionary["icon"] as! NSDictionary
                    
                    if let prefixString = infoDictionary["prefix"] as? String {
                        let sufixString = infoDictionary["suffix"] as? String
                        self.iconUrl = NSString(format: "%@bg_64%@", prefixString, sufixString!)
                    } else {
                        self.iconUrl = nil
                    }
                }
            }
        }
    }
}
