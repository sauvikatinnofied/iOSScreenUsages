//
//  LocationManager.swift
//  ScreenUsages
//
//  Created by Sauvik Dolui on 26/2/16.
//  Copyright (c) 2016 Innofied Solution Pvt. Ltd. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit

/// Handles all the location related tasks of an application
class LocationManager: NSObject{
    
    //MARK: - PUBLIC PROPERTIES
    var currentLocation: CLLocation?
    var currentLocationCoordinate: CLLocationCoordinate2D?
    var isDataAvailable: Bool = false // Defalut value
    var currentLocality: String = "Not Available"
    var locationAccuracy = kCLLocationAccuracyBest
    var distanceFilter = kCLDistanceFilterNone
    var shouldFetchLocality: Bool = false
    
    var officeLocationLat: Double = 22.5992489
    var officeLocationLng: Double = 88.4193389
    let locationUpdateNotificatonName = "LocationUpdated"
    
    
    //MARK: - PRIVATE PROPERTIES
    private var locationManager: CLLocationManager?
    
    //MARK: - SHARED INSTANCE
    static var sharedManager = LocationManager()
    
    //MARK: - INITIAIZATION
    override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.distanceFilter = distanceFilter
        locationManager?.desiredAccuracy = locationAccuracy
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.activityType = .AutomotiveNavigation
        
        if UIDevice.currentDevice().model == "iPhone" {
            // Device is simulator , going to add hard coded location data
            currentLocationCoordinate = CLLocationCoordinate2DMake(officeLocationLat, officeLocationLng)
            currentLocation = CLLocation(latitude: officeLocationLat, longitude: officeLocationLng)
        } else {
            // Precautions for nil value of current location coordinate.
            currentLocationCoordinate = CLLocationCoordinate2DMake(officeLocationLat, officeLocationLng)
            currentLocation = CLLocation(latitude: officeLocationLat, longitude: officeLocationLng)
        }
        
        // user activated automatic attraction info mode
        let status = CLLocationManager.authorizationStatus()
        if status == .NotDetermined || status == .Denied || status == .AuthorizedWhenInUse {
            // present an alert indicating location authorization required
            // and offer to take the user to Settings for the app via
            // UIApplication -openUrl: and UIApplicationOpenSettingsURLString
            locationManager!.requestAlwaysAuthorization()
        }
    }
    /**
    Starts updating location services
    */
    func startUpdatingLocation() {
        locationManager?.startUpdatingLocation()
    }
    /**
    Stops updating location services
    */
    func stopUpdatingLocation() {
        locationManager?.stopUpdatingLocation()
    }
    /**
     Starts monitoring significant location changes
     */
    func startMonitoringSignificantLocationChanges(){
        locationManager?.startMonitoringSignificantLocationChanges()
    }
}

//MARK: Location Manager Delegate Methods
extension LocationManager: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        isDataAvailable = true
        currentLocation = locations.last
        currentLocationCoordinate = currentLocation?.coordinate
        
        if shouldFetchLocality {
            // Getting current locality with GeoCoder
            CLGeocoder().reverseGeocodeLocation(currentLocation!, completionHandler: {(placemarks, error) in
                if (error != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                }
                else {
                        let placeMark = placemarks!.last
                        self.currentLocality = placeMark!.locality!
                }
            })
        }
        NSNotificationCenter.defaultCenter().postNotificationName(locationUpdateNotificatonName, object: nil, userInfo: nil)
    }
}