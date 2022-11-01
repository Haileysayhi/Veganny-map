//
//  ViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/28.
//

import UIKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class MapViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properies
    let manager = CLLocationManager()
    var camera = GMSCameraPosition()
    var listResponse: ListResponse?
    // MARK: - TODO Set user location or Just show all of vegan
    var location = "25.038456876465034,121.53288929543649" // 座標預設為台北市
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // request user authorize
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        manager.desiredAccuracy = kCLLocationAccuracyBest
        // Create a GMSCameraPosition that tells the map to display the
        // coordinate -33.86,151.20 at zoom level 6.
        camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView.camera = camera
//        print("License:\(GMSServices.openSourceLicenseInfo())") // TODO
        
        GoogleMapListController.shared.fetchNearbySearch(location: location, keyword: "vegan") { listresponse in
            self.listResponse = listresponse
            print("==>\(listresponse)")
            listresponse?.results.forEach({ result in
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: result.geometry.location.lat, longitude: result.geometry.location.lng)
                marker.icon = GMSMarker.markerImage(with: .purple)
                marker.map = self.mapView
            })
        }
    }
}

// MARK: - extension
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[0] as CLLocation
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 15)
            manager.stopUpdatingLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Get user author
        switch status {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation() // Start location
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
        case .denied:
            let alertController = UIAlertController(
                title: "定位權限已關閉",
                message: "如要變更權限，請至 設定 > 隱私權 > 定位服務 開啟",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "確認", style: .default, handler: nil)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        default:
            break
        }
    }
}