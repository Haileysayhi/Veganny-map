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
import FloatingPanel

protocol MapViewControllerDelegate: AnyObject {
    func manager(_ mapVC: MapViewController, didGet restaurants: [ItemResult])
}

class MapViewController: UIViewController, GMSMapViewDelegate, FloatingPanelControllerDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var mapView: GMSMapView!
    
    // MARK: - Properies
    let manager = CLLocationManager()
    var listResponse: ListResponse?
    var clusterManager: GMUClusterManager!
    var userLocation = ""
    weak var delegate: MapViewControllerDelegate!
    var fpc: FloatingPanelController!
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        showTableView()

        manager.delegate = self
        manager.requestWhenInUseAuthorization() // request user authorize
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        //    生成 Cluster Manager
        let iconGenerator = GMUDefaultClusterIconGenerator.init(buckets: [99999], backgroundColors: [UIColor.green])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setMapDelegate(self) // Register self to listen to GMSMapViewDelegate events.
        
    }
    
    // MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        GoogleMapListController.shared.fetchNearbySearch(location: userLocation, keyword: "vegan") { listresponse in
            self.listResponse = listresponse
            print("==位置<MapViewController>有沒有吃到\(self.userLocation)")
            print("==<MapViewController>\(listresponse)")
            self.delegate.manager(self, didGet: listresponse!.results)
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
    
    
    // MARK: - Function
    func showTableView() {
        fpc = FloatingPanelController()
        fpc.delegate = self // Optional
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "RestaurantViewController") as?
        RestaurantViewController else { return }
        self.delegate = tableVC // 幫MapViewController做事的人是tableVC
        fpc.set(contentViewController: tableVC)
        fpc.track(scrollView: tableVC.tableView)
        fpc.addPanel(toParent: self)
    }
}

// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation: CLLocation = locations[0] as CLLocation
        if let location = locations.first {
            mapView.animate(toLocation: location.coordinate)
            mapView.animate(toZoom: 13)
            manager.stopUpdatingLocation()
            
            print("目前位置為\n經度為\(location.coordinate.longitude)\n緯度為\(location.coordinate.latitude)")
            self.userLocation = "\(location.coordinate.latitude),\(location.coordinate.longitude)"
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        // Get user author
        switch status {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation() // Start location
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.compassButton = true
            mapView.padding = UIEdgeInsets(top: 0, left: 0, bottom: 400, right: 0)
            
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