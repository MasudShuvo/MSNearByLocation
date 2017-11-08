//
//  MSLocationViewController.swift
//  MSNearByLocation
//
//  Created by Masud Shuvo on 11/8/17.
//  Copyright © 2017 Masud Shuvo. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MSLocationViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource  {

    @IBOutlet var tableView: UITableView!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var accuracyLabel: UILabel!
    @IBOutlet var locationListLabel: UILabel!
    
    var currentLocation:CLLocation? = nil
    var selectedLocation:CLLocation? = nil
    var point:MKPointAnnotation = MKPointAnnotation()
    var nearbyLocations:NSMutableArray = []
    var locationManager:CLLocationManager = CLLocationManager()
    var region:MKCoordinateRegion? = nil
    var alreadyAddedAnnotation:Bool = false
    var isCurrentLocation:Bool = false
    
    @IBAction func currentLocationClicked(_ sender: UIButton) {
        if ((self.currentLocation) != nil) {
            //Focus selected location
            self.region = MKCoordinateRegionMakeWithDistance((self.currentLocation?.coordinate)!, 800, 800);
            self.mapView.setRegion(self.mapView.regionThatFits(self.region!), animated: true)
            
            //Remove previous annotations.
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            //Add an annotation on selected location and find out nearby places of that location
            self.point.coordinate = (self.currentLocation?.coordinate)!;
            self.mapView.addAnnotation(self.point)
            self.isCurrentLocation = true;
            
            loadNearbyLocation(latitude:(self.currentLocation?.coordinate.latitude)!, longitude: (self.currentLocation?.coordinate.longitude)!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.tableFooterView = UIView()
        initiateLocationManager()
        addTapGesture()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func addTapGesture() {
        let tapGestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer()
        tapGestureRecognizer.addTarget(self, action:#selector(didTapMap(gestureRecognizer:)))
        self.mapView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func initiateLocationManager() {
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation();
    }
    
    @objc func didTapMap(gestureRecognizer:UITapGestureRecognizer) {
    
        //Remove previous annotations.
        self.mapView.removeAnnotations(self.mapView.annotations)

        //Findout touch point on map view.
        let touchPoint:CGPoint = gestureRecognizer.location(in: self.mapView)
        let touchMapCoordinate:CLLocationCoordinate2D = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        
        self.selectedLocation = CLLocation.init(latitude: touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
        self.point.coordinate = touchMapCoordinate
    
        //Add an annotation on selected location and find out nearby places of that location
        self.mapView.addAnnotation(self.point);
        self.region = MKCoordinateRegionMakeWithDistance(touchMapCoordinate, 800, 800);
        self.mapView.setRegion(self.mapView.regionThatFits(self.region!), animated: true)
        self.isCurrentLocation = false;
        loadNearbyLocation(latitude:touchMapCoordinate.latitude, longitude: touchMapCoordinate.longitude)
    
    }

    func loadLocationListLabel() {
        if (self.nearbyLocations.count > 0) {
            self.locationListLabel.text = "Locations near you.";
        } else {
            self.locationListLabel.text = "";
        }
    }
    
    
    func loadNearbyLocation(latitude:Double, longitude:Double) {
    
        MSNearbyLocationDataService.fetchLocations(latitude:latitude, longitude:longitude, completion: { (_ locationArray:[AnyObject]?) in
            if locationArray?.isEmpty == false {
                self.nearbyLocations.removeAllObjects()
                self.nearbyLocations.addObjects(from: locationArray!)
                self.loadLocationListLabel()
                self.tableView.reloadData()
            }
        })
    }
    
    // MARK: - UITableViewDelegate methods
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40;
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let location:MSNearbyLocation = self.nearbyLocations.object(at: indexPath.row) as! MSNearbyLocation;
        let placeLocation:CLLocation = CLLocation.init(latitude: location.latitude, longitude: location.longitude)
        self.region = MKCoordinateRegionMakeWithDistance(placeLocation.coordinate, 50, 50);
        self.mapView.setRegion(self.mapView.regionThatFits(self.region!), animated: true)
    }
    
    // MARK: - UITableViewDataSource methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.nearbyLocations.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifer:NSString = NSString(format: "cell%tu",indexPath.row)
        var cell:MSLocationTableViewCell? = tableView.dequeueReusableCell(withIdentifier: cellIdentifer as String) as? MSLocationTableViewCell;
        //Add annotaion on location
        
        if cell == nil {
            let topLevelObjects:NSArray = Bundle.main.loadNibNamed("MSLocationTableViewCell", owner: self, options: nil)! as NSArray
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = topLevelObjects[0] as? MSLocationTableViewCell
        }
        
        let location:MSNearbyLocation? = (self.nearbyLocations.object(at: indexPath.row) as! MSNearbyLocation)
        
        let locationPoint:CLLocationCoordinate2D? = CLLocationCoordinate2D.init(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
        
        let nearbyPlaces:MKPointAnnotation = MKPointAnnotation();
        nearbyPlaces.coordinate = locationPoint!;
        self.mapView.addAnnotation(nearbyPlaces)
        cell?.locationTitle.text = location?.locationTitle as String?
        
        //Fetch location icon
        if location?.iconUrl != nil {
            let url:URL = URL(string: location!.iconUrl as String)!
            let request = URLRequest(url: url as URL)
            let session = URLSession.shared
            cell?.activityIndicatorView.isHidden = false;
            
            let task = session.dataTask(with: request, completionHandler: {(data, response, error) -> Void in
                if (data != nil) {
                    let image:UIImage? = UIImage(data: data!)
                    
                    if image != nil {
                        DispatchQueue.main.async {
                            let updateCell:MSLocationTableViewCell? = tableView.cellForRow(at: indexPath) as? MSLocationTableViewCell
                            if updateCell != nil {
                            //Display fetched location icon on table view cell
                                updateCell?.locationImage.image = image;
                                updateCell?.activityIndicatorView.isHidden = true
                            }
                        }
                    }
                }
                DispatchQueue.main.async {
                    cell?.activityIndicatorView.isHidden = true;
                }
            })
            task.resume()
        }
        return cell!;
    }
    
    // MARK: - CLLocationManager methods
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count != 0) {
            self.currentLocation = locations[0];
            
            let horizontalAccuracy:Double = (self.currentLocation?.horizontalAccuracy)!
            
            if horizontalAccuracy > 0.0 {
                self.accuracyLabel.text = NSString(format:"Accurate to %.0f meters", (self.currentLocation?.horizontalAccuracy)!) as String
            } else {
                self.accuracyLabel.text = "Accurate to few meters";
            }
            
            if self.alreadyAddedAnnotation == false {
                self.alreadyAddedAnnotation = true;
                let region:MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(self.currentLocation!.coordinate, 800, 800);
                self.mapView.setRegion(self.mapView.regionThatFits(region), animated: true)
    
                //Remove previous annotations.
                self.mapView.removeAnnotations(self.mapView.annotations);
                
                //Add an annotation on selected location and find out nearby places of that location
                self.point.coordinate = (self.currentLocation?.coordinate)!;
                self.mapView.addAnnotation(self.point);
               
                self.isCurrentLocation = true;
                loadNearbyLocation(latitude:(self.currentLocation?.coordinate.latitude)!, longitude: (self.currentLocation?.coordinate.longitude)!)
            }
        }
    }
    
    // MARK: - MKMapViewDelegate methods
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let LocationAnnotationIdentifier:NSString = "LocationAnnotationIdentifier";
        var annotationView:MKPinAnnotationView? = self.mapView.dequeueReusableAnnotationView(withIdentifier: LocationAnnotationIdentifier as String) as? MKPinAnnotationView
        
        if (annotationView == nil) {
            annotationView = MKPinAnnotationView.init(annotation: annotation, reuseIdentifier: LocationAnnotationIdentifier as String)
        }
        
        annotationView?.isEnabled = true;
        annotationView?.canShowCallout = false;
        return annotationView;
    }
}

