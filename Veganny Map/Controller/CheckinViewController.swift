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
    let listController = GoogleMapListController()
    var userLocation = UserDefaults.standard.object(forKey: "userLocation") as? String
    var name: ((String) -> ())? // 傳餐廳名字
    
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
        print("CheckinViewController ===\(self.userLocation)")
        getRestaurantData()
    }
    
    func getRestaurantData() {
        guard let userLocation = self.userLocation else { fatalError("ERROR")}
        GoogleMapListController.shared.fetchNearbySearch(location: userLocation, keyword: "restaurant") { listresponse in
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
        cell.nameLabel.text = listResponse?.results[indexPath.row].name
        cell.addressLabel.text = listResponse?.results[indexPath.row].vicinity
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        name?((listResponse?.results[indexPath.row].name)!)
        self.dismiss(animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension CheckinViewController: UISearchBarDelegate {
    
    // 搜尋文字改變時會觸發
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            getRestaurantData()
        } else {
            guard let userLocation = self.userLocation else { fatalError("ERROR")}
            GoogleMapListController.shared.fetchNearbySearch(location: userLocation, keyword: searchText) { listresponse in
                self.listResponse = listresponse
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    // 點擊search後會觸發
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 收鍵盤
        searchBar.resignFirstResponder()
    }
}
