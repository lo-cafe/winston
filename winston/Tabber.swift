//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import _SpriteKit_SwiftUI

class Oops: ObservableObject {
  static var shared = Oops()
  @Published var asking = false
  @Published var error: String?
  
  func sendError(_ error: Any) {
    DispatchQueue.main.async {
      Oops.shared.asking = true
      Oops.shared.error = String(reflecting: error)
    }
  }
}

class TempGlobalState: ObservableObject {
  static var shared = TempGlobalState()
  @Published var globalLoader = GlobalLoader()
}

enum TabIdentifier {
  case posts, inbox, me, search, settings
}

struct TabPayload {
  var reset = false
  var router = Router()
}

struct Tabber: View {
  @ObservedObject var tempGlobalState = TempGlobalState.shared
  @ObservedObject var errorAlert = Oops.shared
  @State var activeTab = TabIdentifier.posts
  @EnvironmentObject var redditAPI: RedditAPI
  @State var credModalOpen = false
  @State var choosingAccount = false
  @State var accountDrag: CGSize = .zero
  @State var tabBarHeight: CGFloat?
  @State private var morph = MorphingGradientCircleScene()
  @State var medium = UIImpactFeedbackGenerator(style: .soft)
  @State var payload: [TabIdentifier:TabPayload] = [
    .inbox: TabPayload(),
    .me: TabPayload(),
    .posts: TabPayload(),
    .search: TabPayload(),
    .settings: TabPayload(),
  ]
  @Default(.postsInBox) var postsInBox
  @Default(.showUsernameInTabBar) var showUsernameInTabBar
  @Default(.showTestersCelebrationModal) var showTestersCelebrationModal
  @Default(.showTipJarModal) var showTipJarModal
  
  var body: some View {
    let tabHeight = (tabBarHeight ?? 0) - getSafeArea().bottom
    TabView(selection: $activeTab.onUpdate { newTab in if activeTab == newTab { payload[newTab]!.reset.toggle() } }) {
      
      Subreddits(reset: payload[.posts]!.reset, router: payload[.posts]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tabBarHeight = tabBar.bounds.height }
        })
        .tabItem {
          VStack {
            Image(systemName: "doc.text.image")
            Text("Posts")
          }
        }
        .tag(TabIdentifier.posts)
      
      Inbox(reset: payload[.inbox]!.reset, router: payload[.inbox]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tabBarHeight = tabBar.bounds.height }
        })
        .tabItem {
          VStack {
            Image(systemName: "bell.fill")
            Text("Inbox")
          }
        }
        .tag(TabIdentifier.inbox)
      
      Me(reset: payload[.me]!.reset, router: payload[.me]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tabBarHeight = tabBar.bounds.height }
        })
        .tabItem {
          VStack {
            Image(systemName: "person.fill")
            if showUsernameInTabBar, let me = redditAPI.me, let data = me.data {
              Text(data.name)
            } else {
              Text("Me")
            }
          }
        }
        .tag(TabIdentifier.me)
      
      Search(reset: payload[.search]!.reset, router: payload[.search]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tabBarHeight = tabBar.bounds.height }
        })
        .tabItem {
          VStack {
            Image(systemName: "magnifyingglass")
            Text("Search")
          }
        }
        .tag(TabIdentifier.search)
      
      Settings(reset: payload[.settings]!.reset, router: payload[.settings]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tabBarHeight = tabBar.bounds.height }
        })
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
            Text("Settings")
          }
        }
        .tag(TabIdentifier.settings)
      
    }
    .replyModalPresenter()
    .overlay(
      GlobalLoaderView()
      , alignment: .bottom
    )
    .overlay(
      tabBarHeight.isNil
      ? nil
      : GeometryReader { geo in
        Color.clear
          .frame(maxWidth: UIScreen.screenWidth / 5, minHeight: tabHeight, maxHeight: tabHeight)
          .overlay(
            !choosingAccount
            ? nil
            //          : BlurRadialGradientView()
            //                      .frame(width: 150, height: 150)
            //                      .clipShape(Circle())
            //          Circle()
            //            .fill(RadialGradient(gradient: Gradient(colors: [.blue, .blue.opacity(0)]), center: .center, startRadius: 0, endRadius: 150))
            //            .opacity(choosingAccount ? 0.75 : 0)
            //            .frame(width: 300, height: 300)
            //            .allowsHitTesting(false)
            
            : ZStack {
              Circle()
                .fill( RadialGradient(
                  gradient: Gradient(stops: [
                    .init(color: Color.cyan, location: 0),
                    .init(color: Color.cyan.opacity(0.972), location: 0.044),
                    .init(color: Color.cyan.opacity(0.924), location: 0.083),
                    .init(color: Color.cyan.opacity(0.861), location: 0.121),
                    .init(color: Color.cyan.opacity(0.786), location: 0.159),
                    .init(color: Color.cyan.opacity(0.701), location: 0.197),
                    .init(color: Color.cyan.opacity(0.609), location: 0.238),
                    .init(color: Color.cyan.opacity(0.514), location: 0.284),
                    .init(color: Color.cyan.opacity(0.419), location: 0.335),
                    .init(color: Color.cyan.opacity(0.326), location: 0.395),
                    .init(color: Color.cyan.opacity(0.239), location: 0.463),
                    .init(color: Color.cyan.opacity(0.161), location: 0.542),
                    .init(color: Color.cyan.opacity(0.095), location: 0.634),
                    .init(color: Color.cyan.opacity(0.044), location: 0.74),
                    .init(color: Color.cyan.opacity(0.012), location: 0.861),
                    .init(color: Color.cyan.opacity(0), location: 1)
                  ]),
                  center: .center,
                  startRadius: 0,
                  endRadius: 300
                ))
                .opacity(0.5)
                .frame(width: 600, height: 600)
              VStack(spacing: 6) {
                Image("winstonNoBG")
                  .resizable()
                  .scaledToFit()
                  .frame(width: 60, height: 60)
                Text("Account switcher\ncoming soon...")
                  .fontSize(15, .medium)
                  .opacity(1)
              }
              .offset(y: -100)
              SpriteView(scene: morph, transition: nil, isPaused: false, preferredFramesPerSecond: UIScreen.main.maximumFramesPerSecond, options: [.allowsTransparency, .ignoresSiblingOrder])
                .frame(width: 600, height: 600)
                .blur(radius: 32)
                .offset(accountDrag)
                .transition(.scale.combined(with: .opacity))
            }
              .multilineTextAlignment(.center)
              .allowsHitTesting(false)
          )
          .contentShape(Rectangle())
          .onTapGesture {
            activeTab = .me
          }
          .gesture(
            LongPressGesture()
              .onEnded({ val in
                medium.prepare()
                medium.impactOccurred(intensity: 1)
                withAnimation(spring) {
                  choosingAccount = true
                }
              })
              .sequenced(before: DragGesture(minimumDistance: 0))
              .onChanged { sequence in
                switch sequence {
                case .first(_):
                  break
                case .second(_, let dragVal):
                  if let dragVal = dragVal {
                    accountDrag = dragVal.translation
                  }
                }
              }
              .onEnded({ sequence in
                switch sequence {
                case .first(_):
                  break
                case .second(_, let dragVal):
                  withAnimation(spring) {
                    choosingAccount = false
                    accountDrag = .zero
                  }
                }
              })
          )
          .frame(width: geo.size.width, height: tabHeight)
          .contentShape(Rectangle())
          .swipeAnywhere(router: payload[activeTab]!.router, forceEnable: true)
          .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
        .ignoresSafeArea(.keyboard)
      , alignment: .bottom
    )
    .background(OFWOpener(router: payload[TabIdentifier.posts]!.router))
    .environmentObject(tempGlobalState)
    .alert("OMG! Winston found a squirky bug!", isPresented: $errorAlert.asking) {
      Button("Gratefully accept the weird gift") {
        if let error = errorAlert.error {
          sendEmail(error)
        }
        errorAlert.error = nil
        errorAlert.asking = false
      }
      Button("Ignore the cat", role: .cancel) {
        errorAlert.error = nil
        errorAlert.asking = false
      }
    } message: {
      Text("Something went wrong, but winston's is a fast cat, got the bug in his fangs and brought it to you. What do you wanna do?")
    }
    .onAppear {
      if showTestersCelebrationModal {
        showTipJarModal = false
      }
      if Defaults[.multis].count != 0 || Defaults[.subreddits].count != 0 {
        Defaults[.multis] = []
        Defaults[.subreddits] = []
      }
      Task(priority: .background) { await updatePostsInBox(redditAPI) }
      if redditAPI.loggedUser.apiAppID == nil || redditAPI.loggedUser.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      } else if redditAPI.loggedUser.accessToken != nil && redditAPI.loggedUser.refreshToken != nil {
        Task(priority: .background) {
          await redditAPI.fetchMe(force: true)
        }
      }
    }
    .onChange(of: redditAPI.loggedUser) { user in
      if user.apiAppID == nil || user.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      }
    }
    .onOpenURL { url in
      print("here")
      let parsed = parseRedditURL(url.absoluteString)
      withAnimation {
        switch parsed {
        case .post(_, _):
          OpenFromWeb.shared.data = parsed
          activeTab = .posts
        case .subreddit(_):
          OpenFromWeb.shared.data = parsed
          activeTab = .posts
        case .user(_):
          OpenFromWeb.shared.data = parsed
          activeTab = .posts
        default:
          break
        }
      }
    }
    .sheet(isPresented: $showTestersCelebrationModal) {
      TestersCelebration()
    }
    .sheet(isPresented: $showTipJarModal) {
      TipJar()
    }
    .sheet(isPresented: $credModalOpen) {
      Onboarding(open: $credModalOpen)
        .interactiveDismissDisabled(true)
    }
  }
}


struct BlurRadialGradientView: UIViewRepresentable {
  func makeUIView(context: Context) -> UIView {
    let view = UIView()
    addBlurWithGradient(view: view)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: Context) {
  }
  
  private func addBlurWithGradient(view: UIView) {
    let gradient = CAGradientLayer()
    gradient.frame = view.bounds
    gradient.colors = [UIColor.blue.cgColor, UIColor.blue.withAlphaComponent(0.0).cgColor]
    gradient.startPoint = CGPoint(x: 0.5, y: 0.5)
    gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
    gradient.locations = [0, 1]
    
    let blurEffect = UIBlurEffect.init(style: .systemMaterial)
    let visualEffectView = UIVisualEffectView.init(effect: blurEffect)
    visualEffectView.frame = gradient.bounds
    
    gradient.mask = visualEffectView.layer
    view.layer.addSublayer(gradient)
  }
}

struct TabBarAccessor: UIViewControllerRepresentable {
  var callback: (UITabBar) -> Void
  private let proxyController = ViewController()
  
  func makeUIViewController(context: UIViewControllerRepresentableContext<TabBarAccessor>) ->
  UIViewController {
    proxyController.callback = callback
    return proxyController
  }
  
  func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<TabBarAccessor>) {
  }
  
  typealias UIViewControllerType = UIViewController
  
  private class ViewController: UIViewController {
    var callback: (UITabBar) -> Void = { _ in }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      if let tabBar = self.tabBarController {
        self.callback(tabBar.tabBar)
      }
    }
  }
}
