//
//  SearchViewController.swift
//  Flickry
//
//  Created by Mersad Ewaz Zadeh on 07.03.20.
//  Copyright © 2020 Mersad Ewaz Zadeh. All rights reserved.
//

import UIKit
import Lottie

class SearchViewController: UIViewController {

    @IBOutlet weak var searchCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    var animationView: AnimationView!
    var searchIdlAnimation: Animation!
    var searchingAnimation: Animation!

    var photoContainer: FlickrPhotoContainer?
    let placeHolderImage = UIImage(named: "placeHolder")
//    var numberOfColumns: CGFloat = 3

    override func viewDidLoad() {
        super.viewDidLoad()

        searchCollectionView.dataSource = self
//        searchCollectionView.delegate = self

        searchBar.delegate = self

        if let flowLayout = searchCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
          flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
        setup()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if photoContainer == nil {
            animationView.animation = searchIdlAnimation
            animationView.play()
        }
    }

    func setup() {
        animationView = AnimationView()
        searchIdlAnimation = Animation.named("SearchIdleAnim")
        searchingAnimation = Animation.named("SearchingAnim")
        animationView.loopMode = .autoReverse
        animationView.animation = searchIdlAnimation

        if #available(iOS 13, *) {
            animationView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        } else {
            animationView.backgroundColor = .white
        }

        view.addSubview(animationView)

        setupConstraints()
    }

    func setupConstraints() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: searchBar.layoutMarginsGuide.bottomAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
    }

    func loadPhotoContainer(searchParam: (String, String)) {

        FlickrDataService.shared.fetchPhotoContainer(using: .searchPhotos, additionalQueryParam: searchParam) { (result) in
            switch result {
            case .success(let container):
                self.photoContainer = container

                DispatchQueue.main.async {
                    self.searchCollectionView.reloadData()
                    self.animationView.stop()
                    self.animationView.isHidden = true
                }

            case .failure(let error):
                self.showToast(error.localizedDescription)
            }
        }
    }
}

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoContainer?.photoAlbum.photos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SearchReusabeCell", for: indexPath)
        let item = photoContainer?.photoAlbum.photos[indexPath.item]
        let imageURL = item?.imageURL(size: .medium)
        cell.backgroundColor = .blue
        
        if let searchReuseCell = cell as? SearchCollectionViewCell {
            searchReuseCell.imageView.sd_setImage(with: imageURL, placeholderImage: placeHolderImage, options: .scaleDownLargeImages, context: nil, progress: nil) { (_, downloadException, _, _) in
                if let downloadException = downloadException {
                    print("Image downloading error : \(downloadException.localizedDescription)")
                }
            }
            return searchReuseCell
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SearchReusabeHeader", for: indexPath)
        guard let header = view as? SearchHeaderCollectionReusableView else { return view }

        if let numberOfPhotos = photoContainer?.photoAlbum.photos.count {
            header.setup(text: "\(numberOfPhotos) Images Found")
            header.headerLable.isHidden = false
        } else {
            header.headerLable.isHidden = true
        }

        return header
    }

}

//extension SearchViewController: UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let collectionViewWidth = collectionView.bounds.width
//        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
//        let spaceBetweenCells = (flowLayout?.minimumInteritemSpacing ?? 0) * (numberOfColumns - 1)
//        let spaceToSides = (flowLayout?.sectionInset.right ?? 0) + (flowLayout?.sectionInset.left ?? 0)
//        let adustedWidth = collectionViewWidth - spaceBetweenCells - spaceToSides
//        let adjustedCellWidth: CGFloat = floor(adustedWidth / numberOfColumns)
//
//        let item = photoContainer?.photoAlbum.photos[indexPath.item]
//        let imageSizeRatio = CGFloat(item?.imageSizeRatio ?? 1)
//        let adjustedCellHeight: CGFloat = floor((adjustedCellWidth * imageSizeRatio))
//
//        return CGSize(width: adjustedCellWidth, height: adjustedCellHeight)
//    }
//
//}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchValue = searchBar.text {
            animationView.animation = searchingAnimation
            animationView.isHidden = false
            animationView.play()
            let searchParam = ("text", searchValue)
            loadPhotoContainer(searchParam: searchParam)
            searchBar.resignFirstResponder()
        }
    }

}
