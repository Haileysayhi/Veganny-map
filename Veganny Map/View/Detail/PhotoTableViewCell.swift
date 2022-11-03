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

    var simpsonsFamily = ["河馬", "霸子", "美枝", "花枝", "奶嘴"]
    
    
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
        simpsonsFamily.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "PhotoCollectionViewCell",
            for: indexPath) as? PhotoCollectionViewCell
        else { fatalError("Could not create Cell.") }
        
        cell.photoIngView.image = UIImage(named: simpsonsFamily[indexPath.item])
        
        return cell
    }
    
    // MARK: - Compositional Layout
    var photoSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1100), heightDimension: .absolute(170))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return section
    }
}
