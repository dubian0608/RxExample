//
//  SIgnViewController.swift
//  SignupRxSwift
//
//  Created by 张骥 on 2020/4/26.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import UIKit
import RxSwift

class SIgnViewController: UIViewController {
    
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
        
        // init view model
        let viewModel = GithubSignupViewModel(
            input: (
                // view 的操作 update view model
                username: usernameOutlet.rx.text.orEmpty.asObservable(),
                password: passwordOutlet.rx.text.orEmpty.asObservable(),
                repatedPassword: repeatedPasswordOutlet.rx.text.orEmpty.asObservable(),
                loginTaps: signupOutlet.rx.tap.asObservable()),
            dependency: (
                API: GitHubDefaultAPI.shareAPI,
                validationService: GitHubDefaultValidationService.shartValidationSsrvice,
                wireframe: DefaultWireframe.shared))
        
        
        // 绑定 view model 结果 update UI
        viewModel.signupEnabled
            .subscribe(onNext: { [weak self] valid in
                self?.signupOutlet.isEnabled = valid
                self?.signupOutlet.alpha = valid ? 1.0 : 0.5
            })
            .disposed(by: disposeBag)
        
        viewModel.validatedUsername
            .bind(to: usernameValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPassword
            .bind(to: passwordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.validatedPasswordRepeated
            .bind(to: repeatedPasswordValidationOutlet.rx.validationResult)
            .disposed(by: disposeBag)
        
        viewModel.signingIn
            .bind(to: signingUpOulet.rx.isAnimating)
            .disposed(by: disposeBag)
        
        viewModel.signedIn
            .subscribe(onNext: { signedIn in
                print("User signed in \(signedIn)")
            })
            .disposed(by: disposeBag)
    }
    
}
