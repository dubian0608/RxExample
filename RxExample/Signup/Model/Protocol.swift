//
//  Protocol.swift
//  SignupRxSwift
//
//  Created by 张骥 on 2020/4/24.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import RxCocoa
import RxSwift

enum VallidationResult {
    case ok(message: String)
    case empty
    case validating
    case failed(message: String)
}

protocol GitHubAPI {
    func usernameAvailable(_ username: String) -> Observable<Bool>
    func signup(_ username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(_ username: String) -> Observable<VallidationResult>
    func validatePassword(_ password: String) -> VallidationResult
    func validateRepeatedPassword(_ password: String, repatedPassword: String) -> VallidationResult
}

extension VallidationResult {
    var isValid: Bool {
        switch self {
        case .ok:
            return true
        default:
            return false
        }
    }
}
