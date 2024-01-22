//
//  SubredditRulesTab.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import SwiftUI
import MarkdownUI

struct SubredditRulesTab: View {
  var subreddit: Subreddit
  @State var loading = true
  @State var data: RedditAPI.FetchSubRulesResponse?
    var body: some View {
      if loading {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 400)
          .listRowBackground(Color.clear)
          .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
          .onAppear {
            Task(priority: .background) {
              if let newData = await subreddit.fetchRules() {
                withAnimation {
                  data = newData
                }
              }
              withAnimation {
                loading = false
              }
            }
          }
      } else {
        if let data = data, let rules = data.rules {
          Section {
            ForEach(Array(rules.enumerated()), id: \.element.short_name) { i, rule in
              HStack(alignment: .top, spacing: 12) {
                Text(String(i + 1))
                  .frame(width: 24, height: 24)
                  .fontSize(16, .semibold)
                  .background(Color.accentColor, in: Circle())
                  .foregroundColor(.white)
                
                VStack(alignment: .leading) {
                  Text(rule.short_name ?? "Unamed rule")
                    .fontSize(22, .bold)
                  
                  let text = MarkdownUtil.formatForMarkdown(rule.description ?? "")
                  Markdown(text.isEmpty ? "Rule without description." : text)
                    .markdownTheme(.winstonMarkdown(fontSize: 16))
                }
              }
              .multilineTextAlignment(.leading)
            }
          }
        } else {
          Text("This sub doesn't have any rules")
        }
      }
    }
}
