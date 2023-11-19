//
//  FileListView.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Foundation
import SwiftUI

struct FileListView: View {
  @EnvironmentObject var appModel: AppModel

  @State var files: [File] = []

  var body: some View {
    VStack {
      List(files, selection: $appModel.activeFile) { file in
        NavigationLink(value: file, label: {
          Text(file.name)
        })
      }.listStyle(SidebarListStyle())
    }
    .toolbar(content: {
      ToolbarItem(placement: .primaryAction, content: {
        Menu {
          Button(action: {
            appModel.createFile("(+ 1 2)", filename: "test.janet")
            files = appModel.getFiles()
          }, label: {
            Label("Add file", systemImage: "doc")
          })

          Button(action: {}, label: {
            Label("Add folder", systemImage: "folder")
          })

        } label: {
          Label("file menu", systemImage: "plus")
        }
      })
    })
    .onAppear {
      files = appModel.getFiles()
    }
  }
}
