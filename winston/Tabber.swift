//
//  Tabber.swift
//  winston
//
//  Created by Igor Marcossi on 24/06/23.
//

import SwiftUI
import Defaults
import SpriteKit

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
  @Published var tabBarHeight: CGFloat? = nil
  @Published var inAppBrowserURL: URL? = nil
}

enum TabIdentifier {
  case posts, inbox, me, search, settings
}

class TabPayload: ObservableObject {
  @Published var reset = false
  var router = Router(id: "FeedThemingPanel")
  
  init(_ id: String, reset: Bool = false) {
    self.reset = reset
    self.router = Router(id: id)
  }
}

struct Tabber: View {
  @ObservedObject var tempGlobalState = TempGlobalState.shared
  @ObservedObject var errorAlert = Oops.shared
  @State var activeTab = TabIdentifier.posts
  @EnvironmentObject var redditAPI: RedditAPI
  @State var credModalOpen = false

//  @State var tabBarHeight: CGFloat?
  @StateObject private var inboxPayload = TabPayload("inboxRouter")
  @StateObject private var mePayload = TabPayload("meRouter")
  @StateObject private var postsPayload = TabPayload("postsRouter")
  @StateObject private var searchPayload = TabPayload("searchRouter")
  @State private var settingsPayload = TabPayload("settingsRouter")
  @Environment(\.useTheme) private var currentTheme
  @Environment(\.colorScheme) private var colorScheme
  @Default(.showUsernameInTabBar) private var showUsernameInTabBar
  @Default(.showTestersCelebrationModal) private var showTestersCelebrationModal
  @Default(.showTipJarModal) private var showTipJarModal
  
  var payload: [TabIdentifier:TabPayload] { [
    .inbox: inboxPayload,
    .me: mePayload,
    .posts: postsPayload,
    .search: searchPayload,
    .settings: settingsPayload,
  ] }
  
  func meTabTap() {
    if activeTab == .me {
      payload[.me]!.reset.toggle()
    } else {
      activeTab = .me
    }
  }
  
  init(theme: WinstonTheme, cs: ColorScheme) {
    Tabber.updateTabAndNavBar(tabTheme: theme.general.tabBarBG, navTheme: theme.general.navPanelBG, cs)
  }
  
  static func updateTabAndNavBar(tabTheme: ThemeForegroundBG, navTheme: ThemeForegroundBG, _ cs: ColorScheme) {
    let toolbarAppearence = UINavigationBarAppearance()
    if !navTheme.blurry {
      toolbarAppearence.configureWithOpaqueBackground()
    }
    toolbarAppearence.backgroundColor = UIColor(navTheme.color.cs(cs).color())
    UINavigationBar.appearance().standardAppearance = toolbarAppearence
    let transparentAppearence = UITabBarAppearance()
    if !tabTheme.blurry {
      transparentAppearence.configureWithOpaqueBackground()
    }
    transparentAppearence.backgroundColor = UIColor(tabTheme.color.cs(cs).color())
    UITabBar.appearance().standardAppearance = transparentAppearence
  }
  
  var body: some View {
    let tabBarHeight = tempGlobalState.tabBarHeight
    let tabHeight = (tabBarHeight ?? 0) - getSafeArea().bottom
    TabView(selection: $activeTab.onUpdate { newTab in if activeTab == newTab { payload[newTab]!.reset.toggle() } }) {
      
      SubredditsStack(reset: payload[.posts]!.reset, router: payload[.posts]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tempGlobalState.tabBarHeight = tabBar.bounds.height }
        })
        .tag(TabIdentifier.posts)
        .tabItem {
          VStack {
            Image(systemName: "doc.text.image")
            Text("Posts")
          }
        }
      
      Inbox(reset: payload[.inbox]!.reset, router: payload[.inbox]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tempGlobalState.tabBarHeight = tabBar.bounds.height }
        })
        .tag(TabIdentifier.inbox)
        .tabItem {
          VStack {
            Image(systemName: "bell.fill")
            Text("Inbox")
          }
        }
      
      Me(reset: payload[.me]!.reset, router: payload[.me]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tempGlobalState.tabBarHeight = tabBar.bounds.height }
        })
        .tag(TabIdentifier.me)
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
      
      Search(reset: payload[.search]!.reset, router: payload[.search]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tempGlobalState.tabBarHeight = tabBar.bounds.height }
        })
        .tag(TabIdentifier.search)
        .tabItem {
          VStack {
            Image(systemName: "magnifyingglass")
            Text("Search")
          }
        }
      
      Settings(reset: payload[.settings]!.reset, router: payload[.settings]!.router)
        .background(TabBarAccessor { tabBar in
          if tabBarHeight != tabBar.bounds.height { tempGlobalState.tabBarHeight = tabBar.bounds.height }
        })
        .tag(TabIdentifier.settings)
        .tabItem {
          VStack {
            Image(systemName: "gearshape.fill")
            Text("Settings")
          }
        }
      
    }
    .replyModalPresenter()
    .overlay(
      GeometryReader { geo in
        GlobalLoaderView()
          .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
      }
        .ignoresSafeArea(.keyboard)
      , alignment: .bottom
    )
    .overlay(
      tabBarHeight.isNil
      ? nil
      : TabBarOverlay(router: payload[activeTab]!.router, tabHeight: tabHeight, meTabTap: meTabTap).id(payload[activeTab]!.router.id)
      , alignment: .bottom
    )
    .background(OFWOpener(router: payload[TabIdentifier.posts]!.router))
    .fullScreenCover(isPresented: Binding(get: { !tempGlobalState.inAppBrowserURL.isNil }, set: { val in
      tempGlobalState.inAppBrowserURL = nil
    })) {
      SafariWebView(url: URL(string: "https://sarunw.com")!)
        .ignoresSafeArea()
    }
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
//    .onChange(of: currentTheme.general.tabBarBG, perform: { val in
//      Tabber.updateTabAndNavBar(tabTheme: val, navTheme: currentTheme.general.navPanelBG, colorScheme)
//    })
//    .onChange(of: currentTheme.general.navPanelBG, perform: { val in
//      Tabber.updateTabAndNavBar(tabTheme: currentTheme.general.tabBarBG, navTheme: val, colorScheme)
//    })
    .onChange(of: redditAPI.loggedUser) { user in
      if user.apiAppID == nil || user.apiAppSecret == nil {
        withAnimation(spring) {
          credModalOpen = true
        }
      }
    }
    .onOpenURL { url in
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
    .accentColor(currentTheme.general.accentColor.cs(colorScheme).color())
//    .id(currentTheme.general.tabBarBG)
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
        Task(priority: .background) {
          self.callback(tabBar.tabBar)
        }
      }
    }
  }
}
