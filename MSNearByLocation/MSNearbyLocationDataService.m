//
//  NearbyLocationDataService.m
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/7/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

#import "MSNearbyLocationDataService.h"
#import "MSNearbyLocation.h"

static NSString *const fourSqureAPI = @"https://api.foursquare.com/v2/venues/search?v=20161016";
static NSString *const clientId = @"WCUGWR3VYQH4KVTCQ3EKSDLK1LSHTTVQQGMNSOAKKGRBOK2P";
static NSString *const clientSecret = @"YFO050U1LALEVT5E2XIN1FUX0HUQ130WMXX1J5O4Y4PXNEQ4";

@implementation MSNearbyLocationDataService

+ (void)fetchLocationsDataForLatitude:(float)latitude andLongitude:(float)longitude withCompletion:(void (^) (NSArray *locationArray, NSError *error))completion {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@&client_id=%@&client_secret=%@&ll=%@,%@",fourSqureAPI, clientId, clientSecret, [NSNumber numberWithFloat:latitude], [NSNumber numberWithFloat:longitude]]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler: ^(NSData *data, NSURLResponse *response, NSError *error) {
        
        if (error)
        {
            //Get error response
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, error);
            });
            return;
        }
        
        NSError *jsonError;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
        
        if(jsonError)
        {
            //Get error response
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, jsonError);
            });
            return;
        }
        
        NSArray *results;
        
        if (![json[@"response"] isKindOfClass:[NSDictionary class]]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //[json[@"response"] should contain a dictionary. But it is not, so invaild response.
                completion(nil, [NSError errorWithDomain:@"00001" code:1001 userInfo:[NSDictionary dictionaryWithObject:@"invalid response" forKey:NSLocalizedDescriptionKey]]);
            });
            return;
        } else {
            NSDictionary *dictionary = json[@"response"];
            if(![dictionary[@"venues"] isKindOfClass:[NSArray class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //[dictionary[@"venues"] should contain an array. But it is not, so invaild response.
                    completion(nil, [NSError errorWithDomain:@"00001" code:1001 userInfo:[NSDictionary dictionaryWithObject:@"invalid response" forKey:NSLocalizedDescriptionKey]]);
                });
                return;
            } else {
                results = dictionary[@"venues"];
            }
        };
        
        NSMutableArray *mutableLocationArray = [[NSMutableArray alloc] init];
        
        [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![obj isKindOfClass:[NSDictionary class]]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    //obj should be a dictionary. But it is not, so invaild response.
                    completion(nil, [NSError errorWithDomain:@"00001" code:1001 userInfo:[NSDictionary dictionaryWithObject:@"invalid response" forKey:NSLocalizedDescriptionKey]]);
                });
                *stop = YES;
                return;
            }
            //Populate location objects
            MSNearbyLocation *loaction = [[MSNearbyLocation alloc] initWithDictionary:obj];
            [mutableLocationArray addObject:loaction];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(mutableLocationArray, nil);
        });
        
    }];
    [task resume];
}

@end
