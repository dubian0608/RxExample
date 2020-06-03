//
//  SIgnDriverViewController.swift
//  SignupRxSwift
//
//  Created by 张骥 on 2020/4/26.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SIgnDriverViewController: UIViewController {
    @IBOutlet weak var usernameOutlet: UITextField!
    @IBOutlet weak var usernameValidationOutlet: UILabel!
    
    @IBOutlet weak var passwordOutlet: UITextField!
    @IBOutlet weak var passwordValidationOutlet: UILabel!
    
    @IBOutlet weak var repeatedPasswordOutlet: UITextField!
    @IBOutlet weak var repeatedPasswordValidationOutlet: UILabel!
    
    @IBOutlet weak var signupOutlet: UIButton!
    @IBOutlet weak var signingUpOulet: UIActivityIndicatorView!
    
    var disposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.disposeBag = DisposeBag()
        
        let viewModel = GithubSignupDriverViewModel(
            input: (
                username: usernameOutlet.rx.text.orEmpty.asDriver(),
                password: passwordOutlet.rx.text.orEmpty.asDriver(),
                repeatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asDriver(),
                loginTap: signupOutlet.rx.tap.asSignal()
            ),
            dependency: (
                API: GitHubDefaultAPI.shareAPI,
                validationService: GitHubDefaultValidationService.shartValidationSsrvice,
                wrieframw: DefaultWireframe.shared
            )
        )
        
        viewModel.signupEnabled
            .drive(onNext: { [weak self] valid in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.validatedUsername
            .drive(usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .drive(passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPasswordRepeated
            .drive(repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .drive(signingUpOulet.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .drive(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
    }
}
