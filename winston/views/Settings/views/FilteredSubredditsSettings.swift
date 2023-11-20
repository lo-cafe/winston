//
//  FilteredSubredditsSettings.swift
//  winston
//
//  Created by Ethan Bills on 9/12/23.
//
import SwiftUI
import Defaults

struct FilteredSubredditsSettings: View {
  @Default(.filteredSubreddits) private var filteredSubreddits
  @State private var newSubreddit = ""
  @State private var addSubredditAlert = false
  @Environment(\.useTheme) private var theme

  private func removeSubreddit(at index: Int) {
    var tempSubreddits = filteredSubreddits
    tempSubreddits.remove(at: index)
    filteredSubreddits = tempSubreddits
  }

  var body: some View {
    Group {
      List {
        Section {
          ForEach(Array(filteredSubreddits.enumerated()), id: \.element) { index, subreddit in
            Text(subreddit)
              .swipeActions {
                Button(action: {
                  withAnimation {
                    removeSubreddit(at: index)
                  }
                  
                }) {
                  Image(systemName: "hand.raised.slash.fill")
                }
                .tint(Color.green)
              }
            .themedListRowBG(enablePadding: true)
          }
        }
        .themedListDividers()
      }
      .themedListBG(theme.lists.bg)
      .navigationTitle("Filtered Subreddits")
      .navigationBarItems(trailing:
        HStack {
          Button(action: {
            addSubredditAlert = true
          }) {
            Image(systemName: "plus")
          }
        }
      )
      .navigationViewStyle(StackNavigationViewStyle())
    }
    .alert("Enter a subreddit", isPresented: $addSubredditAlert) {
      TextField("Meow", text: $newSubreddit)
      Button("OK", action: {
        if !newSubreddit.isEmpty && !filteredSubreddits.contains(newSubreddit) {
          withAnimation {
            filteredSubreddits.append(newSubreddit)
          }

          newSubreddit = ""
        }
      })
      Button("Cancel", action: {
        // Do nothing! :D
      })
    } message: {
      Text("Enter a subreddit you wish to filter (case-sensitive).")
    }
  }
}
