//
//  PhotoTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/3.
//

import UIKit

class PhotoTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.collectionViewLayout = generateLayout()
        }
    }
    
    // MARK: - Properties
    var photos: [PhotosResults] = []
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Function
    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [unowned self] sectionIndex, environment in
            return self.photoSection
        }
    }
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoCollectionViewCell",
            for: indexPath) as? PhotoCollectionViewCell
        else { fatalError("Could not create Cell.") }
        
        cell.photoIngView.image = nil
        GoogleMapListController.shared.fetchPhotos(
            photoReference: photos[indexPath.row].photoReference) {
                image in DispatchQueue.main.async {
                    cell.photoIngView.image = image
                    cell.photoIngView.contentMode = .scaleAspectFill
                }
            }
        return cell
    }
    
    // MARK: - Compositional Layout
    var photoSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
}
