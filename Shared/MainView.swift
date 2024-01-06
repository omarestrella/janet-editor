//
//  ContentView.swift
//  Shared
//
//  Created by Omar Estrella on 7/29/22.
//

import SwiftUI
import ObjectiveC


struct MainView: View {
  @EnvironmentObject var appModel: AppModel
  
  @State var showAlert = false

  var body: some View {
    NavigationSplitView(sidebar: {
      FileListView().padding(.all)
    }, detail: {
      if let document = appModel.activeDocument {
        EditorView(document: document)
          .navigationTitle(title)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(id: "editor-toolbar", content: {
            ToolbarItem(id: "run-code", placement: .primaryAction) {
              Button("run", systemImage: "play.fill", action: {
                let result = appModel.runCode(code: document.contents)
                print("\(String(describing: result))")
              })
            }
          }).toolbarRole(.editor)
      } else {
        Text("Pick a file...")
      }
    })
    .onAppear {
      appModel.runtime.registerFunction(AlertFunction())
    }
//    .alert(alertHandler.title, isPresented: $alertHandler.showAlert, actions: {
//      Button("Ok", systemImage: "play", action: {
//        alertHandler.showAlert = false
//      })
//    }, message: {
//      Text(alertHandler.message)
//    })
//    .onAppear {
//      appModel.runtime.registerFunction(name: "alert", documentation: "", fn: { argc, argv in
//        janet_fixarity(argc, 2)
//        
//        let title = String(cString: janet_unwrap_string(argv![0]))
//        let message = String(cString: janet_unwrap_string(argv![1]))
//        
//        AlertHandler.shared.title = title
//        AlertHandler.shared.message = message
//        AlertHandler.shared.showAlert = true
//        
//        return janet_wrap_nil()
//      })
//    }
  }
  
  var title: String {
    if let url = appModel.activeDocument?.url {
      return url.deletingPathExtension().lastPathComponent
    }
    return "(No name)"
  }
}

#Preview {
  MainView().environmentObject(AppModel(fileTree: [
    FileTreeItem(name: "src", children: [
      FileTreeItem(name: "main.janet", document: JanetDocument(contents: ""))
    ]),
    FileTreeItem(name: "scripts", children: [
      FileTreeItem(name: "folder", children: [
        FileTreeItem(name: "file.sh", document: JanetDocument(contents: ""))
      ]),
      FileTreeItem(name: "edit.sh", document: JanetDocument(contents: "")),
      FileTreeItem(name: "publish.sh", document: JanetDocument(contents: ""))
    ])
  ]))
}
