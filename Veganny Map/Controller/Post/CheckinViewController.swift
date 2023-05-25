//
//  CheckinViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/18.
//

import UIKit
import CoreLocation

class CheckinViewController: UIViewController, CLLocationManagerDelegate {
    
    
    // MARK: - Properties
    var listResponse: ListResponse?
    let listController = GoogleMapService()
    var userLocation = UserDefaults.standard.object(forKey: "userLocation") as? String
    var name: ((String) -> ())? // 傳餐廳名字
    var placeId: ((String) -> ())? // 傳餐廳id

    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var listSearchBar: UISearchBar!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Locations"
        listSearchBar.delegate = self
        getRestaurantData()
    }
    
    func getRestaurantData() {
        guard let userLocation = self.userLocation else { fatalError("ERROR")}
        GoogleMapService.shared.fetchNearbySearch(location: userLocation, keyword: "restaurant", radius: 30000) { listresponse in
            self.listResponse = listresponse
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension CheckinViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listResponse?.results.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CheckinTableViewCell", for: indexPath) as? CheckinTableViewCell
        else { fatalError("Could not creat Cell.")}
        guard let listResponse = self.listResponse else { fatalError("ERROR")}
        cell.layoutCell(
            name: listResponse.results[indexPath.row].name,
            address: listResponse.results[indexPath.row].vicinity
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        name?((listResponse?.results[indexPath.row].name)!)
        placeId?((listResponse?.results[indexPath.row].placeId)!)
        self.dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension CheckinViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            getRestaurantData()
        } else {
            guard let userLocation = self.userLocation else { fatalError("ERROR")}
            GoogleMapService.shared.fetchNearbySearch(location: userLocation, keyword: searchText, radius: 30000) { listresponse in
                self.listResponse = listresponse
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 收鍵盤
        searchBar.resignFirstResponder()
    }
}
