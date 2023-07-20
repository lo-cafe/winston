//
//  SubscribeButton.swift
//  winston
//
//  Created by Igor Marcossi on 19/07/23.
//

import SwiftUI

struct SubscribeButton: View {
  @ObservedObject var subreddit: Subreddit
  @State var loading = false
  @GestureState var pressing = false
    var body: some View {
      if let data = subreddit.data, let subscribed = data.user_is_subscriber {
        HStack {
          Group {
            if loading {
              ProgressView()
                .padding(.trailing, 8)
            } else {
              if subscribed {
                Image(systemName: "checkmark.circle.fill")
              }
            }
            let label = data.user_is_subscriber ?? false ? "Subscribed" : "Not subscribed"
            Text(label)
              .id(label)
          }
          .transition(.scaleAndBlur)
          
        }
        .fontSize(16, .semibold)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(RR(16, subscribed ? .green : .secondary.opacity(0.2)))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(.secondary.opacity(subscribed ? 0 : 0.2)))
        .brightness(pressing ? -0.1 : 0)
        .contentShape(Rectangle())
        .onTapGesture {
          withAnimation(spring) {
            loading = true
          }
          doThisAfter(0.3) {
            Task {
              await subreddit.subscribeToggle { _ in
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
