//
//  DetailViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - IBOutlet
    @IBOutlet weak var tableView: UITableView!{
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
        }
    }
    
    // MARK: - Properties
    var infoResult: InfoResult?
    var itemResult: ItemResult?
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { // 如果第0個section 回傳兩個cell
            return 2
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 1 {
            return "Reviews"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = .black
            headerView.textLabel?.font = UIFont(name: "PingFangTC-Medium", size: 18)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "PhotoTableViewCell",
                for: indexPath) as? PhotoTableViewCell else { fatalError("Could not create Cell") }
            cell.photos = infoResult!.photos // 傳資料給 PhotoTableViewCell
            print("傳資料給 PhotoTableViewCell\(infoResult!.photos)")
            print("傳資料給 ReviewTableViewCell\(infoResult?.reviews)")

            return cell

        } else if indexPath.section == 0 && indexPath.row == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "InfoTableViewCell",
                for: indexPath) as? InfoTableViewCell,
                  let infoResult = infoResult
            else { fatalError("Could not create Cell") }
            
            cell.nameLabel.text = infoResult.name
            cell.addressLabel.text = itemResult?.vicinity
            cell.workHourLabel.text = infoResult.currentOpeningHours.weekdayText[indexPath.row]
            cell.phoneLabel.text = infoResult.internationalPhoneNumber
            cell.reviewsLabel.text = "\(infoResult.rating)"
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "ReviewTableViewCell",
                for: indexPath) as? ReviewTableViewCell else { fatalError("Could not create Cell") }
            cell.reviews = infoResult!.reviews // 傳資料給 ReviewTableViewCell
            
            print("真正的傳資料給 ReviewTableViewCell\(infoResult?.reviews)")

            return cell
        } else {
            fatalError("ERROR")
        }
    }
}
