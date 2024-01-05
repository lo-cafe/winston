//
//  CredentialPanelItem.swift
//  winston
//
//  Created by Igor Marcossi on 07/12/23.
//

import SwiftUI

struct CredentialPanelItem: View {
  var cred: RedditCredential
  var deleteCred: (RedditCredential) -> ()
  var inUse: Bool
  @State private var deleteAlertOpened = false
    var body: some View {
      WListButton(showArrow: true) {
        Nav.present(.editingCredential(cred))
      } label: {
        HStack {
          Label {
            Text(cred.userName ?? (cred.apiAppID.isEmpty ? "Empty credential" : cred.apiAppID))
              .lineLimit(1)
              .fontSize(cred.userName == nil && !cred.apiAppID.isEmpty ? 15 : 17, .regular, design: cred.userName == nil && !cred.apiAppID.isEmpty ? .monospaced : .default)
              .opacity(cred.userName == nil ? 0.75 : 1)
          } icon: {
            if let profilePicture = cred.profilePicture, let url = URL(string: profilePicture) {
              URLImage(url: url, processors: [.resize(size: .init(width: 32, height: 32))])
                .scaledToFill()
                .clipShape(Circle())
            } else {
              Image(systemName: "person.text.rectangle.fill")
                .foregroundStyle(Color.accentColor)
            }
          }
          
          Spacer()
          
          if inUse {
            Text("IN USE")
              .foregroundStyle(.white)
              .shadow(color: .black.opacity(0.5), radius: 8, y: 4)
              .fontSize(12, .semibold)
              .padding(.vertical, 1)
              .padding(.horizontal, 4)
              .background(RR(4, Color.accentColor))
          }
          
          if cred.refreshToken == nil {
            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
          }
        }
      }
      .contextMenu(ContextMenu(menuItems: {
        if let accessToken = cred.accessToken?.token {
          Button("Copy access token", systemImage: "doc.on.clipboard") {
            UIPasteboard.general.string = accessToken
          }
        }
        if cred.refreshToken != nil {
          Button("Refresh access token", systemImage: "arrow.clockwise") {
            Task(priority: .background) { _ = await cred.getUpToDateToken(forceRenew: true) }
          }
        }
        Button("Delete", systemImage: "trash", role: .destructive) {
          deleteAlertOpened = true
        }
      }))
      .alert("Do you really wanna delete this credential?", isPresented: $deleteAlertOpened) {
        VStack {
          Button("Yes, delete", role: .destructive) {
            RedditCredentialsManager.shared.deleteCred(cred)
          }
          Button("Cancel", role: .cancel) {
            deleteAlertOpened = false
          }
        }
      }
    }
}
