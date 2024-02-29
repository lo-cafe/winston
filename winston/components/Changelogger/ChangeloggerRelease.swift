//
//  ChangeloggerRelease.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct ChangeloggerRelease: View {
  enum ReleaseState {
    case smal
  }
  
  var release: ChangelogRelease
  var ns: Namespace.ID
  var small = true
  var open = false
  var hidden = false
  var onTap: ()->()
  
  init(release: ChangelogRelease, ns: Namespace.ID, small: Bool = true, open: Bool = false, hidden: Bool = false, onTap: @escaping ()->()) {
    self.release = release
    self.ns = ns
    self.small = small
    self.open = open
    self.hidden = hidden
    self.onTap = onTap
    self._pressing = .init(initialValue: open)
  }
  
//  var isSource: Bool { open ?  }
  
  @State private var size: CGSize = .zero
  @State private var pressing: Bool
  var body: some View {
    if hidden {
      Color.clear.frame(width: size.width, height: size.height)
    } else {
      ScrollView(.vertical) {
        HStack(alignment: .top, spacing: 4) {
          VStack(alignment: .center, spacing: -12) {
            Image(systemName: "star.fill")
              .fontSize(40)
              .foregroundStyle(.yellow)
//              .matchedGeometryEffect(id: "\(release.version)-icon", in: ns, properties: [.position])
          }
          VStack(alignment: .leading, spacing: 8) {
            VStack(alignment: .leading, spacing: 0) {
              VStack(alignment: .leading, spacing: 0) {
                Text(release.version).fontSize(24, .bold, design: .rounded)
//                  .matchedGeometryEffect(id: "\(release.version)-version", in: ns, properties: [.position], anchor: .top)
                  .frame(maxWidth: .infinity, alignment: .leading)
                SmallTag(label: "MINOR", color: .changelogYellow)
//                  .matchedGeometryEffect(id: "\(release.version)-tag", in: ns, properties: [.position], anchor: .top)
                  .frame(maxWidth: .infinity, alignment: .leading)
              }
              .padding(.top, 7)
              .padding(.bottom, 6)
              
              if !small || open {
                Text("This update includes new features and bug fixes.").fontSize(15, .regular, design: .rounded).opacity(0.75)
//                  .matchedGeometryEffect(id: "\(release.version)-description", in: ns, anchor: .top)
              }
            }
            .scaleEffect(1)
            
            if !small || open {
              
              VStack(alignment: .leading, spacing: 16) {
                if let feats = release.report.feat, feats.count > 0 {
                  Text("Features").fontSize(24, .semibold, design: .rounded)
//                    .matchedGeometryEffect(id: "\(release.version)-feat-title", in: ns, properties: [.position])
                  VStack(alignment: .leading, spacing: 8) {
                    ForEach(feats) { feat in
                      ReleaseChange(type: .feat, icon: feat.icon, subject: feat.subject, description: feat.description)
//                        .matchedGeometryEffect(id: "\(release.version)-features-\(feat.id)", in: ns, anchor: .top)
                    }
                  }
//                  .matchedGeometryEffect(id: "\(release.version)-features", in: ns, anchor: .top)
                }
                
                if let fixes = release.report.fix, fixes.count > 0 {
                  Text("Fixed bugs").fontSize(24, .semibold, design: .rounded)
//                    .matchedGeometryEffect(id: "\(release.version)-bugfixes-title", in: ns, properties: [.position])
                  VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(fixes.enumerated()), id: \.element) { i, fix in
                      if i != 0 { Divider() }
                      ReleaseChange(type: .fix, icon: nil, subject: fix.subject, description: "")
//                        .matchedGeometryEffect(id: "\(release.version)-bugfixes-\(fix.id)", in: ns, anchor: .top)
                    }
                  }
//                  .matchedGeometryEffect(id: "\(release.version)-bugfixes", in: ns, anchor: .top)
                }
                
                if let others = release.report.others, others.count > 0 {
                  Text("Others").fontSize(24, .semibold, design: .rounded)
//                    .matchedGeometryEffect(id: "\(release.version)-others-title", in: ns, properties: [.position], anchor: .top)
                  VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(others.enumerated()), id: \.element) { i, other in
                      if i != 0 { Divider() }
                      ReleaseChange(type: .other, icon: nil, subject: other.subject, description: "")
//                        .matchedGeometryEffect(id: "\(release.version)-others-\(other.id)", in: ns, anchor: .top)
                    }
                  }
//                  .matchedGeometryEffect(id: "\(release.version)-others", in: ns, anchor: .top)
                }
              }
              .scaleEffect(1)
              
              //          ReleaseFeature(icon: "", title: "", description: "")
            }
            
            
            
          }
        }
        .padding(.all, 16)
      }
      .scrollDisabled(!open)
      .matchedGeometryEffect(id: "\(release.version)-frame", in: ns, anchor: .top)
      .frame(maxWidth: .infinity, maxHeight: open ? nil : 400, alignment: .topLeading)
      .measure($size, disable: open || size != .zero)
//      .clipped()
      .mask(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(.black).matchedGeometryEffect(id: "\(release.version)-mask", in: ns, anchor: .top))
      .overlay {
        RoundedRectangle(cornerRadius: 32, style: .continuous)
          .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
          .padding(.all, 0.5)
          .matchedGeometryEffect(id: "\(release.version)-border", in: ns, anchor: .top)
      }
      .background(RoundedRectangle(cornerRadius: 32, style: .continuous).fill(Material.bar).matchedGeometryEffect(id: "\(release.version)-bg", in: ns, anchor: .top))
      .compositingGroup()
      .scaleEffect(pressing ? 0.975 : 1)
      .padding(EdgeInsets(top: !open ? 0 : .topSafeArea + 4, leading: !open ? 0 : 12, bottom: !open ? 0 : .bottomSafeArea, trailing: !open ? 0 : 12))
      .geometryGroup()
      .transition(.scale(1))
      .onTapGesture {
        Hap.shared.play(intensity: 0.75, sharpness: 1)
        onTap()
      }
      .onLongPressGesture(minimumDuration: 300, maximumDistance: 0) { } onPressingChanged: { pressing in
        if open { return }
        if pressing {
          Hap.shared.play(intensity: 0.5, sharpness: 0)
        }
        withAnimation(.bouncy(duration: 0.4, extraBounce: 0.125)) { self.pressing = pressing }
      }
      .onAppear {
        if open { doThisAfter(0.2) { withAnimation(.bouncy) { pressing = false } } }
      }
    }
  }
}
