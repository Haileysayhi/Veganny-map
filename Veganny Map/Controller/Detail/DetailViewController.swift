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
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
           
    }
}


// MARK: - UITableViewDelegate & UITableViewDataSource
extension DetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "PhotoTableViewCell",
            for: indexPath) as? PhotoTableViewCell else { fatalError("Could not create Cell") }
        
        return cell
    }
    
}
