//
//  CommentViewController.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/8.
//

import UIKit

class CommentViewController: UIViewController {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    
    
    @IBOutlet weak var textField: UITextField!
    
    
    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Function
    @IBAction func sendComment(_ sender: Any) {
        
        
        
    }
}





// MARK: - UITableViewDelegate & UITableViewDataSource
extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell", for: indexPath) as? CommentTableViewCell else { fatalError("Could not creat Cell.") }
        
        return cell
    }
    
    
}
