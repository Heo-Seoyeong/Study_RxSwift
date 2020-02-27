
import UIKit

import RxSwift

class BaseCollectionViewCell: UICollectionViewCell {

  // MARK: Initializing
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.initialize()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func initialize() {
    // Override point
  }

}
