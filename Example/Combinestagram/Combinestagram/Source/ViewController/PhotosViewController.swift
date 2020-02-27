import UIKit
import Photos

import RxSwift
import SnapKit

class PhotosViewController: BaseViewController {
  
  // MARK: Properties
  
  private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
  
  private lazy var photos = PhotosViewController.loadPhotos()
  private lazy var imageManager = PHCachingImageManager()
  
  private lazy var thumbnailSize: CGSize = {
    let cellSize = CGSize(width: 80.0, height: 80.0)
    return CGSize(width: cellSize.width * UIScreen.main.scale,
                  height: cellSize.height * UIScreen.main.scale)
  }()
  
  fileprivate let selectedPhotosSubject = PublishSubject<UIImage>()
  
  var selectedPhotos: Observable<UIImage> {
    return selectedPhotosSubject.asObservable()
  }
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    self.title = "Add Photos"
    
    self.view.addSubview(self.collectionView)
    
    self.collectionView.delegate = self
    self.collectionView.dataSource = self
    self.collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "PhotoCell")
    self.collectionView.backgroundColor = .white
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)

    self.selectedPhotosSubject.onCompleted()
  }

  override func setupConstraints() {
    super.setupConstraints()
    
    self.collectionView.snp.makeConstraints { (make) in
      make.edges.equalTo(0)
    }
  }
  
  
  // MARK: Photo
  
  static func loadPhotos() -> PHFetchResult<PHAsset> {
    let allPhotosOptions = PHFetchOptions()
    allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    return PHAsset.fetchAssets(with: allPhotosOptions)
  }
  
}

// MARK: CollectionView Delegate

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return photos.count
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 80.0, height: 80.0)
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let asset = photos.object(at: indexPath.item)
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath)
    if let cell = cell as? PhotoCell {
      cell.representedAssetIdentifier = asset.localIdentifier
      imageManager.requestImage(for: asset,
                                targetSize: thumbnailSize,
                                contentMode: .aspectFill,
                                options: nil,
                                resultHandler: { image, _ in
                                  if cell.representedAssetIdentifier == asset.localIdentifier {
                                    cell.set(by: image)
                                  }
      })
    }
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = photos.object(at: indexPath.item)
    
    if let cell = collectionView.cellForItem(at: indexPath) as? PhotoCell {
      cell.flash()
    }
    
    imageManager.requestImage(for: asset,
                              targetSize: view.frame.size,
                              contentMode: .aspectFill,
                              options: nil,
                              resultHandler: { [weak self] image, info in
                                guard let `self` = self, let image = image, let info = info else { return }
                                if let isThumbnail = info[PHImageResultIsDegradedKey as NSString] as? Bool, !isThumbnail {
                                  self.selectedPhotosSubject.onNext(image)
                                }
    })
  }
  
}


import SwiftUI
struct PhotosViewControllerPreview: PreviewProvider {
  
  static var previews: some View {
    ContainerView()
  }
  
  struct ContainerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<PhotosViewControllerPreview.ContainerView>) -> UIViewController {
      return PhotosViewController()
    }
    
    func updateUIViewController(_ uIViewController: PhotosViewControllerPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<PhotosViewControllerPreview.ContainerView>) {
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 16.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 16.0
  }
  
}
