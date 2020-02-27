import RxSwift

class PhotoWriter: NSObject {

  typealias Callback = (NSError?) -> Void

  private var callback: Callback
  private init(callback: @escaping Callback) {
    self.callback = callback
  }
  
  @objc private func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
    callback(error)
  }

  static func save(_ image: UIImage) -> Observable<Void> {
    return Observable.create { (observer) -> Disposable in
      let writer = PhotoWriter { (error) in
        if let error = error {
          observer.onError(error)
        } else {
          observer.onCompleted()
        }
      }
      UIImageWriteToSavedPhotosAlbum(image, writer, #selector(PhotoWriter.image(_:didFinishSavingWithError:contextInfo:)), nil)

      return Disposables.create()
    }
  }
  
}
