//
//  GitHubDefaultValidationService.swift
//  SignupRxSwift
//
//  Created by 张骥 on 2020/4/26.
//  Copyright © 2020 ZhangJi. All rights reserved.
//

import Foundation
import RxSwift

class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI
    
    static let shartValidationSsrvice = GitHubDefaultValidationService(API: GitHubDefaultAPI.shareAPI)
    
    let minPasswordCount = 5
    
    init(API: GitHubAPI) {
        self.API = API
    }
    
    func validateUsername(_ username: String) -> Observable<VallidationResult> {
        if username.isEmpty {
            return .just(.empty)
        }
        
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return .just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = VallidationResult.validating
        
        return API
            .usernameAvailable(username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                }
                else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> VallidationResult {
        let numberOfCharacters = password.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repatedPassword: String) -> VallidationResult {
        if repatedPassword.count == 0 {
            return .empty
        }
        
        if repatedPassword == password {
            return .ok(message: "Password repeated")
        }
        else {
            return .failed(message: "Password different")
        }
    }
}

class GitHubDefaultAPI: GitHubAPI {
    let URLSession: Foundation.URLSession
    
    static let shareAPI = GitHubDefaultAPI(URLSession: Foundation.URLSession.shared)
    
    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        
        return self.URLSession.rx.response(request: request)
            .map{ pair in
                return pair.response.statusCode == 404
        }
        .catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        let signupResult = arc4random() % 5 == 0 ? false : false
        
        return Observable.just(signupResult)
            .delay(.seconds(1), scheduler: MainScheduler.instance)
    }
}

extension String {
    var URLEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
    }
}


