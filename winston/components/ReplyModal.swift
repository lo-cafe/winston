//
//  CommentModal.swift
//  winston
//
//  Created by Igor Marcossi on 02/07/23.
//

import SwiftUI
import HighlightedTextEditor
import SwiftUIBackports

//class ReplyModalContent: Equatable, ObservableObject, Identifiable {
//  static func ==(lhs: ReplyModalContent, rhs: ReplyModalContent) -> Bool {
//    return lhs.id == rhs.id
//  }
//  @Published var comment: Comment?
//  var id: String {
//    return comment?.id ?? UUID().uuidString
//  }
//}

class TextFieldObserver : ObservableObject {
  
  @Published var debouncedTeplyText = ""
  @Published var replyText = ""
  
  init(delay: DispatchQueue.SchedulerTimeType.Stride) {
    $replyText
      .debounce(for: delay, scheduler: DispatchQueue.main)
      .assign(to: &$debouncedTeplyText)
  }
}

struct ReplyModalComment: View {
  @ObservedObject var comment: Comment
  @State var disableScroll = false
  var body: some View {
    ReplyModal(thingFullname: comment.data?.name ?? "", action: { endLoading, text in
      if let _ = comment.typePrefix {
        Task {
          let result = await comment.reply(text)
          await MainActor.run {
            withAnimation(spring) {
              endLoading(result)
            }
          }
        }
      }
    }) {
      VStack {
        CommentLink(indentLines: 0, disableScroll: $disableScroll, showReplies: false, comment: comment)
      }
    }
  }
}

struct ReplyModalPost: View {
  @ObservedObject var post: Post
  var body: some View {
    ReplyModal(thingFullname: post.data?.name ?? "", action: { endLoading, text in
      Task {
        let result = await post.reply(text)
        await MainActor.run {
          withAnimation(spring) {
            endLoading(result)
          }
        }
      }
    }) {
      EmptyView()
    }
  }
}

struct ReplyModal<Content: View>: View {
  var thingFullname: String
  var action: ((@escaping (Bool) -> ()), String) -> ()
  @EnvironmentObject var redditAPI: RedditAPI
  @State var alertExit = false
  @StateObject var textWrapper = TextFieldObserver(delay: 0.5)
  @Environment(\.backportDismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @State var currentDraft: ReplyDraft?
  @State var editorHeight: CGFloat = 200
  @State var loading = false
  @State var disableScroll = false
  @State private var selection: Backport.PresentationDetent = .medium
  
  @FetchRequest(sortDescriptors: []) var drafts: FetchedResults<ReplyDraft>
  var content: (() -> Content)?
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 12) {
          
          VStack(alignment: .leading) {
            if let me = redditAPI.me?.data {
              Badge(author: me.name, fullname: me.name, created: Date().timeIntervalSince1970, avatarURL: me.icon_img ?? me.snoovatar_img)
            }
            HighlightedTextEditor(text: $textWrapper.replyText, highlightRules: .markdown)
              .introspect { editor in
                editor.textView.backgroundColor = .clear
              }
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity, minHeight: 200)
          .background(RR(16, .secondary.opacity(0.1)))
          .allowsHitTesting(!loading)
          .blur(radius: loading ? 24 : 0)
          .overlay(
            !loading
            ? nil
            : ProgressView()
              .progressViewStyle(.circular)
          )
          
          if let content = content {
            content()
          }
          
            
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 68)
      }
      .overlay(
        MasterButton(icon: "paperplane.fill", label: "Send", height: 48, fullWidth: true, cornerRadius: 16) {
          withAnimation { loading = true }
          action({ result in
            withAnimation { loading = false }
            if result {
              if result { dismiss() }
              if let currentDraft = currentDraft {
                viewContext.delete(currentDraft)
                try? viewContext.save()
              }
            }
          }, textWrapper.replyText)
        }
          .shrinkOnTap()
          .offset(y: loading ? 64 : 0)
          .padding(.horizontal, 16)
          .padding(.bottom, 8)
        , alignment: .bottom
      )
      .onChange(of: textWrapper.debouncedTeplyText, perform: { val in
        currentDraft?.replyText = val
        try? viewContext.save()
      })
      .onDisappear {
        if textWrapper.replyText == "", let currentDraft = currentDraft {
          viewContext.delete(currentDraft)
          try? viewContext.save()
        }
      }
      .onAppear {
        Task {
          await redditAPI.fetchMe()
        }
        if let draftEntity = drafts.first(where: { draft in draft.thingID == thingFullname }) {
          if let draftText = draftEntity.replyText {
            textWrapper.replyText = draftText
          }
          currentDraft = draftEntity
        } else {
          let newDraft = ReplyDraft(context: viewContext)
          newDraft.timestamp = Date()
          newDraft.thingID = thingFullname
          currentDraft = newDraft
        }
      }
      .backport.navigationTitle("Replying")
      .navigationBarTitleDisplayMode(.inline)
      .backport.toolbar {
        Backport.ToolbarItem {
          HStack(spacing: 0) {
            MasterButton(icon: "trash.fill", mode: .subtle, color: .primary, textColor: .red, shrinkHoverEffect: true, height: 52, proportional: .circle) {
              withAnimation(spring) {
                alertExit = true
              }
            }
            .actionSheet(isPresented: $alertExit) {
              ActionSheet(title: Text("Are you sure you wanna discard?"), buttons: [
                .default(Text("Yes")) {
                  withAnimation(spring) {
                    dismiss()
                  }
                  if let currentDraft = currentDraft {
                    viewContext.delete(currentDraft)
                    try? viewContext.save()
                  }
                },
                .cancel()
              ])
            }
            
            MasterButton(icon: "chevron.down", mode: .subtle, color: .primary, textColor: .primary, shrinkHoverEffect: true, height: 52, proportional: .circle) {
              withAnimation(spring) {
                dismiss()
              }
            }
            
          }
        }
      }
    }
    .backport.presentationDetents([.medium,.large], selection: $selection)
    .backport.presentationCornerRadius(32)
    .backport.presentationBackgroundInteraction(.enabled)
    //    .backport.presentationDragIndicator(.visible)
    .backport.interactiveDismissDisabled(alertExit) {
      alertExit = true
    }
  }
}

//struct CommentModal_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentModal()
//    }
//}
