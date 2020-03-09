//
//  ExploreViewController.swift
//  Flickry
//
//  Created by Mersad Ewaz Zadeh on 07.03.20.
//  Copyright © 2020 Mersad Ewaz Zadeh. All rights reserved.
//

import UIKit
import SDWebImage
import Lottie

class ExploreViewController: UIViewController {

    @IBOutlet weak var exploreCollectionView: UICollectionView!
    var animationView: AnimationView!
    var refreshControl: UIRefreshControl!

    var photoContainer: FlickrPhotoContainer?
    let placeHolderImage = UIImage(named: "placeHolder")
    var numberOfColumns: CGFloat = 1

    override func viewDidLoad() {
        super.viewDidLoad()

        exploreCollectionView.dataSource = self
        exploreCollectionView.delegate = self

        if UIDevice.current.userInterfaceIdiom == .pad {
            numberOfColumns = 2
        }

        setup()
        loadPhotoContainer()

    }

    func setup() {

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(loadPhotoContainer), for: .valueChanged)
        exploreCollectionView.addSubview(refreshControl)

        animationView = AnimationView()
        let animation = Animation.named("ExploreAnim")
        animationView.animation = animation
        animationView.loopMode = .autoReverse
        animationView.animationSpeed = 0.8

        if #available(iOS 13, *) {
            animationView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.98)
        } else {
            animationView.backgroundColor = .white
        }
        view.addSubview(animationView)

        setupConstraints()
    }

    func setupConstraints() {
        animationView.translatesAutoresizingMaskIntoConstraints = false
        animationView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor).isActive = true
        animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true

        animationView.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor).isActive = true
        animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        animationView.setContentCompressionResistancePriority(.fittingSizeLevel, for: .horizontal)
    }

    @objc func loadPhotoContainer() {
        animationView.isHidden = false
        animationView.play()
        FlickrDataService.shared.fetchPhotoContainer(using: .interestingness, additionalQueryParam: nil) { (result) in
            switch result {
            case .success(let container):
                self.photoContainer = container
                DispatchQueue.main.async {
                    self.exploreCollectionView.reloadData()
                    self.showToast("Loading completed", delay: UIViewController.DELAY_SHORT)
                }

            case .failure(let error):
                self.showToast(error.localizedDescription)
            }
            DispatchQueue.main.async {
                self.animationView.isHidden = true
                self.animationView.stop()
                if self.refreshControl.isRefreshing {
                    self.refreshControl.endRefreshing()
                }
            }

        }
    }
}

extension ExploreViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoContainer?.photoAlbum.photos.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreReuseCell", for: indexPath)
        let item = photoContainer?.photoAlbum.photos[indexPath.item]
        let imageURL = item?.imageURL(size: .large)

        if let exploreCell = cell as? ExploreCollectionViewCell {
            exploreCell.titleLable.text = item?.title
            exploreCell.imageView
                .sd_setImage(with: imageURL, placeholderImage: placeHolderImage, options: .scaleDownLargeImages, context: nil, progress: nil) { (uiImage, downloadException, _, _) in //context: [.imageTransformer: transformer as Any]
                    //

                    if let downloadException = downloadException {
                        print("Image downloading error : \(downloadException.localizedDescription)")
                    }
                    if let uiImage = uiImage {

                        let width = exploreCell.frame.width
                        let ratio = CGFloat(item?.imageSizeRatio ?? 1)
                        let height = width * ratio
                        exploreCell.imageView.image = uiImage.sd_resizedImage(with: CGSize(width: width, height: height), scaleMode: .fill)
                    }
            }

            return exploreCell
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "ExploreSectionHeader", for: indexPath)
        return sectionHeader
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        guard previousTraitCollection != nil else {
            return
        }
        exploreCollectionView.collectionViewLayout.invalidateLayout()
    }
}

extension ExploreViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let collectionViewWidth = collectionView.bounds.width
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let spaceBetweenCells = (flowLayout?.minimumInteritemSpacing ?? 0) * (numberOfColumns - 1)
        let spaceToSides = (flowLayout?.sectionInset.right ?? 0) + (flowLayout?.sectionInset.left ?? 0)
        let adustedWidth = collectionViewWidth - spaceBetweenCells - spaceToSides
        let adjustedCellWidth: CGFloat = floor(adustedWidth / numberOfColumns)

        let item = photoContainer?.photoAlbum.photos[indexPath.item]
        let imageSizeRatio = CGFloat(item?.imageSizeRatio ?? 1)
        let adjustedCellHeight: CGFloat = floor((adjustedCellWidth * imageSizeRatio) + 60)

        return CGSize(width: adjustedCellWidth, height: adjustedCellHeight)
    }

}
