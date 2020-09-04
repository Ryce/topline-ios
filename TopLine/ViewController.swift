//
//  ViewController.swift
//  TopLine
//
//  Created by Hamon Riazy on 03/09/2020.
//  Copyright © 2020 UINTMAX Limited. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var startMappingButton: UIButton!
    @IBOutlet var travelTimeLabel: UILabel!
    
    private lazy var plottingService: PlottingService = {
        let service = PlottingService()
        service.delegate = self
        return service
    }()
    
    private var locationService: LocationService = LocationService()
    
    @IBAction func toggleTracking(sender: UIButton) {
        guard sender == startMappingButton else { return }
        if locationService.isRecording {
            locationService.stopTracking()
        } else {
            locationService.startTracking(with: plottingService)
        }
        startMappingButton.setTitle(locationService.isRecording ? "Stop Tracking" : "Start Tracking", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
}

extension ViewController: PlottingDelegate {
    
    func plottingService(service: PlottingService, didUpdatePlot line: MKPolyline) {
        // TODO: there should be a way to calculate the diff here and only add the vertices that are missing
        let previous = self.mapView.overlays.first
        self.mapView.addOverlay(line)
        if let previous = previous {
            mapView.removeOverlay(previous)
        }
        if let lastKnownLocation = locationService.lastKnownLocation,
            let distance = plottingService.bufferedDistance {
            let region = MKCoordinateRegion(center: lastKnownLocation.coordinate,
                                            latitudinalMeters: distance,
                                            longitudinalMeters: distance)
            mapView.setRegion(region, animated: true)
        }
        self.travelTimeLabel.text = plottingService.travelDuration.localizedString
    }
    
}

extension ViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let polyLine = overlay
        let polyLineRenderer = MKPolylineRenderer(overlay: polyLine)
        polyLineRenderer.strokeColor = .blue
        polyLineRenderer.lineWidth = 4.0
        return polyLineRenderer
    }
}

extension TimeInterval {
    
    var localizedString: String {
        let time = NSInteger(self)
        
        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)
        
        return String(format: "%0.2d:%0.2d:%0.2d", hours, minutes, seconds)
    }
    
}
