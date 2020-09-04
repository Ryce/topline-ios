//
//  PlottingService.swift
//  TopLine
//
//  Created by Hamon Riazy on 03/09/2020.
//  Copyright © 2020 UINTMAX Limited. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

protocol PlottingDelegate: class {
    func plottingService(service: PlottingService, didUpdatePlot line: MKPolyline)
}

class PlottingService {
    
    weak var delegate: PlottingDelegate?
    
    // collecting date so we can get an idea of how long a person is standing still
    private var locationHistory: [CLLocation] = []
    private var sorted: [CLLocation] {
        return locationHistory.sorted(by: { $0.timestamp > $1.timestamp })
    }
    
    var travelDuration: TimeInterval {
        guard locationHistory.count >= 2 else { return 0 }
        return sorted.last!.timestamp.distance(to: sorted.first!.timestamp)
    }
    
    var plot: MKPolyline {
        let points: [CLLocationCoordinate2D] = locationHistory.sorted(by: { $0.timestamp < $1.timestamp }).filteredCloseProximity().map({ $0.coordinate })
        return MKPolyline(coordinates: points, count: points.count)
    }
    
    var bufferedDistance: CLLocationDistance?
    
    func append(location: CLLocation) {
        locationHistory.append(location)
        // TODO: measure speed/velocity instead of total amount of points to compute the distance
        if locationHistory.count > 2 {
            let slice = locationHistory[(locationHistory.count/2)...]
            if let lhs = slice.first, let rhs = slice.last {
                bufferedDistance = lhs.distance(from: rhs) * 1.2
            }
        }
        self.delegate?.plottingService(service: self, didUpdatePlot: self.plot)
    }
    
}



extension Array where Element == CLLocation {
    
    // Filter points with close proximity
    func filteredCloseProximity() -> Self {
        // This would be much easier in Python
        guard self.count > 2 else { return self }
        var filtered: Self = [self[0]]
        var index = 1
        while self.count > index + 1 {
            if self[index - 1].distance(from: self[index + 1]) > 0.1 {
                filtered.append(self[index])
            }
            index += 1
        }
        return filtered
    }
    
}
