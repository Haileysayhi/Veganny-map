//
//  MapViewController.swift
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
    var moveLocation = ""
    weak var delegate: MapViewControllerDelegate!
    var fpc: FloatingPanelController!
    let geocoder = GMSGeocoder()
    let searchAreaButton = UIButton()
    var isStartCamara = true
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        showTableView()
        
        setupSearchButton(button: searchAreaButton)

        manager.delegate = self
        manager.requestWhenInUseAuthorization() // request user authorize
        manager.distanceFilter = kCLLocationAccuracyNearestTenMeters // update data after move ten meters
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        // 生成 Cluster Manager
        let iconGenerator = GMUDefaultClusterIconGenerator.init(buckets: [99999], backgroundColors: [UIColor(hexString: "FFA500", alpha: 1.0)])
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: mapView, clusterIconGenerator: iconGenerator)
        clusterManager = GMUClusterManager(map: mapView, algorithm: algorithm, renderer: renderer)
        clusterManager.setMapDelegate(self) // Register self to listen to GMSMapViewDelegate events.
    }
    
    // MARK: - viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getData()
    }
    
    // MARK: - Function
    func setupSearchButton(button: UIButton) {
        button.setTitle("search this area", for: .normal)
        button.tintColor = .white
        button.backgroundColor = .orange
        button.layer.cornerRadius = 5
        view.insertSubview(button, at: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 150),
            button.heightAnchor.constraint(equalToConstant: 35),
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30)
        ])
        button.isHidden = true
        button.addTarget(self, action: #selector(search), for: .touchUpInside)
    }
    
    @objc func search() {
        self.searchAreaButton.isHidden = true
        self.mapView.clear()
        GoogleMapListController.shared.fetchNearbySearch(location: self.moveLocation, keyword: "vegan", radius: 3000) { listresponse in
            self.listResponse = listresponse
            self.delegate.manager(self, didGet: listresponse!.results)
            listresponse?.results.forEach({ result in
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: result.geometry.location.lat,
                    longitude: result.geometry.location.lng
                )
                marker.snippet = result.name
                marker.icon = GMSMarker.markerImage(with: UIColor(hexString: "FFA500", alpha: 0.5))
                marker.accessibilityLabel = result.placeId // 儲存每個pin自己的id
                self.clusterManager.add(marker)
                self.clusterManager.cluster()
                marker.map = self.mapView
            })
        }
    }
    
    func getData() {
        GoogleMapListController.shared.fetchNearbySearch(location: self.userLocation, keyword: "vegan", radius: 3000) { listresponse in
            self.listResponse = listresponse
            print("==位置:\(self.userLocation)")
            print("==Listresponse:\(listresponse)")
            self.delegate.manager(self, didGet: listresponse!.results)
            listresponse?.results.forEach({ result in
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(
                    latitude: result.geometry.location.lat,
                    longitude: result.geometry.location.lng
                )
                
                marker.snippet = result.name
                marker.icon = GMSMarker.markerImage(with: UIColor(hexString: "FFA500", alpha: 0.5))
                marker.accessibilityLabel = result.placeId // 儲存每個pin自己的id
                self.clusterManager.add(marker)
                self.clusterManager.cluster()
                marker.map = self.mapView
            })
        }
    }
    
    
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
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if isStartCamara {
            self.searchAreaButton.isHidden = true
        } else {
            self.searchAreaButton.isHidden = false
            geocoder.reverseGeocodeCoordinate(position.target) { response, error in
                guard error == nil else {
                    return
                }
                
                if let result = response?.firstResult() {
                    self.moveLocation = "\(position.target.latitude),\(position.target.longitude)"
                }
            }
        }
        isStartCamara = false
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
            UserDefaults.standard.set(self.userLocation, forKey: "userLocation")
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
            return true
        } else {
            let placeId = marker.accessibilityLabel
            
            guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController,
                  let placeId = placeId
            else { fatalError("ERROR") }
            GoogleMapListController.shared.fetchPlaceDetail(placeId: placeId) { detailResponse in

                guard let detailResponse = detailResponse else { fatalError("ERROR") }
                tableVC.infoResult = detailResponse.result
                self.present(tableVC, animated: true)
            }
        }
        return false
    }
}
