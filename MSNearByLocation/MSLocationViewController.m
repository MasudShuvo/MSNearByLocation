//
//  MSLocationViewController.m
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/7/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

#import "MSLocationViewController.h"
#import "MSLocationTableViewCell.h"
#import "MSNearbyLocationDataService.h"
#import "MSNearbyLocation.h"
#import <CoreLocation/CoreLocation.h>

@interface MSLocationViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (nonatomic, weak) IBOutlet UILabel *accuracyLabel;
@property (nonatomic, weak) IBOutlet UILabel *locationListLabel;
@property (nonatomic, strong) CLLocation *currentLocation;
@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) MKPointAnnotation *point;
@property (nonatomic, strong) NSMutableArray *nearbyLocations;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign) MKCoordinateRegion region;
@property (nonatomic, assign) BOOL alreadyAddedAnnotation;
@property (nonatomic, assign) BOOL isCurrentLocation;

-(IBAction)currentLocationClicked:(UIButton *)sender;

@end

@implementation MSLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.alreadyAddedAnnotation = NO;
    self.nearbyLocations = [NSMutableArray array];
    self.point = [[MKPointAnnotation alloc] init];
    self.tableView.tableFooterView = [UIView new];
    [self initiateLocationManager];
    [self addTapGesture];
}

- (void)addTapGesture {
    UITapGestureRecognizer* tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self action:@selector(didTapMap:)];
    [self.mapView addGestureRecognizer:tapGestureRecognizer];
}

- (void)initiateLocationManager {
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    [self.locationManager startUpdatingLocation];
}

- (void)didTapMap:(UITapGestureRecognizer *)gestureRecognizer {
    
    //Remove previous annotations.
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    //Findout touch point on map view.
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    self.selectedLocation = [[CLLocation alloc] initWithLatitude:touchMapCoordinate.latitude longitude:touchMapCoordinate.longitude];
    self.point.coordinate = touchMapCoordinate;
    
    //Add an annotation on selected location and find out nearby places of that location
    [self.mapView addAnnotation:self.point];
    self.region = MKCoordinateRegionMakeWithDistance(touchMapCoordinate, 800, 800);
    [self.mapView setRegion:[self.mapView regionThatFits:self.region] animated:YES];
    self.isCurrentLocation = NO;
    [self loadNearbyLocationsForLatitude:touchMapCoordinate.latitude andLongitude:touchMapCoordinate.longitude searchString:nil];
    
}

- (void)loadNearbyLocationsForLatitude:(float)latitude andLongitude:(float)longitude searchString:(NSString *)searchString {
    
    [MSNearbyLocationDataService fetchLocationsDataForLatitude:latitude andLongitude:longitude withCompletion:^(NSArray *locationArray, NSError *error) {
        if (!error) {
            //Got nearby locations. Now plot them on map.
            [self.nearbyLocations removeAllObjects];
            [self.nearbyLocations addObjectsFromArray:locationArray];
            [self loadLocationListLabel];
            [self.tableView reloadData];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark IBAction
-(IBAction)currentLocationClicked:(UIButton *)sender
{
    if (self.currentLocation) {
        //Focus selected location
        self.region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 800, 800);
        [self.mapView setRegion:[self.mapView regionThatFits:self.region] animated:YES];
        
        //Remove previous annotations.
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        //Add an annotation on selected location and find out nearby places of that location
        self.point.coordinate = self.currentLocation.coordinate;
        [self.mapView addAnnotation:self.point];
        self.isCurrentLocation = YES;
        [self loadNearbyLocationsForLatitude:self.currentLocation.coordinate.latitude andLongitude:self.currentLocation.coordinate.longitude searchString:nil];
    }
}

- (void)loadLocationListLabel {
    if (self.nearbyLocations.count > 0) {
        self.locationListLabel.text = @"Locations near you.";
    } else {
        self.locationListLabel.text = @"";
    }
}

#pragma UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MSNearbyLocation *location = [self.nearbyLocations objectAtIndex:indexPath.row];
    CLLocation *placeLocation = [[CLLocation alloc] initWithLatitude:location.latitude longitude:location.longitude];
    //Focus selected location
    self.region = MKCoordinateRegionMakeWithDistance(placeLocation.coordinate, 50, 50);
    [self.mapView setRegion:[self.mapView regionThatFits:self.region] animated:YES];
}

#pragma UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.nearbyLocations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifer = [NSString stringWithFormat:@"cell%tu",indexPath.row];
    
    MSLocationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer];
    
    if (cell == nil) {
        // Load the top-level objects from the custom cell XIB.
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"MSLocationTableViewCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    //Add annotaion on location
    MSNearbyLocation *location = [self.nearbyLocations objectAtIndex:indexPath.row];
    CLLocationCoordinate2D locationPoint;
    locationPoint.latitude = location.latitude;
    locationPoint.longitude = location.longitude;
    
    MKPointAnnotation *nearbyPlaces = [[MKPointAnnotation alloc] init];
    nearbyPlaces.coordinate = locationPoint;
    [self.mapView addAnnotation:nearbyPlaces];
    cell.locationTitle.text = location.locationTitle;
    
    //Fetch location icon
    if (location.iconUrl) {
        NSURL *url = [NSURL URLWithString:location.iconUrl];
        cell.activityIndicatorView.hidden = NO;
        
        NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (data) {
                UIImage *image = [UIImage imageWithData:data];
                if (image) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MSLocationTableViewCell *updateCell = (id)[tableView cellForRowAtIndexPath:indexPath];
                        if (updateCell) {
                            //Display fetched location icon on table view cell
                            updateCell.locationImage.image = image;
                            updateCell.activityIndicatorView.hidden = YES;
                        }
                        
                    });
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                cell.activityIndicatorView.hidden = YES;
            });
        }];
        [task resume];
    }
    return cell;
}

#pragma mark -
#pragma mark CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations
{
    if (locations && locations.count != 0) {
        self.currentLocation=[locations objectAtIndex:0];
        if (self.currentLocation.horizontalAccuracy > 0) {
            self.accuracyLabel.text = [NSString stringWithFormat:@"Accurate to %.0f meters", self.currentLocation.horizontalAccuracy];
        } else {
            self.accuracyLabel.text = @"Accurate to few meters";
        }
        if (!self.alreadyAddedAnnotation) {
            self.alreadyAddedAnnotation = YES;
            
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.currentLocation.coordinate, 800, 800);
            [self.mapView setRegion:[self.mapView regionThatFits:region] animated:YES];
            
            //Remove previous annotations.
            [self.mapView removeAnnotations:self.mapView.annotations];
            
            //Add an annotation on selected location and find out nearby places of that location
            self.point.coordinate = self.currentLocation.coordinate;
            [self.mapView addAnnotation:self.point];
            self.isCurrentLocation = YES;
            [self loadNearbyLocationsForLatitude:self.currentLocation.coordinate.latitude andLongitude:self.currentLocation.coordinate.longitude searchString:nil];
        }
    }
}

#pragma mark -
#pragma mark MKMapView delegate
- (MKAnnotationView *)mapView:(MKMapView *)mapview viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString* LocationAnnotationIdentifier = @"LocationAnnotationIdentifier";
    MKPinAnnotationView *annotationView =(MKPinAnnotationView *) [self.mapView dequeueReusableAnnotationViewWithIdentifier:LocationAnnotationIdentifier];
    if (!annotationView) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:LocationAnnotationIdentifier];
    }
    
    annotationView.enabled = YES;
    annotationView.canShowCallout = NO;
    return annotationView;
}

@end
