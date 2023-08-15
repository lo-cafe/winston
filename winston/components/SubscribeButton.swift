//
//  SubscribeButton.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import SwiftUI
import Defaults

struct SubscribeButton: View {
  @Environment(\.colorScheme) var colorScheme: ColorScheme
  @Default(.subreddits) var subs
  @ObservedObject var subreddit: Subreddit
  @State var loading = false
  @GestureState var pressing = false
    var body: some View {
      let subscribed = subs.contains(where: { $0.data?.id == subreddit.id })
      if let _ = subreddit.data {
        HStack {
          Group {
            if loading {
              ProgressView()
                .padding(.trailing, 8)
                .colorScheme(subscribed ? .dark : colorScheme)
            } else {
              if subscribed {
                Image(systemName: "checkmark.circle.fill")
              }
            }
            let label = subscribed ? "Subscribed" : "Not subscribed"
            Text(label)
              .id(label)
          }
          .transition(.scaleAndBlur)
          
        }
        .fontSize(16, .semibold)
        .foregroundColor(subscribed ? .white : .primary)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RR(16, subscribed ? .green : .secondary.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.secondary.opacity(subscribed ? 0 : 0.2)))
        .brightness(pressing ? -0.1 : 0)
        .contentShape(Rectangle())
        .animation(spring, value: subs)
        .onTapGesture {
          withAnimation(spring) {
            loading = true
          }
          doThisAfter(0.3) {
            Task(priority: .background) {
              await subreddit.subscribeToggle()
              withAnimation(spring) {
                loading = false
              }
            }
          }
        }
        .simultaneousGesture(
          LongPressGesture(minimumDuration: 1)
            .updating($pressing, body: { val, state, transaction in
              transaction.animation = .default
              state = val
            })
        )
      }
    }
}
