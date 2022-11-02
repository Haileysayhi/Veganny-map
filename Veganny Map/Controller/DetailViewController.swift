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
    
    // MARK: - Properties
    var itemResults: [ItemResult] = [] {
        didSet {
            print("===>DetailViewController拿到的資料\(itemResults)")
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView?.delegate = self
        tableView?.dataSource = self
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        itemResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "DeatilTableViewCell",
            for: indexPath) as? DeatilTableViewCell else { fatalError("Could not create Cell") }
        cell.layoutCell(result: itemResults[indexPath.row])
        return cell
    }
}
