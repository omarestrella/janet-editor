//
//  Alert.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 1/5/24.
//

import Foundation
import UIKit

struct AlertFunction: JanetFunction {
  var name = "alert"

  var documentation = ""

  func run() {
    if let rootController {
      DispatchQueue.main.async {
              let alertController = UIAlertController(title: "TITLE", message: "MESSAGE", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: { _ in
          alertController.dismiss(animated: true)
        }))
              
        rootController.present(alertController, animated: true, completion: nil)
      }
    }
  }

  var rootController: UIViewController? {
    return (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController
  }
}
