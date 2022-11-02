//
//  ViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/1.
//

import UIKit

class DetailViewController: UIViewController, MapViewControllerDelegate {
    
    func manager(_ mapVC: MapViewController, didGet restaurants: [ItemResult]) {
        self.itemResults = restaurants
    }
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // MARK: - Properties
    var itemResults: [ItemResult] = [] {
        didSet {
            print("===>DetailViewController拿到的資料\(itemResults)")
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
        tableView?.delegate = self
        tableView?.dataSource = self
        self.searchBar.delegate = self
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedRestaurants.count
        } else {
            return itemResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DeatilTableViewCell",
            for: indexPath) as? DeatilTableViewCell else { fatalError("Could not create Cell") }
        
        if searching {
            cell.layoutCell(result: searchedRestaurants[indexPath.row])
        } else {
            cell.layoutCell(result: itemResults[indexPath.row])
        }
        return cell
    }
}

// MARK: - UISearchBarDelegate
extension DetailViewController: UISearchBarDelegate {
    
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
}
