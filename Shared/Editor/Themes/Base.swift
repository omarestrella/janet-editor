//
//  Base.swift
//  JanetMobile
//
//  Created by Omar Estrella on 6/10/22.
//

import Foundation
import Runestone
import UIKit

public protocol EditorTheme: Runestone.Theme {
  var backgroundColor: UIColor { get }
  var userInterfaceStyle: UIUserInterfaceStyle { get }
}
