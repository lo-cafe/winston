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

    func checkIfEnrolled() -> Bool {
        var isEnrolled = false
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) { 
            print("Biometrics are available on this device")
            isEnrolled = true
        } else {
            print("Biometrics are not available on this device")
        }
        return isEnrolled
    }

    func biometricType() -> String {
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            if #available(iOS 11.0, *) {
                switch context.biometryType {
                case .opticID:
                    return "Optic ID"
                case .faceID:
                    return "Face ID"
                case .touchID:
                    return "Touch ID"
                case .none:
                    return "None"
                @unknown default:
                    return "Unknown"
                }
            } else {
                // Fallback on earlier versions
                return "Touch ID"
            }
        }
        else {
            // Fallback to passcode
            return "Passcode"
        }
    }

    func authenticateUser(completion: @escaping (Bool) -> Void) {
        // Check if biomtrics are available
        if !checkIfEnrolled() {
            completion(false)
            return
        }
        // We're all good, let's authenticate
        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "Identify Yourself!") { success, error in
            if success {
                print("Auth Success")
                completion(true)
            } else {
                print("Auth Failure: \(error?.localizedDescription ?? "Failed to authenticate")")
                completion(false)
            }
        }
    }
}
