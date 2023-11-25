//
//  ChangeAuthAPIKey.swift
//  winston
//
//  Created by Igor Marcossi on 09/07/23.
//

import SwiftUI

struct SmallStep<Content: View>: View {
    let content: () -> Content
    var body: some View {
      VStack (alignment: .leading) {
          content()
      }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(RR(16, Color.black.opacity(0.1)))
      .padding(.horizontal, -8)
      .fontSize(15)
    }
}
struct CardStep<Content: View>: View {
  var currentStep: Int
  var title: String
  var subTitle: String
  @Binding var step: Int
    let content: () -> Content
    var body: some View {
      VStack (alignment: .leading) {
          HStack(spacing: 8) {
            Group {
              if step <= currentStep {
                Text("\(currentStep)")
                  .frame(width: 20, height: 20)
                  .background(Circle().fill(step < currentStep ? .gray : .blue))
                  .fontSize(13, .semibold)
              } else {
                Image(systemName: "checkmark.circle.fill")
                  .foregroundColor(.green)
              }
            }
            .transition(.fadeBlur)
            
            Text(title)
          }
          .frame(maxWidth: .infinity, alignment: .leading)
          .fontSize(18, .semibold)
        if step == currentStep {
          content()
//          HStack {
//            if step > 1 {
//              MasterButton(label: "Back") {
//                withAnimation(spring) {
//                  step -= 1
//                }
//              }
//            }
//            MasterButton(label: "Next") {
//              withAnimation(spring) {
//                step += 1
//              }
//            }
//          }
        }
      }
      .compositingGroup()
      .opacity(step < currentStep ? 0.5 : 1)
      .padding(.horizontal, 20)
      .padding(.vertical, 16)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(RR(20, .secondary.opacity(0.15)))
      .mask(RR(20, .black))
      .shadow(radius: step == currentStep ? 16 : 0)
    }
}

struct CopiableValue: View {
  var value: String
  @State var copied = false
  var body: some View {
    HStack {
      Text("Tap to copy")
        .multilineTextAlignment(.leading)
      Spacer()
      Text(value)
        .multilineTextAlignment(.trailing)
    }
      .padding(.vertical, 12)
      .padding(.horizontal, 16)
      .opacity(0.75)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(RoundedRectangle(cornerRadius: 16, style: .continuous).fill(.ultraThinMaterial))
      .overlay(
        !copied
        ? nil
        : Text("Copied!")
          .foregroundColor(.white)
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(RR(16, Color.black.opacity(0.5)))
      )
      .fontSize(15)
      .onTapGesture {
        UIPasteboard.general.string = value
        withAnimation {
          copied = true
        }
        doThisAfter(1.0) {
          withAnimation {
            copied = false
          }
        }
      }
  }
}

struct ChangeAuthAPIKey: View {
  @Environment(\.openURL) var openURL
  @Binding var open: Bool
  @State var appID: String = ""
  @State var appSecret: String = ""
  @State var step = 1
  @State var loadingCallback = false
  
  
  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        Text("API Credentials Setup")
          .fontSize(28, .bold)
        
        VStack(alignment: .leading, spacing: 16) {
          
          CardStep(currentStep: 1, title: "Getting credentials", subTitle: "Generating your own API credentials", step: $step) {
            VStack (alignment: .leading) {
              Text("In order to be able to use Reddit, you'll need to provide your own API credentials.")
              Text("Don't worry, there will be no costs, there's a free tier of 100 requests/minute and it's kinda impossible for you to go beyond that.")
              
              SmallStep {
                VStack (alignment: .leading) {
                  Text("Open Reddit's apps settings by clicking this button:")
                  MasterButton(label: "Reddit apps settings", height: 40, fullWidth: true) {
                    openURL(URL(string: "https://www.reddit.com/prefs/apps")!)
                  }
                }
              }
              .fixedSize(horizontal: false, vertical: true)
                SmallStep {
                  VStack (alignment: .leading) {
                    Text("Scroll down and click")
                    Image("createAppButton")
                      .resizable()
                      .scaledToFit()
                      .frame(maxWidth: .infinity)
                      .mask(RR(12, Color.black))
                    
                  }
                }
                .fixedSize(horizontal: false, vertical: true)
                SmallStep {
                  VStack (alignment: .leading) {
                    Text("Check \"web app\":")
                    Image("webAppRadio")
                      .resizable()
                      .scaledToFill()
                      .frame(maxWidth: .infinity, maxHeight: 72, alignment: .top)
                      .mask(RR(12, Color.black))
                  }
                }
              .fixedSize(horizontal: false, vertical: true)
              
              SmallStep {
                VStack (alignment: .leading) {
                  Text("Tap the URL below to copy and paste it in the \"redirect uri\" field:")
                  CopiableValue(value: "https://winston.cafe/auth-success")
                }
              }
              .fixedSize(horizontal: false, vertical: true)
              
              SmallStep {
                HStack (alignment: .top) {
                  Text("Fill the other fields however you want and click:")
                  Image("saveAppButton")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: 150)
                    .mask(RR(12, Color.black))
                }
              }
              .fixedSize(horizontal: false, vertical: true)
              
              MasterButton(label: "Next", height: 44, fullWidth: true) {
                withAnimation(spring) {
                  step += 1
                }
              }
            }
          }
          
          CardStep(currentStep: 2, title: "Granting access", subTitle: "Input your API credentials:", step: $step) {
            Group {
              SmallStep {
                VStack (alignment: .leading) {
//                  HStack {
                  Image("appIDLocation")
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity, maxHeight: 72)
                    .mask(RR(12, Color.black))
                    .frame(maxWidth: .infinity)
                    Text("In the new app you created, find the app ID and paste it below:")
//                  }
                  TextField("App ID", text: $appID)
                }
              }
              .fixedSize(horizontal: false, vertical: true)
              
              SmallStep {
                VStack (alignment: .leading) {
                  HStack {
                    Text("Now, your \"secret\" (don't worry, it'll be saved locally in your keychain):")
                  }
                  TextField("App secret", text: $appSecret)
                }
              }
              .fixedSize(horizontal: false, vertical: true)
              
              Text("Now click the button below and grant full access to the app you created:")
              HStack {
                MasterButton(label: "Back", mode: .soft, color: .gray, height: 44, fullWidth: true) {
                  withAnimation(spring) {
                    step = 1
                  }
                }
                MasterButton(label: "Grant access", height: 44, fullWidth: true) {
                  dismissKeyboard()
                  RedditAPI.shared.loggedUser.apiAppID = appID.trimmingCharacters(in: .whitespaces)
                  RedditAPI.shared.loggedUser.apiAppSecret = appSecret.trimmingCharacters(in: .whitespaces)
                  openURL(RedditAPI.shared.getAuthorizationCodeURL(appID))
                }
              }
            }
          }
          .blur(radius: loadingCallback ? 24 : 0)
          .allowsHitTesting(!loadingCallback)
          .overlay(
            !loadingCallback
            ? nil
            : VStack (alignment: .leading) {
              ProgressView()
              Text("Hold up, we're getting your access token!")
            }
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          )
          .onOpenURL { url in
            withAnimation(spring) {
              loadingCallback = true
            }
            RedditAPI.shared.monitorAuthCallback(url) { success in
              withAnimation(spring) {
                loadingCallback = false
                if success {
                  step = 3
                }
              }
            }
          }
          
          CardStep(currentStep: 3, title: "Done!", subTitle: "I hope you love winston!", step: $step) {
            VStack (alignment: .leading) {
              Text("That's it! Your API credentials are setup and you don't need to worry about these boring details anymore.")
              MasterButton(icon: "hand.thumbsup.fill", label: "Nice!", height: 44, fullWidth: true) {
                withAnimation(spring) {
                  open = false
                }
              }
            }
          }
          
        }
      }
      .padding(.top, 32)
      .padding(.horizontal, 16)
      .multilineTextAlignment(.leading)
    }
  }
  func dismissKeyboard() {
    let resign = #selector(UIResponder.resignFirstResponder)
     UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
  }
}
//
//struct ChangeAuthAPIKey_Previews: PreviewProvider {
//  static var previews: some View {
//    ChangeAuthAPIKey()
//  }
//}
