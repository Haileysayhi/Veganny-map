//
//  SaveViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/10.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift

class SaveViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var saveCountLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.layer.cornerRadius = 20
            searchBar.clipsToBounds = true
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            tableView.addRefreshHeader(refreshingBlock: { [weak self] in
                self?.getPlaceIdData()
            })
        }
    }
    
    // MARK: - Properties
    let dataBase = Firestore.firestore()
    var user: User?
    var detail = [DetailResponse]()
    var searching = false
    var searchedSave = [DetailResponse]()
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = .systemOrange
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPlaceIdData()
    }
    
    // MARK: - Function
    func getPlaceIdData() {
        dataBase.collection("User").document(getUserID()).getDocument(as: User.self) { result in
            switch result {
            case .success(let user):
                self.user = user
                self.fetchPlaceId()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func fetchPlaceId() {
        guard let user = user else { return }
        self.detail = [] // 清空資料，從其他頁面跳回來時不會重複取資料
        for placeId in user.savedRestaurants {
            GoogleMapListController.shared.fetchPlaceDetail(placeId: placeId) { detailResponse in
                guard let detailResponse = detailResponse else { return }
                self.detail.append(detailResponse)
                print("===SaveViewController資料2:\(self.detail)")
                DispatchQueue.main.async {
                    self.tableView.endHeaderRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension SaveViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchedSave.count
        } else {
            return  detail.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SaveTableViewCell", for: indexPath) as? SaveTableViewCell
        else { fatalError("Could not creat Cell.") }
        
        cell.photoImgView.image = nil
        
        if searching {
            GoogleMapListController.shared.fetchPhotos(photoReference: searchedSave[indexPath.row].result.photos[indexPath.row].photoReference) { image in
                DispatchQueue.main.async {
                    cell.nameLabel.text = self.searchedSave[indexPath.row].result.name
                    cell.addressLabel.text = self.searchedSave[indexPath.row].result.formattedAddress
                    cell.photoImgView.image = image
                    cell.photoImgView.layer.cornerRadius = 5
                    self.saveCountLabel.text = "You have saved \(self.detail.count) locations"
                }
            }
        } else {
            GoogleMapListController.shared.fetchPhotos(photoReference: detail[indexPath.row].result.photos[indexPath.row].photoReference) { image in
                DispatchQueue.main.async {
                    cell.nameLabel.text = self.detail[indexPath.row].result.name
                    cell.addressLabel.text = self.detail[indexPath.row].result.formattedAddress
                    cell.photoImgView.image = image
                    cell.photoImgView.layer.cornerRadius = 5
                    self.saveCountLabel.text = "You have saved \(self.detail.count) locations"
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableVC = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else { return }
        tableVC.infoResult = self.detail[indexPath.row].result
        navigationController?.pushViewController(tableVC, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension SaveViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchedSave = detail.filter { $0.result.name.lowercased().prefix(searchText.count) == searchText.lowercased() }
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
