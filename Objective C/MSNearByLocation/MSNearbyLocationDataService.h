//
//  MSNearbyLocationDataService.h
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/7/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MSNearbyLocationDataService : NSObject

+ (void)fetchLocationsDataForLatitude:(float)latitude andLongitude:(float)longitude withCompletion:(void (^) (NSArray *locationArray, NSError *error))completion;

@end
