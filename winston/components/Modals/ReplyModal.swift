//
//  CommentModal.swift
//  winston
//
//  Created by Igor Marcossi on 02/07/23.
//

import SwiftUI
import HighlightedTextEditor
import Defaults
import NukeUI

class TextFieldObserver : ObservableObject {
  @Published var debouncedTeplyText: String
  @Published var replyText: String
  
  init(delay: DispatchQueue.SchedulerTimeType.Stride, text: String? = nil) {
    let initial = ""
    debouncedTeplyText = text ?? initial
    replyText = text ?? initial
    $replyText
      .debounce(for: delay, scheduler: DispatchQueue.main)
      .assign(to: &$debouncedTeplyText)
  }
}

struct EditReplyModalComment: View {
  @ObservedObject var comment: Comment
  
  func action(_ endLoading: (@escaping (Bool) -> ()), text: String) {
    if let _ = comment.typePrefix {
      Task(priority: .background) {
        let result = (await comment.edit(text)) ?? false
        await MainActor.run {
          withAnimation(spring) {
            endLoading(result)
          }
        }
      }
    }
  }
  
  var body: some View {
    ReplyModal(title: "Editing", loadingLabel: "Updating...", submitBtnLabel: "Update comment", thingFullname: comment.data?.name ?? "", action: action, text: comment.data?.body) {
      EmptyView()
    }
  }
}

struct ReplyModalComment: View {
  @ObservedObject var comment: Comment
  
  func action(_ endLoading: (@escaping (Bool) -> ()), text: String) {
    if let _ = comment.typePrefix {
      Task(priority: .background) {
        let result = await comment.reply(text)
        await MainActor.run {
          withAnimation(spring) {
            endLoading(result)
          }
        }
      }
    }
  }
  
  var body: some View {
    ReplyModal(thingFullname: comment.data?.name ?? "", action: action) {
      VStack {
        if let commentWinstonData = comment.winstonData {
          CommentLink(indentLines: 0, showReplies: false, comment: comment, commentWinstonData: commentWinstonData, children: comment.childrenWinston)
        }
//          .equatable()
      }
    }
  }
}

struct ReplyModalPost: View {
  var post: Post
  var updateComments: (()->())?
  
  func action(_ endLoading: (@escaping (Bool) -> ()), text: String) {
    Task(priority: .background) {
      let result = await post.reply(text, updateComments: updateComments)
      await MainActor.run {
        withAnimation(spring) {
          endLoading(result)
        }
      }
    }
  }
  
  var body: some View {
    ReplyModal(thingFullname: post.data?.name ?? "", action: action) {
      EmptyView()
    }
  }
}

struct ReplyModal<Content: View>: View {
  var loadingLabel: String
  var submitBtnLabel: String
  var thingFullname: String
  var title: String
  var action: ((@escaping (Bool) -> ()), String) -> ()
  let content: (() -> Content)?
  
  @ObservedObject private var globalLoader = TempGlobalState.shared.globalLoader
  
  @State private var alertExit = false
  @StateObject private var textWrapper: TextFieldObserver
  @Environment(\.dismiss) private var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @State private var currentDraft: ReplyDraft?
  @State private var editorHeight: CGFloat = 200
  @State private var loading = false
  @State private var selection: PresentationDetent = .medium
  @Environment(\.useTheme) private var selectedTheme
  @FetchRequest(sortDescriptors: []) var drafts: FetchedResults<ReplyDraft>
  @Environment(\.colorScheme) private var cs
  @ObservedObject var redditAPI = RedditAPI.shared
  
  init(title: String = "Replying", loadingLabel: String = "Commenting...", submitBtnLabel: String = "Send", thingFullname: String, action: @escaping (@escaping (Bool) -> Void, String) -> Void, text: String? = nil, content: (() -> Content)?) {
    self.title = title
    self.loadingLabel = loadingLabel
    self.submitBtnLabel = submitBtnLabel
    self.content = content
    self.thingFullname = thingFullname
    self.action = action
    self._textWrapper = StateObject(wrappedValue: TextFieldObserver(delay: 0.5, text: text))
  }
  
  var body: some View {
    NavigationView {
      ScrollView {
        VStack(spacing: 12) {
          
          VStack(alignment: .leading) {
            if let me = redditAPI.me?.data, let avatarLink = me.icon_img ?? me.snoovatar_img, let rootURL = rootURLString(avatarLink), let avatarURL = URL(string: rootURL) {
              BadgeOpt(avatarRequest: ImageRequest(url: avatarURL), badgeKit: .init(numComments: 0, ups: 0, saved: false, author: me.name, authorFullname: "t2_\(me.id)", userFlair: "", created: Date().timeIntervalSince1970), cs: cs, avatarURL: me.icon_img ?? me.snoovatar_img, theme: selectedTheme.comments.theme.badge)
            }
            MDEditor(text: $textWrapper.replyText)
          }
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .frame(maxWidth: .infinity, minHeight: 200)
          .background(RR(16, Color.secondary.opacity(0.1)))
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
        MasterButton(icon: "paperplane.fill", label: submitBtnLabel, height: 48, fullWidth: true, cornerRadius: 16) {
          withAnimation(spring) {
            dismiss()
          }
          globalLoader.enable(loadingLabel)
          action({ result in
            globalLoader.dismiss()
            if result {
              if let currentDraft = currentDraft {
                Task {
                  await viewContext.perform(schedule: .enqueued) {
                    viewContext.delete(currentDraft)
                    try? viewContext.save()
                  }
                }
              }
            }
          }, textWrapper.replyText)
        }
          .shrinkOnTap()
          .offset(y: loading || selection == collapsedPresentation ? 90 : 0)
          .animation(spring, value: selection)
          .padding(.horizontal, 16)
          .padding(.bottom, 8)
        , alignment: .bottom
      )
      .onChange(of: textWrapper.debouncedTeplyText, perform: { val in
        currentDraft?.replyText = val
        Task {
          await viewContext.perform(schedule: .enqueued) {
            try? viewContext.save()
          }
        }
      })
      .onDisappear {
        if textWrapper.replyText == "", let currentDraft = currentDraft {
          Task {
            await viewContext.perform(schedule: .enqueued) {
              viewContext.delete(currentDraft)
              try? viewContext.save()
            }
          }
        }
      }
      .onAppear {
        Task(priority: .background) {
          await RedditAPI.shared.fetchMe()
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
      .toolbar {
        ToolbarItem {
          HStack(spacing: 0) {
            MasterButton(icon: "trash.fill", mode: .subtle, color: .primary, textColor: .red, shrinkHoverEffect: true, height: 52, proportional: .circle, disabled: textWrapper.replyText == "") {
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
                    Task {
                      await viewContext.perform(schedule: .enqueued) {
                        viewContext.delete(currentDraft)
                        try? viewContext.save()
                      }
                    }
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
      .navigationBarTitleDisplayMode(.inline)
      .navigationTitle(title)
    }
    .background(
      !selectedTheme.general.modalsBG.blurry
      ? nil
      : GeometryReader { geo in
        selectedTheme.general.modalsBG.color.cs(cs).color()
          .frame(width: geo.size.width, height: geo.size.height)
      }
        .edgesIgnoringSafeArea(.all)
    )
    .presentationBackground(selectedTheme.general.modalsBG.blurry ? AnyShapeStyle(.bar) : AnyShapeStyle(selectedTheme.general.modalsBG.color.cs(cs).color()))
    .presentationDetents([.large, .fraction(0.75), .medium, collapsedPresentation], selection: $selection)
    .presentationCornerRadius(32)
    .presentationBackgroundInteraction(.enabled)
    .presentationDragIndicator(.hidden)
  }
}
