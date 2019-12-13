//
//  AskPermission.swift
//  FinalFaceAuth
//
//  Created by Marlhex on 2019-12-04.
//  Copyright © 2019 Ignacio Arias. All rights reserved.
//

import UIKit
import Lottie
import LocalAuthentication

class AskPermission: UIViewController {
    
    //MARK: Lottie
    let animationView: AnimationView = {
        let a = AnimationView()
        return a
    }()
    
    
    private func lottie() {
        view.addSubview(animationView)
        animationView.bounds.size.width = UIScreen.main.bounds.width
        animationView.bounds.size.height = UIScreen.main.bounds.height
        animationView.center = view.center
        self.animationView.animation = Animation.named("4432-face-scanning")
        self.animationView.loopMode = .playOnce
        self.animationView.animationSpeed = 9
        self.animationView.play { (finished) in
            self.authenticateWithBiometric()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lottie()
        NotificationCenter.default.addObserver(self, selector: #selector(AskPermission.authenticationCompletionHandler(loginStatusNotification:)), name: .MTBiometricAuthenticationNotificationLoginStatus, object: nil)
    }
    
    
    //Ask user permission
    func authenticateWithBiometric() {
        let bioAuth = MTBiometricAuthentication(askPermissionViewController: self)
        bioAuth.reasonString = "Are you the device owner?"
        bioAuth.authenticationWithBiometricID()
    }
    
    func authLocked() {
        let alertController = UIAlertController(title: "You're Banned", message: "You've been disabled to use biometric auth by attempting to auth many failed times. Please check again later.", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Back", style: .destructive, handler: {(_) in
        _ = self.navigationController?.popViewController(animated: true)
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //    //Ask again
    func goToUserSettings() {
        let alertController = UIAlertController(title: "Biometric Auth", message: "Go to settings and turn on the proper permissions", preferredStyle: .alert)
        
        let settingsAction = UIAlertAction(title: "Go to Settings", style: .destructive) { (_) -> Void in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in })
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (_) in
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    //Status of the BioAuth
    @objc func authenticationCompletionHandler(loginStatusNotification: Notification) {
        if let _ = loginStatusNotification.object as? MTBiometricAuthentication, let userInfo = loginStatusNotification.userInfo {
            if let authStatus = userInfo[MTBiometricAuthentication.status] as? MTBiomericAuthenticationStatus {
                if authStatus.success {
                    print("Login Success")
                    DispatchQueue.main.async {
                        self.onLoginSuccess()
                    }
                } else {
                    if let errorCode = authStatus.errorCode {
                        print("Login Fail with code: \(String(describing: errorCode)), reason: \(authStatus.errorMessage)")
                        
                        switch authStatus.errorCode {
                        case -8:
                            //Blocked by many attempts
                            authLocked()
                        
                        case -6:
                            //Check permissions
                            goToUserSettings()
                            
                        default:
                            //Failed to check identity
                            DispatchQueue.main.async {
                            self.onLoginFail()
                            }
                        }
                    }
                }
            }
        }
    }
    
    //Success
    func onLoginSuccess() {
        let receiptVC = ReceiptVC()
        self.navigationController?.pushViewController(receiptVC, animated: true)
    }
    
    //Failed
    func onLoginFail() {
        let alert = UIAlertController(title: "Unable to check your identity", message: "No purchase and nor auth where done", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Go back", style: UIAlertAction.Style.default, handler: { (_) in
            _ = self.navigationController?.popViewController(animated: true)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
