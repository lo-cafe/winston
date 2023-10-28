//
//  PinnedPost.swift
//  winston
//
//  Created by Igor Marcossi on 23/07/23.
//

import SwiftUI
import NukeUI
import Defaults

struct PostInBoxLink: View {
  @EnvironmentObject private var routerProxy: RouterProxy
  @Binding var selectedSub: FirstSelectable?
  @Default(.postsInBox) private var postsInBox
  
  var postInBox: PostInBox
  @StateObject var post: Post
  @StateObject var sub: Subreddit
  @State private var dragging = false
  @State private var deleting = false
  @State private var offsetY: CGFloat?
  var body: some View {
    //    Button {
    //      openPost(post)
    //    } label: {
    VStack(alignment: .leading, spacing: 4) {
      HStack {
        if let subredditIconKit = sub.data?.subredditIconKit {
          SubredditIcon(subredditIconKit: subredditIconKit, size: 20)
        }
//        SubredditBaseIcon(name: postInBox.subredditName, iconURLStr: postInBox.subredditIconURL, id: postInBox.id, size: 20, color: postInBox.subColor)
//          .equatable()
        Text(postInBox.subredditName)
          .fontSize(13,.medium)
      }
      Text(postInBox.title.escape)
        .lineLimit(2)
        .fontSize(16, .semibold)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear { if let selfBody = postInBox.body { decodePostToCache(id: postInBox.id, str: selfBody) } }
      
      Spacer()
        .frame(maxHeight: .infinity)
      
      HStack {
        
        
        HStack(alignment: .center, spacing: 6) {
          HStack(alignment: .center, spacing: 2) {
            Image(systemName: "message.fill")
            Text(formatBigNumber(postInBox.commentsCount ?? 0))
              .contentTransition(.numericText())
          }
          
          if let createdAt = postInBox.createdAt {
            HStack(alignment: .center, spacing: 2) {
              Image(systemName: "hourglass.bottomhalf.filled")
              Text(timeSince(Int(createdAt)))
                .contentTransition(.numericText())
            }
          }
        }
        .font(.system(size: 13, weight: .medium))
        .compositingGroup()
        .opacity(0.5)
        
        Spacer()
        HStack(alignment: .center, spacing: 4) {
          
          Image(systemName: "arrow.up")
            .foregroundColor(.orange)
          
          Text(formatBigNumber(postInBox.score ?? 0))
            .foregroundColor((postInBox.score ?? 0) > 0 ? .orange : postInBox.score == 0 ? .gray : .blue)
            .fontSize(13, .semibold)
            .transition(.asymmetric(insertion: .offset(y: 16), removal: .offset(y: -16)).combined(with: .opacity))
//            .id(post.score)
          
          Image(systemName: "arrow.down")
            .foregroundColor(.gray)
        }
        .fontSize(13, .medium)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Capsule(style: .continuous).fill(.secondary.opacity(0.1)))
      }
      
    }
    .padding(.horizontal, 13)
    .padding(.vertical, 11)
    .frame(width: (UIScreen.screenWidth / 1.75), height: 120, alignment: .topLeading)
    .background(
      postInBox.img != nil && postInBox.img != ""
      
      ? URLImage(url: URL(string: postInBox.img!)!)
        .scaledToFill()
        .opacity(0.15)
        .frame(width: (UIScreen.screenWidth / 1.75), height: 120)
        .clipped()
      : nil
    )
    .themedListRowBG()
    .mask(RR(20, Color.listBG))
    .offset(y: offsetY ?? 0)
    .scaleEffect(dragging ? 0.975 : 1)
    .background(
      Text("DISCARD")
        .fontSize(14, .semibold)
        .foregroundColor(.red)
        .frame(height: abs(offsetY ?? 0))
        .saturation(deleting ? 1 : 0)
        .scaleEffect(deleting ? 1 : 0.85)
    )
    .onTapGesture {
      selectedSub = .post(PostViewPayload(post: post, postSelfAttr: nil, sub: sub))
    }
    .gesture(
      LongPressGesture(minimumDuration: 0.5, maximumDistance: 10)
        .onEnded { _ in
          withAnimation(spring) {
            dragging = true
          }
          let impact = UIImpactFeedbackGenerator(style: .rigid)
          impact.prepare()
          impact.impactOccurred()
//          try? haptics.fire(intensity: 1, sharpness: 1)
        }
        .sequenced(before: DragGesture())
        .onChanged{ sequence in
          switch sequence {
          case .first(_):
            break
          case .second(_, let dragVal):
            if let dragVal = dragVal {
              var trans = Transaction()
              trans.isContinuous = true
              trans.animation = draggingAnimation
              withTransaction(trans) {
                offsetY = dragVal.translation.height
              }
              if abs(dragVal.translation.height) > 70 && !deleting {
                withAnimation(spring) {
                  deleting = true
                }
                let impact = UIImpactFeedbackGenerator(style: .rigid)
                impact.prepare()
                impact.impactOccurred()
              }
              if abs(dragVal.translation.height) < 70 && deleting {
                withAnimation(spring) {
                  deleting = false
                }
                let impact = UIImpactFeedbackGenerator(style: .rigid)
                impact.prepare()
                impact.impactOccurred()
              }
            }
          }
        }
        .onEnded { sequence in
          switch sequence {
          case .first(_):
            break
          case .second(_, let dragVal):
            var endingY: CGFloat = 0
            let endPos = dragVal?.translation.height ?? 0
            let predictedEnd = dragVal?.predictedEndTranslation.height ?? 0
            if dragVal != nil {
              if predictedEnd > 300 || (endPos > 70 && predictedEnd > 0) { endingY = 300 }
              if predictedEnd < -300 || (endPos < 70 && predictedEnd < 0) { endingY = -300 }
            }
            
            let newPostsInBox = postsInBox.filter({ x in
              x.id != post.id
            })
            
            withAnimation(spring) {
              deleting = false
              dragging = false
              offsetY = endingY
              if endingY != 0 {
                postsInBox = newPostsInBox
              }
            }
          }
        }
    )
  }
}
