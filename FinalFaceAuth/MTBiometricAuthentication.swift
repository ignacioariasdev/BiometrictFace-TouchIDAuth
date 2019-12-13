//
//  MTBiometricAuthentication.swift
//  FinalFaceAuth
//
//  Created by Marlhex on 2019-12-04.
//  Copyright © 2019 Ignacio Arias. All rights reserved.
//

import UIKit
import LocalAuthentication

extension Notification.Name {
    static let MTBiometricAuthenticationNotificationLoginStatus = Notification.Name("LoginStatus")
}

class MTBiometricAuthentication {
    
    var authStatus =  MTBiomericAuthenticationStatus()
    //reasonString is prompted to user for login with touchid
    var reasonString = "For bio auth"
    static let status = "status"
    
    private var askPermissionViewController: AskPermission? = nil
    
    //Ask user permission again
    func askAgain() {
        askPermissionViewController!.goToUserSettings() // askPermissionViewController won't be nil
    }
    
    //Auto hirarchy add + no need to instanciate the class again
    init(askPermissionViewController: AskPermission) {
        self.askPermissionViewController = askPermissionViewController
    }
    
    //Global
    let localAuthenticationContext = LAContext()
    var authError: NSError?
    
    
    //Check userPermission for faceID
    func authenticationWithBiometricID() {
        print("Starting Biometric")
        
        if localAuthenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
            
            localAuthenticationContext.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Enter your passcode to make a safe purchase", reply: { (success, error) in
                print("passcode begun")
                if success {
                    DispatchQueue.main.async {
                        //Passcode enter correctly.
                        print("Authentication was successful")
                        self.authStatus.setLoginSuccess()
                        self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
                    }
                }else {
                    
                    guard let error = error else {
                        return
                    }
                    
                    let errorMessage = self.errorMessageForFails(errorCode: error._code)
                    self.authStatus.setLoginFail(errorCode: error._code, errorMessage: errorMessage)
                    self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
//
//                    DispatchQueue.main.async {
//                        //self.displayErrorMessage(error: error as! LAError )
//                        print("Authentication was error")
//                        //                                   self.askPermissionViewController!.onLoginFail()
//                    }
                }
            })
            
            //Bio fail by several reasons cancelation, failure, https://developer.apple.com/documentation/localauthentication/laerror/code
        } else {
            //If the user didn't allow on first attempt the request, you can send the open settings func over here.
            guard let error = authError else {
                return
            }
            
            print("sending the user to settings")
            
            print("error es: ", error)
            
            let errorMessage = self.errorMessageForFails(errorCode: error._code)
            self.authStatus.setLoginFail(errorCode: error._code, errorMessage: errorMessage)
            self.postNotification(userInfo: [MTBiometricAuthentication.status : self.authStatus])
        }
    }
    
    //Not going to help
    func errorMessageForFailsDeprecatediniOS11(errorCode: Int) -> String {
        var message = ""
        if #available(iOS 11.0, macOS 10.13, *) {
            message = "unknown error"
        } else {
            switch errorCode {
            case LAError.touchIDLockout.rawValue:
                message = "Authentication was not successful, because there were too many failed Touch ID attempts and Touch ID is now locked. Passcode is required to unlock Touch ID"
                
            case LAError.touchIDNotAvailable.rawValue:
                message = "Authentication could not start, because Touch ID is not available on the device or User has denied the use of biometry for this app."
                
                
            case LAError.touchIDNotEnrolled.rawValue:
                message = "Authentication could not start, because Touch ID is not enrolled on the device"
            default :
                message = "unknown error, add more cases to the MTBiometricAuthentication"
            }
        }
        
        return message
    }
    
    func errorMessageForFails(errorCode: Int) -> String {
        
        var message = ""
        
        switch errorCode {
        case LAError.authenticationFailed.rawValue:
            message = "Authentication was not successful, because user failed to provide valid credentials"
            
        case LAError.appCancel.rawValue:
            message = "Authentication was canceled by application"
            
        case LAError.invalidContext.rawValue:
            message = "LAContext passed to this call has been previously invalidated"
            
        case LAError.notInteractive.rawValue:
            message = "Authentication failed, because it would require showing UI which has been forbidden by using interactionNotAllowed property"
            
        case LAError.passcodeNotSet.rawValue:
            message = "Authentication could not start, because passcode is not set on the device"
            
        case LAError.systemCancel.rawValue:
            message = "Authentication was canceled by system"
            
        case LAError.userCancel.rawValue:
            message = "Authentication was canceled by user"
            
        case LAError.userFallback.rawValue:
            message = "Authentication was canceled, because the user tapped the fallback button"
            
        case LAError.biometryNotAvailable.rawValue:
            message = "Authentication could not start, because biometry is not available on the device"
            
        case LAError.biometryLockout.rawValue:
            message = "Authentication was not successful, because there were too many failed biometry attempts and                          biometry is now locked"
            
        case LAError.biometryNotEnrolled.rawValue:
            message = "Authentication could not start, because biometric authentication is not enrolled"
            
        default:
            message = self.errorMessageForFailsDeprecatediniOS11(errorCode: errorCode)
        }
        
        return message
    }
    
    func postNotification(userInfo: [String: MTBiomericAuthenticationStatus]) {
        NotificationCenter.default.post(name: .MTBiometricAuthenticationNotificationLoginStatus, object: self, userInfo: userInfo)
    }
    
}
