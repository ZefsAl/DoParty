//
//  MapViewModel.swift
//  DoParty
//
//  Created by Serj on 02.07.2022.
//

import SwiftUI
import MapKit
import CoreLocation

// All Map Data goes here
// Весь этот класс и функции в нем работают таким образом. Описанные функции относящеесе к Manager выполняется

class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published var mapView = MKMapView()
    // Region
    @Published var region: MKCoordinateRegion!
    // Based on Location it will set up
    
    // Alert
    @Published var permissionDenied = false
    
    // Map Type
    @Published var mapType: MKMapType = .standard
    
    // Search text
    @Published var searchText: String = ""
    
    // Searched places
    @Published var places: [Place] = []
    
    @Published var annotationArray: [MKPointAnnotation] = []
    
    
    
    
    // Updating map type
    func updateMapType() {
        if mapType == .standard {
            mapType = .hybrid
            mapView.mapType = mapType
        } else {
            mapType = .standard
            mapView.mapType = mapType
        }
    }
    
    // Focus location
    func focusLocation() {
        
        guard let _ = region else { return }
        
        mapView.setRegion(region, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
    }
    
    // Search places
    func searchQuery() {
        
        places.removeAll()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        
        // Fetch
        MKLocalSearch(request: request).start { ( response, _ ) in
            guard let result = response else { return }
            self.places = result.mapItems.compactMap({ (item) -> Place? in
                return Place(place: item.placemark)
            })
        }
    }
    
    // Search from text field
    func setUpPlacemark(/* adressPlace: String */) { /* [self] in */
        
        // скорее всего что то с locationManager или с ссылками в setUpPlacemark
        
        let adressPlace = searchText
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(adressPlace) { (placemarks, error) in
            if let error = error {
                print(error)
                //self.vmError.alertError(title: "Error", message: "Server is not response")
             return
            }
            
            guard let placemarks = placemarks else { return }
            let placemark = placemarks.first
            
            let annotation = MKPointAnnotation()
            annotation.title = "\(adressPlace)"
            
            guard let placemarkLocation = placemark?.location else { return }
            annotation.coordinate = placemarkLocation.coordinate
            
            // Add annotation
            self.annotationArray.append(annotation)
            self.mapView.showAnnotations(self.annotationArray, animated: true)
            
            //guard let coordinate = annotationArray
//            let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
//            mapView.setRegion(coordinateRegion, animated: true)
//            mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        }
    }
    
    // Pick search result
    func selectPlace(place: Place) {
        
        // Showing pin on map
        searchText = ""
        
        guard let coordinate = place.place.location?.coordinate else { return }
        
        
        let pointAnnotation = MKPointAnnotation()
        pointAnnotation.coordinate = coordinate
        pointAnnotation.title = place.place.name ?? "Error name"
        
        // Removing all old once
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotation(pointAnnotation)
        
        // Moving map to that location
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(coordinateRegion, animated: true)
        mapView.setVisibleMapRect(mapView.visibleMapRect, animated: true)
        
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        // Check permissions
        switch manager.authorizationStatus {
        case .denied:
            // Alert
            permissionDenied.toggle()
        case .notDetermined:
            // Requesting
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            // If permission given
            manager.requestLocation()
        default:
            ()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // User location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        self.region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        
        // Updating map
        self.mapView.setRegion(self.region, animated: true)
        self.mapView.setVisibleMapRect(self.mapView.visibleMapRect, animated: true)
    }
    
    
    
}
