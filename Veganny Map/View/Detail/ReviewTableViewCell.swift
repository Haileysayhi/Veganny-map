//
//  ReviewTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit

class ReviewTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.collectionViewLayout = generateLayout()
        }
    }
    
    // MARK: - Properties
    var reviews: [Reviews] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    var dateFormatter = DateFormatter()
    weak var viewController: UIViewController?
    
    // MARK: - Function
    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [unowned self] sectionIndex, environment in
            return self.photoSection
        }
    }
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "ReviewCollectionViewCell",
            for: indexPath) as? ReviewCollectionViewCell
        else { fatalError("Could not create Cell.") }
        
        
        GoogleMapListController.shared.getPhoto(url: reviews[indexPath.row].profilePhotoURL) { image in
            DispatchQueue.main.async {
                cell.profileImgView.image = image
            }
        }
        
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        cell.dateLabel.text = dateFormatter.string(from: reviews[indexPath.row].time)
        cell.nameLabel.text = reviews[indexPath.row].authorName
        cell.contentLabel.text = reviews[indexPath.row].text
        cell.updateStar(rate: reviews[indexPath.row].rating)
                
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil) // 去UIStoryboard中
        guard let vc = mainStoryBoard.instantiateViewController(withIdentifier: "ReviewDetailViewController") as? ReviewDetailViewController else { return }
        vc.review = self.reviews[indexPath.item]
        viewController?.present(vc, animated: true)
    }
    
    // MARK: - Compositional Layout
    var photoSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(150))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.7), heightDimension: .absolute(150))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}
