//
//  RestaurantTableViewCell.swift
//  Veganny Map
//
//  Created by Hailey on 2022/11/1.
//

import UIKit

//protocol RestaurantTableViewCellDelegate : AnyObject {
//    func presentVC(_ tableViewCell: RestaurantTableViewCell)
//}

class RestaurantTableViewCell: UITableViewCell, UICollectionViewDelegate, UICollectionViewDataSource {
    
    // MARK: - IBOutlet
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.collectionViewLayout = generateLayout()
        }
    }
    
    // MARK: - Properties
    var detail: DetailResponse?
//    weak var delegate: RestaurantTableViewCellDelegate?
    
    // MARK: - awakeFromNib
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Function
    func layoutCell(result: ItemResult) {
       let item = result.placeId
        GoogleMapListController.shared.fetchPlaceDetail(placeId: item) { detailResponse in
            self.detail = detailResponse
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    func generateLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [unowned self] sectionIndex, environment in
            return self.photoSection
        }
    }
    
    // MARK: - UICollectionViewDelegate & UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        detail?.result.photos.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "RestaurantCollectionViewCell",
            for: indexPath) as? RestaurantCollectionViewCell
        else { fatalError("Could not create Cell.") }
        
        cell.restaurantImgView.image = nil
        GoogleMapListController.shared.fetchPhotos(photoReference: detail?.result.photos[indexPath.row].photoReference ?? "") { image in
            DispatchQueue.main.async {
                cell.restaurantImgView.image = image
                cell.restaurantImgView.contentMode = .scaleAspectFill
                cell.restaurantImgView.layer.cornerRadius = 5
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: "HeaderView", for: indexPath) as?
                HeaderView else {fatalError("Could not create Header.") }
        
        headerView.header.text = detail?.result.name
        
        return headerView
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        self.delegate?.presentVC(self)
//    }
    
    // MARK: - Compositional Layout
    var photoSection: NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(100), heightDimension: .absolute(100))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(1100), heightDimension: .absolute(170))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        // 設定Header大小
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40))
        
        // 生成NSCollectionLayoutBoundarySupplementaryItem，Header內容靠右上對齊
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .topLeading)
        
        // 設定Section的boundarySupplementaryItems
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}
