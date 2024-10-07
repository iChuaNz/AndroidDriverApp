//
//  HomeViewController+CLLocationManagerDelegate.swift
//  BLPartnerApp
//
//  Created by Arif Rahman Sidik on 17/09/24.
//

import Foundation
import CoreLocation
import UIKit
import GoogleMaps
import GooglePlaces

extension HomeViewController: CLLocationManagerDelegate {
    
    // CLLocationManager delegate method for updating heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if isAutoUpdatingHeading {
            // Get the true heading (in degrees) and rotate the map accordingly
            let heading = newHeading.trueHeading
            
            if abs(heading - lastUpdatedHeading) >= headingThreshold {
                lastUpdatedHeading = heading
                
                let cameraUpdate = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(
                    withTarget: marker.position, // Keep the user marker in view
                    zoom: mapView.camera.zoom,
                    bearing: heading, // Update bearing only if the change is significant
                    viewingAngle: mapView.camera.viewingAngle
                ))
                mapView.animate(with: cameraUpdate)
            }
        }
    }
    
    // CLLocationManager delegate method for updating location (if needed)
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        // Optional: Handle location updates if you want the map to center on the user's location
        if let location = locations.last {
            let coordinate = location.coordinate
            
            // Update the marker position to the user's current location
            marker.position = coordinate
            
            // Auto-update map to follow user's location if enabled
            if isAutoUpdatingHeading {
                let cameraUpdate = GMSCameraUpdate.setCamera(GMSCameraPosition.camera(
                    withTarget: coordinate,
                    zoom: mapView.camera.zoom,
                    bearing: mapView.camera.bearing,
                    viewingAngle: mapView.camera.viewingAngle
                ))
                mapView.animate(with: cameraUpdate)
            }
        }
    }
    
    // Handle location authorization status changes
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            // Handle permission denial
            print("Location permission denied")
        }
    }
    
    // Handle errors
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error fetching location: \(error.localizedDescription)")
    }
}
