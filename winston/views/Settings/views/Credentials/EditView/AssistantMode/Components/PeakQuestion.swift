//
//  PeakQuestion.swift
//  winston
//
//  Created by Igor Marcossi on 04/01/24.
//

import SwiftUI
import Popovers

struct PeakQuestion: Identifiable, Equatable {
  static func == (lhs: PeakQuestion, rhs: PeakQuestion) -> Bool {
    lhs.id == rhs.id
  }
  
  init(question: String, answer: String) {
    self.question = question
    self.answer = answer.fixWidowedLines().md()
  }
  
  var id: String { self.question }
  let question: String
  let answer: AttributedString
}

struct PeakQuestionView: View, Equatable {
  static func == (lhs: PeakQuestionView, rhs: PeakQuestionView) -> Bool {
    lhs.peakQuestion == rhs.peakQuestion && lhs.isSelected == rhs.isSelected && lhs.isAnswer == rhs.isAnswer
  }
  
  let peakQuestion: PeakQuestion
  let ns: Namespace.ID
  let isSelected: Bool
  let toggleSelected: (PeakQuestion) -> ()
  var isAnswer: Bool = false
  @State private var pressed: Bool = false
  @State private var shadow = false
  @State private var size: CGSize? = nil
  
  init(peakQuestion: PeakQuestion, ns: Namespace.ID, isSelected: Bool, toggleSelected: @escaping (PeakQuestion) -> (), isAnswer: Bool = false) {
    self.peakQuestion = peakQuestion
    self.ns = ns
    self.isSelected = isSelected
    self.toggleSelected = toggleSelected
    self.isAnswer = isAnswer
  }
  
  func toggle() {
    toggleSelected(peakQuestion)
  }
  
  var body: some View {
      if isSelected && !isAnswer {
        Color.clear.frame(size)
      } else {
        VStack(alignment: .center, spacing: 8) {
          Label(peakQuestion.question, systemImage: "questionmark.circle.fill")
            .fontSize(18, .medium, design: .rounded)
            .matchedGeometryEffect(id: "question-\(peakQuestion.id)-title", in: ns, properties: [.position], anchor: .top)
            .padding(EdgeInsets(top: 12, leading: 16, bottom: isAnswer ? 0 : 12, trailing: 16))
            .fixedSize(horizontal: true, vertical: false)
            .getInitialSize($size, disabled: isAnswer)
          
          if size != nil || isAnswer {
            VStack(alignment: .center, spacing: 8) {
              Divider()
              Text(peakQuestion.answer)
                .fixedSize(horizontal: false, vertical: true)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 12, trailing: 16))
                .opacity(0.9)
            }
            .frame(width: .screenW - 32, alignment: .top)
            .matchedGeometryEffect(id: "question-\(peakQuestion.id)-details", in: ns, anchor: .top)
          }
        }
        .matchedGeometryEffect(id: "question-\(peakQuestion.id)-frame", in: ns, anchor: .top)
        .frame(width: isAnswer ? .screenW - 16 : size?.width, height: !isAnswer ? size?.height : nil, alignment: .top)
        .mask { RoundedRectangle(cornerRadius: 24, style: .continuous).fill(.black).matchedGeometryEffect(id: "question-\(peakQuestion.id)-mask", in: ns) }
        .background { RoundedRectangle(cornerRadius: 24, style: .continuous).fill(Color(uiColor: .secondarySystemGroupedBackground)).matchedGeometryEffect(id: "question-\(peakQuestion.id)-bg", in: ns) }
        .overlay {
          RoundedRectangle(cornerRadius: 24, style: .continuous)
            .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
            .matchedGeometryEffect(id: "question-\(peakQuestion.id)-bg-border", in: ns)
            .padding(.all, 0.5)
        }
        .multilineTextAlignment(.center)
        .scaleEffect(pressed ? 0.975 : 1)
        .contentShape(Rectangle())
        .transition(.scale(scale: 1))
        .onTapGesture { toggle() }
        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: .infinity, perform: { }, onPressingChanged: { val in
          withAnimation(.spring(duration: 0.25)) { pressed = val }
        })
        .allowsHitTesting(!(isAnswer && !isSelected))
        .onAppear {
          if isAnswer && !shadow { withAnimation { shadow = true } }
//          if !isAnswer && shadow { withAnimation { shadow = false } }
        }
      }
  }
}

