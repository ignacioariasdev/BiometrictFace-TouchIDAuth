//
//  MTBiomericAuthenticationStatus.swift
//  FinalFaceAuth
//
//  Created by Marlhex on 2019-12-04.
//  Copyright © 2019 Ignacio Arias. All rights reserved.
//

import Foundation

struct MTBiomericAuthenticationStatus {
    var success = false
    var errorCode: Int?
    var errorMessage = ""
    
    mutating func setLoginSuccess() {
        self.success = true
    }
    
    mutating func setLoginFail(errorCode: Int, errorMessage: String) {
        self.success = false
        self.errorCode = errorCode
        self.errorMessage = errorMessage
    }
}
