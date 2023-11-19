//
//  JanetApp.swift
//  Shared
//
//  Created by Omar Estrella on 7/29/22.
//

import SwiftUI


@main
struct JanetApp: App {
  @StateObject var appModel = AppModel()
  
  var body: some Scene {
    WindowGroup {
      MainView(text: "")
    }
      .environmentObject(appModel)
  }
}
