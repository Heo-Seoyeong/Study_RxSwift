import UIKit

import RxSwift
import SnapKit

class MainViewController: BaseViewController {
  
  // MARK: Variable
  
  private let images = Variable<[UIImage]>([])
  
  
  // MARK: Properties
  
  private let previewImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.layer.cornerRadius = 5.0
    imageView.layer.borderColor = UIColor.black.cgColor
    imageView.layer.borderWidth = 1.0
    return imageView
  }()
  
  private let clearButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.green
    button.setTitle("Clear", for: .normal)
    return button
  }()
  
  private let saveButton: UIButton = {
    let button = UIButton()
    button.backgroundColor = UIColor.blue
    button.setTitle("Save", for: .normal)
    return button
  }()
  
  private let addButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: nil, action: nil)
  
  
  // MARK: View Life Cycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.backgroundColor = .white
    self.title = "Combinestagram"
    self.navigationItem.rightBarButtonItem = self.addButtonItem
    
    self.view.addSubview(self.previewImageView)
    self.view.addSubview(self.clearButton)
    self.view.addSubview(self.saveButton)
    
    self.addButtonItem.target = self
    self.addButtonItem.action = #selector(addButtonDidTap(_:))
    self.clearButton.addTarget(self, action: #selector(clearButtonDidTap(_:)), for: .touchUpInside)
    self.saveButton.addTarget(self, action: #selector(saveButtonDidTap(_:)), for: .touchUpInside)
    
    self.bind()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    print("resources: \(RxSwift.Resources.total)")
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    
    self.previewImageView.snp.makeConstraints { (make) in
      make.leading.equalToSuperview().offset(16.0)
      make.trailing.equalToSuperview().offset(-16.0)
      make.height.equalTo(210.0)
      make.centerY.equalToSuperview().multipliedBy(0.75)
    }
    
    self.clearButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(80.0)
      make.centerY.equalToSuperview().multipliedBy(1.5)
      make.centerX.equalToSuperview().multipliedBy(0.5)
    }
    
    self.saveButton.snp.makeConstraints { (make) in
      make.width.height.equalTo(80.0)
      make.centerY.equalToSuperview().multipliedBy(1.5)
      make.centerX.equalToSuperview().multipliedBy(1.5)
    }
  }
  
  
  // MARK: Bind
  
  private func bind() {
    self.images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        guard let `self` = self else { return }
        self.previewImageView.image = UIImage.collage(images: photos, size: self.previewImageView.frame.size)
      })
      .disposed(by: disposeBag)
    
    self.images.asObservable()
      .subscribe(onNext: { [weak self] photos in
        guard let `self` = self else { return }
        self.updateUI(photos: photos)
      })
      .disposed(by: disposeBag)
  }
  
  
  // MARK: Action
  
  @objc private func addButtonDidTap(_ sender: UIBarButtonItem) {
    let photosVC = PhotosViewController()

    photosVC.selectedPhotos
      .subscribe(onNext: { [weak self] newImage in
        guard let `self` = self else { return }
        self.images.value.append(newImage)
        }, onDisposed: {
          print("completed photo selection")
      })
      .disposed(by: photosVC.disposeBag)
    
    self.navigationController?.pushViewController(photosVC, animated: true)
  }
  
  @objc private func clearButtonDidTap(_ sender: UIButton) {
    self.images.value = []
  }
  
  @objc private func saveButtonDidTap(_ sender: UIButton) {
    guard let image = previewImageView.image else { return }
    
    PhotoWriter.save(image)
      .subscribe(onError: { [weak self] error in
        guard let `self` = self else { return }
        self.showMessage("Error", description: error.localizedDescription)
        }, onCompleted: { [weak self] in
          guard let `self` = self else { return }
          self.showMessage("Saved")
          self.images.value = []
        })
      .disposed(by: disposeBag)
  }
  
  private func updateUI(photos: [UIImage]) {
    self.saveButton.isEnabled = photos.count > 0 && photos.count % 2 == 0
    self.clearButton.isEnabled = photos.count > 0
    self.addButtonItem.isEnabled = photos.count < 6
    self.title = photos.count > 0 ? "\(photos.count) photos" : "Collage"
  }
  
  func showMessage(_ title: String, description: String? = nil) {
    showAlert(title: title, description: description)
      .subscribe()
      .disposed(by: disposeBag)
  }
  
}

import SwiftUI
struct MainViewControllerPreview: PreviewProvider {
  
  static var previews: some View {
    ContainerView()
  }
  
  struct ContainerView: UIViewControllerRepresentable {
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<MainViewControllerPreview.ContainerView>) -> UIViewController {
      return MainViewController()
    }
    
    func updateUIViewController(_ uIViewController: MainViewControllerPreview.ContainerView.UIViewControllerType, context: UIViewControllerRepresentableContext<MainViewControllerPreview.ContainerView>) {
    }
  }
  
}
