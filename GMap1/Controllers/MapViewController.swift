//
//  MapViewController.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, TypesTableViewControllerDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
  
  @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
  @IBOutlet weak var mapCenterPinImage: UIImageView!
  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
  var searchedTypes = ["bakery", "bar", "cafe", "grocery_or_supermarket", "restaurant"]
  let locationManager = CLLocationManager()
  var mapRadius: Double {
    get {
      let region = mapView.projection.visibleRegion()
      let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
      let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
      return max(horizontalDistance, verticalDistance)*0.5
    }
  }
  let dataProvider = GoogleDataProvider()

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    locationManager.delegate = self
    locationManager.requestWhenInUseAuthorization()
    mapView.delegate = self
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "Types Segue" {
      let navigationController = segue.destinationViewController as! UINavigationController
      let controller = segue.destinationViewController.topViewController as! TypesTableViewController
      controller.selectedTypes = searchedTypes
      controller.delegate = self
    }
  }
  
  func typesController(controller: TypesTableViewController, didSelectTypes types: [String]) {
    searchedTypes = sorted(controller.selectedTypes)
    dismissViewControllerAnimated(true, completion: nil)
    fetchNearbyPlaces(mapView.camera.target)
  }
  
  @IBAction func mapTypeSegmentPressed(sender: AnyObject) {
    let segmentedControl = sender as! UISegmentedControl
    switch segmentedControl.selectedSegmentIndex {
    case 0:
      mapView.mapType = kGMSTypeNormal
    case 1:
      mapView.mapType = kGMSTypeSatellite
    case 2:
      mapView.mapType = kGMSTypeHybrid
    default:
      mapView.mapType = mapView.mapType
    }
  }
  
  @IBAction func refreshPlaces(sender: AnyObject) {
    fetchNearbyPlaces(mapView.camera.target)
  }
  func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
    if status == .AuthorizedWhenInUse {
      locationManager.startUpdatingLocation()

      mapView.myLocationEnabled = true
      mapView.settings.myLocationButton = true
    }
  }
  
  func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
    if let location = locations.first as? CLLocation {
      fetchNearbyPlaces(location.coordinate)
      mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
      
      locationManager.stopUpdatingLocation()
    }
  }
  func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D) {
    
    let geocoder = GMSGeocoder()
    
    geocoder.reverseGeocodeCoordinate(coordinate) { response , error in
      self.addressLabel.unlock()
      if let address = response?.firstResult() {
        
        let lines = address.lines as! [String]
        self.addressLabel.text = join("\n", lines)
        
        UIView.animateWithDuration(0.25) {
          // 1
          let labelHeight = self.addressLabel.intrinsicContentSize().height
          self.mapView.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: labelHeight, right: 0)
          
          UIView.animateWithDuration(0.25) {
            //2
            self.pinImageVerticalConstraint.constant = ((labelHeight - self.topLayoutGuide.length) * 0.5)
            self.view.layoutIfNeeded()
          }
        }
      }
    }
  }
  
  func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
    reverseGeocodeCoordinate(position.target)
  }
  func mapView(mapView: GMSMapView!, willMove gesture: Bool) {
    addressLabel.lock()
  }
  
  func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D) {
    // 1
    mapView.clear()
    // 2
    dataProvider.fetchPlacesNearCoordinate(coordinate, radius:mapRadius, types: searchedTypes) { places in
      for place: GooglePlace in places {
        // 3
        let marker = PlaceMarker(place: place)
        // 4
        marker.map = self.mapView
      }
    }
  }
}

