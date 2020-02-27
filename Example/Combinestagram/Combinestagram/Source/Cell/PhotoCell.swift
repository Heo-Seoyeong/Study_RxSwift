import UIKit

class PhotoCell: BaseCollectionViewCell {
  
  // MARK: Properties
  
  private let imageView = UIImageView()
  
  var representedAssetIdentifier: String?
  
  
  // MARK: Initializing
  
  override func initialize() {
    self.contentView.addSubview(self.imageView)
  }
  
  
  // MARK: Layout
  
  override func layoutSubviews() {
    self.imageView.snp.makeConstraints { (make) in
      make.edges.equalTo(0.0)
    }
  }
  
  func set(by image: UIImage?) {
    self.imageView.image = image
  }
  
  func flash() {
    imageView.alpha = 0
    setNeedsDisplay()
    UIView.animate(withDuration: 0.5, animations: { [weak self] in
      self?.imageView.alpha = 1
    })
  }
  
}
