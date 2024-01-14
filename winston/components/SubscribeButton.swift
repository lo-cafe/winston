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
  @FetchRequest(sortDescriptors: [], animation: .default) var subs: FetchedResults<CachedSub>
  @ObservedObject var subreddit: Subreddit
  var isSmall: Bool = false
  @State var loading = false
  @GestureState var pressing = false
  
  var body: some View {
    let subscribed = subs.contains(where: { $0.name == subreddit.data?.name })
    if let _ = subreddit.data {
      HStack {
        Group {
          if loading {
            ProgressView()
              .padding(.trailing, isSmall ? 0 : 8)
              .colorScheme(subscribed ? .dark : colorScheme)
            
          } else {
            if subscribed {
              if isSmall {
                Image(systemName: "checkmark").padding(.horizontal, 5)
              } else {
                Image(systemName: "checkmark.circle.fill")
              }
            } else {
              if isSmall {
                Text("Sub")
              }
            }
          }
          let label = subscribed ? "Subscribed" : "Not subscribed"
          if !isSmall {
            Text(label)
              .id(label)
          }
        }
        .transition(.scaleAndBlur)
        
      }
      .contentTransition(.symbolEffect)
      .fontSize(16, isSmall ? .medium : .semibold)
      .foregroundColor(subscribed ? .white : isSmall ? .accentColor : .primary)
      .padding(.horizontal, isSmall ? 0 : 16)
      .padding(.vertical, isSmall ? 0 : 12)
      .frame(width: isSmall ? 56 : nil, height: isSmall ? 28 : nil)
      .background(RR(16, (subscribed ? .green : isSmall ? .clear : .secondary.opacity(0.2))))
      .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(isSmall ? Color.accentColor.opacity(subscribed ? 0 : 1.5) : .secondary.opacity(subscribed ? 0 : 0.2), lineWidth: 2))
      .brightness(pressing ? -0.1 : 0)
      .contentShape(Rectangle())
      //        .animation(spring, value: subs)
      .onTapGesture {
        withAnimation(spring) {
          loading = true
        }
        doThisAfter(0.3) {
          subreddit.subscribeToggle {
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
