//
//  MSNearbyLocation.h
//
//  Created by Masud Shuvo on 10/24/16.
//  Copyright © 2016 Masud Shuvo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MSNearbyLocation : NSObject

@property (nonatomic, strong) NSString *locationTitle;
@property (nonatomic, strong) NSString *iconUrl;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
