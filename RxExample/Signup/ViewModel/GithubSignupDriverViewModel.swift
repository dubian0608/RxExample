//
//  GithubSignupDriverViewModel.swift
//  SignupRxSwift
//
//  Created by 张骥 on 2020/4/26.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import RxCocoa
import RxSwift

class GithubSignupDriverViewModel {
    // outputs {
    
    //
    let validatedUsername: Driver<VallidationResult>
    let validatedPassword: Driver<VallidationResult>
    let validatedPasswordRepeated: Driver<VallidationResult>
    
    // Is signup button enabled
    let signupEnabled: Driver<Bool>
    
    // Has user signed in
    let signedIn: Driver<Bool>
    
    // Is signing process in progress
    let signingIn: Driver<Bool>
    
    // }
    
    init(
        input:(
        username: Driver<String>,
        password: Driver<String>,
        repeatedPassword: Driver<String>,
        loginTap: Signal<()>
        ),
        dependency: (
        API: GitHubAPI,
        validationService: GitHubValidationService,
        wrieframw: Wireframe
        )
    ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wirframe = dependency.wrieframw
        
        validatedUsername = input.username
            .flatMapFirst { username in
                return validationService.validateUsername(username)
                    .asDriver(onErrorJustReturn: .failed(message: "Error contacting server"))
        }
        
        validatedPassword = input.password
            .map { password in
                return validationService.validatePassword(password)
        }
        
        validatedPasswordRepeated = Driver.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
        
        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asDriver()
        
        let userAndPassword = Driver.combineLatest(input.username, input.password) {
            return (username: $0, password: $1)
        }
        
        signedIn = input.loginTap.withLatestFrom(userAndPassword)
            .flatMapLatest { pair in
                return API.signup(pair.username, password: pair.password)
                    .trackActivity(signingIn)
                    .asDriver(onErrorJustReturn: false)
        }
        .flatMapLatest { loggedIn -> Driver<Bool> in
            let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
            return wirframe.promptFor(message, cancelAction: "OK", actions: [])
                .map { _ in
                    loggedIn
            }
            .asDriver(onErrorJustReturn: false)
        }
        
        signupEnabled = Driver.combineLatest(
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated,
            signingIn) { username, password, repeatedPassword, signingIn in
                username.isValid &&
                password.isValid &&
                repeatedPassword.isValid &&
                !signingIn
        }
    }
}
