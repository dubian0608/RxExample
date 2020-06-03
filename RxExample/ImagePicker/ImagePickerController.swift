//
//  ImagePickerController.swift
//  RxExample
//
//  Created by 张骥 on 2020/6/3.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ImagePickerController: UIViewController {
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var cameraButton: UIButton!
    @IBOutlet var galleryButton: UIButton!
    @IBOutlet var cropButton: UIButton!
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cameraButton.rx.tap
            .flatMapLatest { [weak self] (_)  in
                // 点击 -> 创建UIImagePicker   异步
                return UIImagePickerController.rx.createWithParent(self) { picker in
                    picker.sourceType = .camera
                    picker.allowsEditing = false
                }
                    .flatMap { $0.rx.didFinishPickingMediaWithInfo }         // 点击获取图片信息
                    .take(1)
        }
        .map { info in
            // 图片信息 -> UIImage    同步
            return info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        }
        .bind(to: imageView.rx.image)    // 图片绑定imageView
        .disposed(by: disposeBag)
        
        galleryButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self, animated: true) { (picker) in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = false
                }.flatMap { (picker)  in
                    picker.rx.didFinishPickingMediaWithInfo
                }.take(1)
        }
        .map { info in
            return info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage
        }
        .bind(to: imageView.rx.image)
        .disposed(by: disposeBag)
        
        cropButton.rx.tap
            .flatMapLatest { [weak self] _ in
                return UIImagePickerController.rx.createWithParent(self, animated: true) { picker in
                    picker.sourceType = .photoLibrary
                    picker.allowsEditing = true
                }.flatMapLatest { (picker) in
                    picker.rx.didFinishPickingMediaWithInfo
                }.take(1)
        }
        .map{ info in
            return info[UIImagePickerController.InfoKey.editedImage.rawValue] as? UIImage
        }
        .bind(to: imageView.rx.image)
        .disposed(by: disposeBag)
        
        
    }
    
}
