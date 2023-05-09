//
//  MapView.swift
//  MapLibreDemo
//
//  Created by Stefan Karschti on 09.05.2023.
//

import Mapbox
import SwiftUI
import CoreLocation

class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var userLocation: CLLocationCoordinate2D?
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        userLocation = location.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location update failed with error: \(error.localizedDescription)")
    }
}

struct MapView: UIViewRepresentable {
    @State private var userLocation: CLLocationCoordinate2D?
    var mapView = MGLMapView(frame: .zero, styleURL: MGLStyle.defaultStyleURL())
    let locationManager = CLLocationManager()
    let locationDelegate = LocationDelegate()
    
    func makeUIView(context: Context) -> MGLMapView {
        // read the key from property list
        let mapTilerKey = getMapTilerkey()
        validateKey(mapTilerKey)
        
        // Build the style url
        let styleURL = URL(string: "https://api.maptiler.com/maps/streets/style.json?key=\(mapTilerKey)")
        
        // create the mapview
        mapView.styleURL = styleURL;
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.showsUserLocation = true
        mapView.setZoomLevel(0, animated: false)
        
        // use the coordinator only if you need
        // to respond to the map events
        mapView.delegate = context.coordinator
        
        // location stuff
        locationManager.delegate = context.coordinator
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) {
        guard let location = self.userLocation else { return }
        let z = max(mapView.zoomLevel, 14)
        mapView.setCenter(location, zoomLevel: z, animated: true)
    }
    
    func makeCoordinator() -> MapView.Coordinator {
        Coordinator(self)
    }
    
    final class Coordinator: NSObject, MGLMapViewDelegate, CLLocationManagerDelegate {
        var control: MapView
        
        init(_ control: MapView) {
            self.control = control
        }

        func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
            // write your custom code which will be executed
            // after map has been loaded
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last?.coordinate else { return }
            control.userLocation = location
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location update failed with error: \(error.localizedDescription)")
        }
    }
    
    func getMapTilerkey() -> String {
        let mapTilerKey = Bundle.main.object(forInfoDictionaryKey: "MapTilerKey") as? String
        validateKey(mapTilerKey)
        return mapTilerKey!
    }
    
    func validateKey(_ mapTilerKey: String?) {
        if (mapTilerKey == nil) {
            preconditionFailure("Failed to read MapTiler key from info.plist")
        }
        let result: ComparisonResult = mapTilerKey!.compare("placeholder", options: NSString.CompareOptions.caseInsensitive, range: nil, locale: nil)
        if result == .orderedSame {
            preconditionFailure("Please enter correct MapTiler key in info.plist[MapTilerKey] property")
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
