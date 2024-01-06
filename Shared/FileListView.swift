//
//  FileListView.swift
//  Janet (iOS)
//
//  Created by Omar Estrella on 11/17/23.
//

import Foundation
import SwiftUI

struct FileTreeEntry: View {
  @EnvironmentObject var appModel: AppModel
  
  @State var isOpen = true
  
  let item: FileTreeItem
  var level = 0
  
  var isFolder: Bool {
    item.type == .Folder
  }
  
  var isSelected: Bool {
    guard let activeDocument = appModel.activeDocument else {
      return false
    }
    return activeDocument.id == item.document?.id
  }
  
  var body: some View {
    VStack {
      HStack {
        HStack {
          if isFolder {
            Button(action: {
              isOpen = !isOpen
            }, label: {
              Label("OpenCloseAction", systemImage: isOpen ? "chevron.down" : "chevron.right")
                .labelStyle(.iconOnly)
                .foregroundColor(.primary)
              
            })
            .controlSize(.small)
            .frame(width: 20)
          } else {
            Spacer().frame(width: 28)
          }
          
          Button(action: {
            if let doc = item.document {
              appModel.activeDocument = doc
            } else {
              isOpen = !isOpen
            }
          }, label: {
            HStack {
              Image(systemName: isFolder ? "folder.fill" : "doc")
                .foregroundStyle(isFolder ? .secondary : .primary)
              Label(item.name, systemImage: "").labelStyle(.titleOnly)
            }
          }).foregroundColor(.primary)
          
          Spacer()
        }
        .padding(.leading, CGFloat(level) * 20)
        .frame(height: 24)
      }
      .background(isSelected ? Color.secondary.opacity(0.2) : Color.clear)
      .clipShape(.rect(cornerRadius: 5, style: .continuous))
      
      if isOpen, let children = item.children {
        ForEach(children) { item in
          FileTreeEntry(item: item, level: level + 1)
        }
      }
    }
    .background()
    .contextMenu {
      Button(action: {
        if isSelected {
          appModel.activeDocument = nil
        }
        appModel.deleteItem(item)
        appModel.loadFiles()
      }, label: {
        Label("Delete", systemImage: "trash")
      })
    }
  }
}

struct FileListView: View {
  @EnvironmentObject var appModel: AppModel

  @State var newFileName = ""
  @State var showNewFileDialog = false

  var body: some View {
    HStack {
      VStack(alignment: .leading) {
        ForEach(appModel.fileTree) { item in
          FileTreeEntry(item: item)
        }
        
        Spacer()
      }
      
      Spacer()
    }
    .toolbar(content: {
      ToolbarItem(placement: .primaryAction, content: {
        Menu {
          Button(action: {
            showNewFileDialog = true
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
  }
}

#Preview {
  FileListView().environmentObject(AppModel(fileTree: [
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
  ])).frame(width: 200)
}
