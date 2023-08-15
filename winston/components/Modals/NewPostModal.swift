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

private let bgFieldColor: Color = .primary.opacity(0.1)

struct FlairButton: View {
  var selected: Bool
  var onSelect: (Flair) -> ()
  var flair: Flair
  var body: some View {
    let bgColor = Color.hex(flair.background_color ?? "ffffff")
    let brightness = bgColor.brightness()
    let contrastColor = brightness > 0.5 ? bgColor.darken(0.75) : bgColor.lighten(0.9)
    HStack {
      Circle()
        .fill(selected ? contrastColor : Color.hex(flair.background_color ?? "ffffff"))
        .frame(width: 8, height: 8)
      Text(flair.text ?? "unnamed flair")
        .foregroundColor(selected ? contrastColor : .primary)
    }
    .padding(.horizontal, 8)
    .padding(.vertical, 4)
    .background(Capsule(style: .continuous).fill(selected ? Color.hex(flair.background_color ?? "ffffff") : .primary.opacity(0.075)))
    .mask(Capsule(style: .continuous).fill(.black))
    .transition(.opacity)
    .allowsHitTesting(!selected)
    .onTapGesture {
      onSelect(flair)
    }
  }
}

struct FlairPicker: View {
  @ObservedObject var subreddit: Subreddit
  @Binding var selectedFlair: Flair?
  //  @State var searchQuery = ""
  @StateObject var searchQuery = DebouncedText(delay: 0.25)
  @FocusState var focused: Bool
  @State var searching = false
  
  func selectFlair(_ flair: Flair) {
    withAnimation(spring) {
      selectedFlair = flair
    }
  }
  var body: some View {
    let fadeWidth: CGFloat = 16
    if subreddit.data?.winstonFlairs == nil || (subreddit.data?.winstonFlairs?.count ?? 0) != 0 {
      HStack(spacing: 4) {
        HStack {
          HStack {
            Button {
              withAnimation(spring) {
                searching = true
              }
              doThisAfter(0) {
                focused = true
              }
            } label: {
              Image(systemName: "magnifyingglass")
            }
            .shrinkOnTap()
            if searching {
              TextField("", text: $searchQuery.text, prompt: Text("Search"))
                .focused($focused)
                .fixedSize(horizontal: true, vertical: false)
            }
          }
          .padding(.horizontal, 12)
          .padding(.trailing, searching ? 6 : 0)
          .frame(height: 42)
          .background(Capsule(style: .continuous).fill(bgFieldColor))
          .mask(Capsule(style: .continuous).fill(.black))
          
          if let selectedFlair = selectedFlair, !searching {
            FlairButton(selected: true, onSelect: selectFlair, flair: selectedFlair)
              .padding(.trailing, 4)
          }
        }
        
        ScrollView(.horizontal, showsIndicators: false) {
          HStack {
            if let flairs = subreddit.data?.winstonFlairs {
              if searchQuery.debounced.isEmpty {
                ForEach(flairs.filter({ $0 != selectedFlair })) { flair in
                  FlairButton(selected: selectedFlair == flair, onSelect: selectFlair, flair: flair)
                }
              } else {
                ForEach(flairs.filter({ ($0.text?.lowercased() ?? "").contains(searchQuery.debounced.lowercased()) })) { flair in
                  FlairButton(selected: selectedFlair == flair, onSelect: selectFlair, flair: flair)
                }
              }
            } else {
              ProgressView()
            }
          }
          .padding(.horizontal, 12)
          .animation(spring, value: searchQuery.debounced)
        }
        .mask(
          HStack(spacing: 0) {
            Rectangle()
              .fill(LinearGradient(
                gradient: Gradient(stops: [
                  .init(color: Color.black.opacity(1), location: 0),
                  .init(color: Color.black.opacity(0), location: 1)
                ]),
                startPoint: .trailing,
                endPoint: .leading
              ))
              .frame(minWidth: fadeWidth, maxWidth: fadeWidth, maxHeight: .infinity)
            Rectangle()
              .fill(.black)
              .frame(maxWidth: .infinity, maxHeight: .infinity)
            Rectangle()
              .fill(LinearGradient(
                gradient: Gradient(stops: [
                  .init(color: Color.black.opacity(1), location: 0),
                  .init(color: Color.black.opacity(0), location: 1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
              ))
              .frame(minWidth: fadeWidth, maxWidth: fadeWidth, maxHeight: .infinity)
          }
        )
        .scrollDismissesKeyboard(.never)
      }
      .padding(.leading, 16)
      .frame(maxWidth: .infinity)
      .onChange(of: focused) { newValue in
        if !newValue {
          withAnimation(spring) { searching = false }
          doThisAfter(0) {
            withAnimation {
              searchQuery.text = ""
              searchQuery.debounced = ""
            }
          }
        }
      }
    }
  }
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
  @State var selectedFlair: Flair?
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
          .padding(.horizontal, 16)
        
        FlairPicker(subreddit: subreddit, selectedFlair: $selectedFlair)
        
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
          .background(Capsule(style: .continuous).fill(bgFieldColor))
          .padding(.horizontal, 2)
          .padding(.horizontal, 16)
        }
        
        MDEditor(text: $postData.text)
          .padding(.horizontal, 16)
      }
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
          if let data = subreddit.data, let allowImgs = data.allow_images, allowImgs {
            PillTab(icon: "🖼️", label: "Image", active: postKind == .image, onPress: {
              withAnimation(spring) {
                postKind = .image
              }
            })
          }
          if let data = subreddit.data, let allowVideos = data.allow_videos, allowVideos {
            PillTab(icon: "🎥", label: "Video", active: postKind == .video, onPress: {
              withAnimation(spring) {
                postKind = .video
              }
            })
          }
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
        Task(priority: .background) {
          await subreddit.getFlairs()
        }
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
      .navigationTitle("New post")
      .navigationBarTitleDisplayMode(.inline)
    }
    .scrollDismissesKeyboard(.immediately)
    //    .backport.presentationDetents([.medium,.large], selection: $selection)
    .presentationDetents([.large, .fraction(0.75), .medium, collapsedPresentation], selection: $selection)
    .presentationCornerRadius(32)
    .presentationBackgroundInteraction(.enabled)
    .presentationBackground(newPostModalBlurBackground ? AnyShapeStyle(.bar) : AnyShapeStyle(Color.listBG))
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
