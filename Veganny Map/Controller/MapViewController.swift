//
//  ViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/28.
//

import UIKit
import GoogleMaps
import GooglePlaces
import GoogleMapsUtils
import CoreLocation

class MapViewController: UIViewController, GMSMapViewDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properies
    let manager = CLLocationManager()
//    var camera = GMSCameraPosition()
    var listResponse: ListResponse?
    var clusterManager: GMUClusterManager!
    // MARK: - TODO Set user location or Just show all of vegan
    var location = ""
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.delegate = self
        manager.requestWhenInUseAuthorization() // request user authorize
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
//        camera = GMSCameraPosition.camera(withLatitude: 25.038, longitude: 121.532, zoom: 6.0)
//        mapView.camera = camera
        //        print("License:\(GMSServices.openSourceLicenseInfo())") 
        
        
        // 生成 Cluster Manager
        let iconGenerator = GMUDefaultClusterIconGenerator.init(buckets: [99999], backgroundColors: [UIColor.green])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setMapDelegate(self) // Register self to listen to GMSMapViewDelegate events.
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleMapListController.shared.fetchNearbySearch(location: location, keyword: "vegan") { listresponse in
            self.listResponse = listresponse
            print("==>位置有沒有吃到\(self.location)")
            print("==>\(listresponse)")
            listresponse?.results.forEach({ result in
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: result.geometry.location.lat,
                    longitude: result.geometry.location.lng
                )
                marker.snippet = result.name
                marker.icon = GMSMarker.markerImage(with: .green)
                self.clusterManager.add(marker)
                self.clusterManager.cluster()
                marker.map = self.mapView
            })
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[0] as CLLocation
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 15)
            manager.stopUpdatingLocation()
            
            print("目前位置為\n經度為\(location.coordinate.longitude)\n緯度為\(location.coordinate.latitude)")
            self.location = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
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

// MARK: - GMUClusterManagerDelegate
extension MapViewController: GMUClusterManagerDelegate {
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      // center the map on tapped marker
      mapView.animate(toLocation: marker.position)
      // check if a cluster icon was tapped
      if marker.userData is GMUCluster {
        // zoom in on tapped cluster
        mapView.animate(toZoom: mapView.camera.zoom + 1)
        print("Did tap cluster")
        return true
      }

        print("Did tap a normal marker")
      return false
    }
}


