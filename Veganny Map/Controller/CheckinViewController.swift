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
    // 座標預設為台北市
    var location = "25.038456876465034,121.53288929543649"
    var listResponse: ListResponse?
    let listController = GoogleMapListController()
//    let loadingView = UIView()
//    let activityIndicator = UIActivityIndicatorView()
//    let loadingLabel = UILabel()
    
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
        title = "Location"
        listSearchBar.delegate = self
//        setActivityIndicatorView()
//        hideActivityIndicatorView()
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
        
        let item = listResponse?.results[indexPath.row]
        cell.updateCell(item: item)
        
        return cell
    }
}

// MARK: - ActivityIndicator

// extension CheckinViewController {
//
//    func setActivityIndicatorView() {
//
//        let width: CGFloat = 120
//        let height: CGFloat = 30
//        let x = (tableView.frame.width / 2) - (width / 2)
//        let y = (tableView.frame.height / 2) - (height / 2) - (navigationController?.navigationBar.frame.height)!
//        loadingView.frame = CGRect(x: x, y: y, width: width, height: height)
//
//        // Sets loading text
//        loadingLabel.textColor = .gray
//        loadingLabel.textAlignment = .center
//        loadingLabel.text = "Loading..."
//        loadingLabel.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
//
//        // Sets spinner
//        activityIndicator.style = .medium
//        activityIndicator.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        activityIndicator.startAnimating()
//
//        // Adds text and spinner to the view
//        loadingView.addSubview(loadingLabel)
//        loadingView.addSubview(activityIndicator)
//        tableView.addSubview(loadingView)
//    }
//
//    func showActivityIndicatorView() { loadingView.isHidden = false }
//
//    func hideActivityIndicatorView() { loadingView.isHidden = true }
// }

// MARK: - UISearchBarDelegate
extension CheckinViewController: UISearchBarDelegate {
    
    // 搜尋文字改變時會觸發
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String){
        // 搜尋時跳出loading
//        showActivityIndicatorView()
        
        GoogleMapListController.shared.fetchNearbySearch(location: location, keyword: searchText) { listresponse in // 寒舍艾美
            self.listResponse = listresponse

            DispatchQueue.main.async {
                self.tableView.reloadData()
                // 找到資料隱藏loading
//                self.hideActivityIndicatorView()
            }
        }
    }
    
    // 點擊search後會觸發
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar){
        // 收鍵盤
        searchBar.resignFirstResponder()
    }
}
