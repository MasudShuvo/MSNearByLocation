//
//  MSLocationViewController.h
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/7/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MSLocationViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@end

