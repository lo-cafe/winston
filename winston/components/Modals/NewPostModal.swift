//
//  NewPostModal.swift
//  winston
//
//  Created by Igor Marcossi on 24/07/23.
//
import SwiftUI
import HighlightedTextEditor
import Defaults

class NewPostData: ObservableObject {
  @Published var text: String = ""
  @Published var debText: String = ""
  @Published var title: String = ""
  @Published var debTitle: String = ""
  @Published var url: String?
  @Published var debUrl: String?
  @Published var gallery: [NewPostGalleryItem]?
  //  @Published var debGallery: [NewPostGalleryItem]?
  @Published var flair: NewPostFlairData?
  //  @Published var debFlair: NewPostFlairData?
  
  init(delay: DispatchQueue.SchedulerTimeType.Stride) {
    $text.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debText)
    $title.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debTitle)
    $url.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debUrl)
    //    $gallery.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debGallery)
    //    $flair.debounce(for: delay, scheduler: DispatchQueue.main).assign(to: &$debFlair)
  }
}

struct NewPostFlairData: Codable {
  var id: String
  var text: String
}

struct NewPostGalleryItem: Codable {
  var caption: String
  var outbound_url: String
  var asset_id: String
}

struct NewPostModal: View {
  var subreddit: Subreddit
  @EnvironmentObject var redditAPI: RedditAPI
  @StateObject var postData = NewPostData(delay: 0.5)
  @State var alertExit = false
  @Environment(\.dismiss) var dismiss
  @Environment(\.managedObjectContext) private var viewContext
  @State var currentDraft: PostDraft?
  @State var editorHeight: CGFloat = 200
  @State var loading = false
  @State var postKind: RedditAPI.PostType = .text
  @State private var selection: PresentationDetent = .medium
  @Default(.newPostModalBlurBackground) var newPostModalBlurBackground
  
  @FetchRequest(sortDescriptors: []) var drafts: FetchedResults<PostDraft>
  
  func save() { try? viewContext.save() }
  
  var body: some View {
    let isEmpty = postData.text.isEmpty && postData.title.isEmpty && (postData.url?.isEmpty ?? true)
    NavigationView {
      VStack(alignment: .leading) {
        TextField("Title", text: $postData.title, prompt: Text("Post title"))
          .textFieldStyle(.plain)
          .fontSize(24, .bold)
          .padding(.horizontal, 2)
        
        if postKind == .link {
          HStack {
            Image(systemName: "link")
            TextField("", text: Binding(get: { postData.url ?? "" }, set: { postData.url = $0 }), prompt: Text(verbatim: "https://example.com"))
              .disableAutocorrection(true)
              .autocapitalization(.none)
              .textFieldStyle(.plain)
          }
          .fontSize(18, .medium)
          .padding(.horizontal, 12)
          .padding(.vertical, 8)
          .background(Capsule(style: .continuous).fill(Color(UIColor.tertiarySystemGroupedBackground).opacity(newPostModalBlurBackground ? 0.5 : 1)))
          .padding(.horizontal, 2)
        }
        
        HighlightedTextEditor(text: $postData.text, highlightRules: winstonMDEditorPreset)
          .introspect { editor in
            editor.textView.backgroundColor = .clear
          }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 8)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      //          .background(RR(16, .secondary.opacity(0.1)))
      .allowsHitTesting(!loading)
      .blur(radius: loading ? 24 : 0)
      .overlay(
          HStack {
            PillTab(icon: "⌨️", label: "Text", active: postKind == .text, onPress: {
              withAnimation(spring) {
                postKind = .text
              }
            })
            PillTab(icon: "🔗", label: "Link", active: postKind == .link, onPress: {
              withAnimation(spring) {
                postKind = .link
              }
            })
            PillTab(icon: "🖼️", label: "Image", active: postKind == .image, onPress: {
              withAnimation(spring) {
                postKind = .image
              }
            })
            PillTab(icon: "🎥", label: "Video", active: postKind == .video, onPress: {
              withAnimation(spring) {
                postKind = .video
              }
            })
          }
          .padding(.bottom, 12)
        , alignment: .bottom
      )
      .onChange(of: postData.debText) { currentDraft?.text = $0; save() }
      .onChange(of: postData.debTitle) { currentDraft?.title = $0; save() }
      .onChange(of: postData.debUrl) { currentDraft?.url = $0; save() }
      .onDisappear {
        if isEmpty, let currentDraft = currentDraft {
          viewContext.delete(currentDraft)
          try? viewContext.save()
        }
      }
      .onAppear {
        if let draftEntity = drafts.first(where: { draft in draft.subredditName == subreddit.data?.name }) {
          if let text = draftEntity.text { postData.text = text }
          if let title = draftEntity.title { postData.title = title }
          if let url = draftEntity.url { postData.url = url }
          currentDraft = draftEntity
        } else {
          let newDraft = PostDraft(context: viewContext)
          newDraft.timestamp = Date()
          newDraft.subredditName = subreddit.data?.name
          currentDraft = newDraft
        }
      }
      .navigationTitle("New post")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          HStack(spacing: 0) {
            MasterButton(icon: "trash.fill", mode: .subtle, color: .primary, textColor: .red, shrinkHoverEffect: true, height: 52, proportional: .circle, disabled: isEmpty) {
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
    //    .backport.presentationDetents([.medium,.large], selection: $selection)
    .presentationDetents([.large, .fraction(0.75), .medium, collapsedPresentation], selection: $selection)
    .presentationCornerRadius(32)
    .presentationBackgroundInteraction(.enabled)
    .if(newPostModalBlurBackground) { $0.presentationBackground(.regularMaterial) }
    .presentationDragIndicator(.hidden)
    //    .backport.presentationDragIndicator(.visible)
    //    .backport.interactiveDismissDisabled(alertExit) {
    //      alertExit = true
    //    }
  }
}

//struct CommentModal_Previews: PreviewProvider {
//    static var previews: some View {
//        CommentModal()
//    }
//}
