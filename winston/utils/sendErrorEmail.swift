//
//  sendErrorEmail.swift
//  winston
//
//  Created by Igor Marcossi on 29/07/23.
//

import MessageUI

class EmailHelper: NSObject, MFMailComposeViewControllerDelegate {
  
  static let shared = EmailHelper()
  
  func sendEmail(_ text: String) {
    if MFMailComposeViewController.canSendMail() {
      let fileName = "bug-in-a-jar.txt"
      let filePath = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
      
      do {
        try text.write(to: filePath, atomically: true, encoding: .utf8)
      } catch {
        return
      }
      
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients(["weird-gift@lo.cafe"])
      mail.setSubject("Winston found a bug!")
      mail.setMessageBody("Here it is, inside a jar of course because ewww", isHTML: false)
      
      if let fileData = NSData(contentsOf: filePath) {
        mail.addAttachmentData(fileData as Data, mimeType: "text/plain", fileName: fileName)
      }
      
      UIApplication.shared.windows.first?.rootViewController?.present(mail, animated: true)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}

func sendEmail(_ text: String) {
  DispatchQueue.main.async {
    EmailHelper.shared.sendEmail(text)
  }
}





class CustomEmailHelper: NSObject, MFMailComposeViewControllerDelegate {
  
  static let shared = CustomEmailHelper()
  
  func sendEmail() {
    if MFMailComposeViewController.canSendMail() {
      
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      mail.setToRecipients(["hi@lo.cafe"])
      mail.setSubject("Hey, I just found a bug!")
      mail.setMessageBody("Please describe what you were doing and what happened.", isHTML: false)
      
      UIApplication.shared.windows.first?.rootViewController?.present(mail, animated: true)
    }
  }
  
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}

func sendCustomEmail() {
  DispatchQueue.main.async {
    CustomEmailHelper.shared.sendEmail()
  }
}
