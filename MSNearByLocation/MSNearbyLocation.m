//
//  MSNearbyLocation.m
//
//  Created by Masud Shuvo on 10/24/16.
//  Copyright © 2016 Masud Shuvo. All rights reserved.
//

#import "MSNearbyLocation.h"

@implementation MSNearbyLocation

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        self.locationTitle = dictionary[@"name"];
            
        if ([dictionary[@"location"] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *locationDictionary = dictionary[@"location"];
            
            self.latitude = [locationDictionary[@"lat"] floatValue];
            self.longitude = [locationDictionary[@"lng"] floatValue];
        }
        if ([dictionary[@"categories"] isKindOfClass:[NSArray class]]) {
            NSArray *array = dictionary[@"categories"];
            if(array.count > 0) {
                NSDictionary *infoDictionary = [array objectAtIndex:0];
                if ([infoDictionary[@"icon"] isKindOfClass:[NSDictionary class]]) {
                    infoDictionary = infoDictionary[@"icon"];
                    if(infoDictionary[@"prefix"]) {
                        self.iconUrl = [NSString stringWithFormat:@"%@bg_64%@",infoDictionary[@"prefix"], infoDictionary[@"suffix"]];
                    } else {
                        self.iconUrl = nil;
                    }
                }
            }
        }
    }
    return self;
}

@end
