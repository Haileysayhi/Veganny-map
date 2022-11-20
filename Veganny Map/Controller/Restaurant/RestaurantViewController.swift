//
//  RestaurantViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/1.
//

import UIKit

class RestaurantViewController: UIViewController, MapViewControllerDelegate {
    
    func manager(_ mapVC: MapViewController, didGet restaurants: [ItemResult]) {
        self.itemResults = restaurants
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView?.delegate = self
            tableView?.dataSource = self
        }
    }
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var itemResults: [ItemResult] = [] {
        didSet {
            print("===>RestaurantViewController拿到的資料\(itemResults)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    var searching = false
    var searchedRestaurants = [ItemResult]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension RestaurantViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedRestaurants.count
        } else {
            return itemResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "RestaurantTableViewCell",
            for: indexPath) as? RestaurantTableViewCell else { fatalError("Could not create Cell") }
        
        cell.viewController = self
        if searching {
            cell.layoutCell(result: searchedRestaurants[indexPath.row])
        } else {
            cell.layoutCell(result: itemResults[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let rotationTransform = CATransform3DTranslate(CATransform3DIdentity, 0, 50, 0)
        cell.layer.transform = rotationTransform
        cell.alpha = 0
        UIView.animate(withDuration: 0.75) {
            cell.layer.transform = CATransform3DIdentity
            cell.alpha = 1.0
        }
    }
}

// MARK: - UISearchBarDelegate
extension RestaurantViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedRestaurants = itemResults.filter { $0.name.lowercased().prefix(searchText.count) == searchText.lowercased() }
        searching = true
        tableView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        searchBar.text = ""
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searching = false
        self.searchBar.endEditing(true)
    }
}
