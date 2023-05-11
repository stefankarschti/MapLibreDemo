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
    @Binding var bind_styleURL: String
    @State private var userLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    let locationDelegate = LocationDelegate()
    let boundingBox = MGLCoordinateBounds(sw: CLLocationCoordinate2D(latitude: 46.71620366032939, longitude: 23.39774008738669), ne: CLLocationCoordinate2D(latitude: 46.83472377112443, longitude: 23.74945969396266))
    
    func updateStyle(_ uiView: MGLMapView) {
        // read the key from property list
        let mapTilerKey = getMapTilerkey()
        validateKey(mapTilerKey)
        
        // Build the style url
        var style = bind_styleURL
        if style.isEmpty {
            style = "https://api.maptiler.com/maps/streets/style.json?key="
        }
        let styleURL = URL(string: style + "\(mapTilerKey)")
        if let unwrapped = styleURL {
            print("Style URL: \(unwrapped)")
        }
        // create the mapview
        uiView.styleURL = styleURL;
    }
    func makeUIView(context: Context) -> MGLMapView {
        // create the mapview
        let mapView = MGLMapView(frame: .zero, styleURL: MGLStyle.defaultStyleURL())
        updateStyle(mapView)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.logoView.isHidden = true
        mapView.showsUserLocation = true
        mapView.showsUserHeadingIndicator = true
        mapView.minimumZoomLevel = 13
        mapView.showsScale = true
        mapView.showsHeading = true
        mapView.setVisibleCoordinateBounds(boundingBox, animated: false)
        mapView.delegate = context.coordinator
        // location stuff
        locationManager.delegate = context.coordinator
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // annotations
        // Create point to represent where the symbol should be placed
        let point1 = MGLPointAnnotation()
        point1.coordinate = CLLocationCoordinate2D(latitude: 46.76952032174447, longitude: 23.589856130996207)
        point1.title = "Statue1"
        mapView.addAnnotation(point1)
        
        // 46.751701289159485, 23.5981339859047
        let point2 = MGLPointAnnotation()
        point2.coordinate = CLLocationCoordinate2D(latitude: 46.751701289159485, longitude: 23.5981339859047)
        point2.title = "Statue2"
        mapView.addAnnotation(point2)
        
        // route
        // Simulated route coordinates
        // 46.738353192398165, 23.591225526255162
        // 46.74183919270858, 23.591803144589015
        // 46.74663240854748, 23.59272754575663
        // 46.74944497193167, 23.593883518803718
        // 46.752534829576085, 23.595444307024266
        let routeCoordinates = [
            CLLocationCoordinate2D(latitude: 46.738353192398165, longitude: 23.591225526255162),
            CLLocationCoordinate2D(latitude: 46.74183919270858, longitude: 23.591803144589015),
            CLLocationCoordinate2D(latitude: 46.74663240854748, longitude: 23.59272754575663),
            CLLocationCoordinate2D(latitude: 46.74944497193167, longitude: 23.593883518803718),
            CLLocationCoordinate2D(latitude: 46.752534829576085, longitude: 23.595444307024266),
        ]

        // Create a polyline overlay for the route
        let polyline = MGLPolyline(coordinates: routeCoordinates, count: UInt(routeCoordinates.count))
        mapView.addAnnotation(polyline)

        return mapView
    }
    
    func updateUIView(_ uiView: MGLMapView, context: Context) {
        // style update
        updateStyle(uiView)
        
        // location update
        guard let location = self.userLocation else { return }
        uiView.setCenter(location, animated: true)
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
        
        func mapView(_ mapView: MGLMapView, shouldChangeFrom oldCamera: MGLMapCamera, to newCamera: MGLMapCamera) -> Bool {
            // Check if the new camera center is within the bounding box
            func contains(bbox: MGLCoordinateBounds, point: CLLocationCoordinate2D)-> Bool {
                return point.latitude >= bbox.sw.latitude && point.latitude <= bbox.ne.latitude && point.longitude >= bbox.sw.longitude && point.longitude <= bbox.ne.longitude
            }

            return contains(bbox: control.boundingBox, point: newCamera.centerCoordinate)
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last?.coordinate else { return }
            control.userLocation = location
        }

        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Location update failed with error: \(error.localizedDescription)")
        }
        
        func mapView(_ mapView: MGLMapView, imageFor annotation: MGLAnnotation) -> MGLAnnotationImage? {
            let image = UIImage(named: "myImage")!
            let annotationImage = MGLAnnotationImage(image: image, reuseIdentifier: "myImage")
            return annotationImage
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
    @State static var styleURL: String = ""
    static var previews: some View {
        MapView(bind_styleURL: $styleURL)
    }
}
