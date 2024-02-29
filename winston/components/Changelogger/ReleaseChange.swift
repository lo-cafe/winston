//
//  ReleaseFeature.swift
//  winston
//
//  Created by Igor Marcossi on 24/02/24.
//

import SwiftUI

struct ReleaseChange: View {
  enum ChangeType {
    case feat, fix, other
    
    var icon: String {
      return switch self {
      case .feat: "star.fill"
      case .fix: "ladybug.fill"
      case .other: "carrot.fill"
      }
    }
    
    var color: Color {
      return switch self {
      case .feat: .blue
      case .fix: .green
      case .other: .primary
      }
    }
  }
  var type: ChangeType
  var icon: String?
  var subject: String
  var description: String?
    var body: some View {
      HStack(alignment: description?.isEmpty ?? true ? .center : .top, spacing: 8) {
        Image(systemName: icon ?? type.icon).fontSize(18, .medium)
          .foregroundStyle(type.color)
        
        VStack(alignment: .leading, spacing: 0) {
          Text(subject).fontSize(description == nil ? 16 : 18, description == nil ? .regular : .medium)
            .fixedSize(horizontal: false, vertical: true)
          if let description, !description.isEmpty {
            Text(description).fontSize(15, .regular).opacity(0.75)
              .fixedSize(horizontal: false, vertical: true)
          }
        }
      }
      .padding(type == .feat ? .all : .vertical, type == .feat ? 12 : 8)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(type == .feat ? RR(16, .primary.opacity(0.05)) : nil)
    }
}
