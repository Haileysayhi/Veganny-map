//
//  ViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/10/28.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    
    //MARK: - IBOutlet
    @IBOutlet weak var mapView: MKMapView! {
        didSet {
            mapView.showsUserLocation = true
        }
    }
    @IBOutlet weak var userLocation: UIButton!
    
    //MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
//        mapView.delegate = self
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showUserLocation()
    }
    
    //MARK: - Function
    @IBAction func showUserLocation(_ sender: UIButton) {
        showUserLocation()
        
        //Show pin as user location
//        let pin = MKPointAnnotation()
//        pin.coordinate = location.coordinate
//        mapView.addAnnotation(pin)
    }
    
    func showUserLocation() {
        let location = mapView.userLocation
        let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 300, longitudinalMeters: 300)
        mapView.setRegion(region, animated: true)
    }
    
}

//extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        <#code#>
//    }
//}

