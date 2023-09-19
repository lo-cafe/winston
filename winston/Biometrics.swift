//
//  Biometrics.swift
//  winston
//
//  Created by Nelson Dane on 19/09/23.
//

import SwiftUI
import Foundation
import LocalAuthentication

class Biometrics {
    let context = LAContext()
    var error: NSError?
    let reason = "Identify yourself!"
    var lockScreenView: UIView?

    func checkIfEnrolled() -> Bool {
        var isEnrolled = false
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) { 
            print("Biometrics are available")
            isEnrolled = true
        } else {
            print("Biometrics are not available")
        }
        return isEnrolled
    }

    func authenticateUser() {
        // Check if biometrics are enabled
        if !UserDefaults.standard.bool(forKey: "useFaceID") {
            print("App Biometrics Disabled")
            return
        }
        // Check if biomtrics are available
        if !checkIfEnrolled() {
            return
        }
        // We're all good, let's authenticate
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { 
            [weak self] success, error in

            DispatchQueue.main.async {
                if success {
                    print("Success!")
                    self?.lockScreenView?.removeFromSuperview()
                } else {
                    print("Failure!")
                    print(error?.localizedDescription ?? "Failed to authenticate")
                }
            }
        }
    }

}

extension Biometrics {
    
    func showLockedScreen(backgroundColor: UIColor, logo: UIImage?, width: CGFloat, toView view: UIView) {
        lockScreenView = UIView()
        assert(lockScreenView != nil, "There was a problem creating the lock screen view")
        lockScreenView!.translatesAutoresizingMaskIntoConstraints = false
        lockScreenView!.backgroundColor = backgroundColor
        
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        assert(logo != nil, "Could not find image!")
//        imageView.image = logo!
//        imageView.contentMode = .scaleAspectFit
//        
//        lockScreenView!.addSubview(imageView)
//        imageView.widthAnchor.constraint(equalTo: lockScreenView!.widthAnchor, multiplier: width).isActive = true
//        imageView.centerXAnchor.constraint(equalTo: lockScreenView!.centerXAnchor).isActive = true
//        imageView.centerYAnchor.constraint(equalTo: lockScreenView!.centerYAnchor).isActive = true
        
        view.addSubview(lockScreenView!)
        lockScreenView?.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        lockScreenView?.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        lockScreenView?.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        lockScreenView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
}
