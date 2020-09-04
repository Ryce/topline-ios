//
//  LocationService.swift
//  TopLine
//
//  Created by Hamon Riazy on 03/09/2020.
//  Copyright © 2020 UINTMAX Limited. All rights reserved.
//

import Foundation
import CoreLocation
import os

class LocationService: NSObject {
    
    private let locationManager: CLLocationManager = .init()
    private weak var plottingService: PlottingService?
    
    var isRecording: Bool = false
    
    var lastKnownLocation: CLLocation? = nil
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startTracking(with plottingService: PlottingService) {
        self.plottingService = plottingService
        locationManager.startUpdatingLocation()
        isRecording = true
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
        isRecording = false
    }
    
    
}


extension LocationService: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.last
        os_log("Did Update Location", type: .info)
        plottingService?.append(location: locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            os_log("Authorization given", type: .info)
        }
    }
    
}
