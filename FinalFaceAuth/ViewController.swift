//
//  ViewController.swift
//  FinalFaceAuth
//
//  Created by Marlhex on 2019-12-04.
//  Copyright © 2019 Ignacio Arias. All rights reserved.
//

import UIKit

extension UIView {
  func addTapGesture(tapNumber: Int, target: Any, action: Selector) {
    let tap = UITapGestureRecognizer(target: target, action: action)
    tap.numberOfTapsRequired = tapNumber
    addGestureRecognizer(tap)
    isUserInteractionEnabled = true
  }
}


class ViewController: UIViewController {
  
    
    let randomView: UIImageView = {
        let imageView = UIImageView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        imageView.backgroundColor = UIColor.black.withAlphaComponent(0.9)
        imageView.layer.cornerRadius = 5
        imageView.isUserInteractionEnabled = false
        return imageView
    }()
    
    let shinnyDLbl: UILabel = {
     let lbl = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        lbl.text = "Tap here to pay \n \n by \n \n Face ID or Touch ID"
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = UIColor(white: 1, alpha: 0.9)
        lbl.textAlignment = .center
        
        return lbl
    }()

    let baseDLbl: UILabel = {
        let lbl = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 100))
        lbl.text = "Tap here to pay \n \n by \n \n Face ID or Touch ID"
        lbl.numberOfLines = 0
        lbl.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        lbl.textColor = UIColor(white: 1, alpha: 0.5)
        lbl.textAlignment = .center
        return lbl
    }()
      
      override func viewDidLoad() {
          super.viewDidLoad()
        
        view.backgroundColor = .white
        
          randomView.center = view.center
          view.addSubview(randomView)

        randomView.addTapGesture(tapNumber: 1, target: self, action: #selector(handlePay))
        
        setUpEffect2()
      }

    @objc private func handlePay() {
        
         let nextVC = AskPermission()
        
        let nav = UINavigationController(rootViewController: nextVC)
        nav.isNavigationBarHidden = true
        
        self.navigationController?.pushViewController(nextVC, animated: false)
//        print("begin")
    }
    
    
    
    fileprivate func setUpEffect2() {
    
               // Labels
               randomView.addSubview(baseDLbl)
               randomView.addSubview(shinnyDLbl)


               let gradient = CAGradientLayer()

               gradient.frame = baseDLbl.bounds

               gradient.colors = [UIColor.clear.cgColor, UIColor.clear.cgColor, UIColor.black.cgColor, UIColor.black.cgColor, UIColor.clear.cgColor, UIColor.clear.cgColor]
               gradient.locations = [0.0, 0.2, 0.4, 0.6, 0.8, 1.0]
               let angle = -60 * CGFloat.pi / 180
               let rotationTransform = CATransform3DMakeRotation(angle, 0, 0, 1)
               gradient.transform = rotationTransform

               shinnyDLbl.layer.mask = gradient

               let animation = CABasicAnimation(keyPath: "transform.translation.x")
               animation.duration = 2
               animation.repeatCount = Float.infinity
               animation.autoreverses = false
               animation.fromValue = -view.frame.width
               animation.toValue = view.frame.width
               animation.isRemovedOnCompletion = false
               animation.fillMode = CAMediaTimingFillMode.forwards

               gradient.add(animation, forKey: "shimmerKey")
           }
    

}

