//
//  ContentView.swift
//  Shared
//
//  Created by Omar Estrella on 7/29/22.
//

import SwiftUI

struct MainView: View {
  @State var text: String

  @EnvironmentObject var appModel: AppModel

  var body: some View {
    NavigationSplitView {
      FileListView()
        .navigationTitle("Files")
    } detail: {
      if let file = appModel.activeFile {
        VStack {
          EditorView(file: file)
            .navigationTitle(Text("df"))
            .navigationBarTitleDisplayMode(.inline)
          
          VStack {
            ForEach(Array(zip($appModel.results.indices, $appModel.results)), id: \.0) { result in
              Text(String(describing: result.1.wrappedValue))
            }
          }.frame(maxHeight: 100)
        }
      } else {
        Text("Select a file...")
      }
    }
    .navigationSplitViewColumnWidth(min: 150, ideal: 150, max: 150)
  }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    MainView(text: "")
  }
}
#endif
