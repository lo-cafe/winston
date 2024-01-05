//
//  PeakQuestionsScroller.swift
//  winston
//
//  Created by Igor Marcossi on 05/01/24.
//

import SwiftUI
import WrappingHStack

struct PeakQuestionsScroller: View, Equatable {
  static func == (lhs: PeakQuestionsScroller, rhs: PeakQuestionsScroller) -> Bool {
    lhs.selectedQuestion == rhs.selectedQuestion && lhs.prevSelectedQuestion == rhs.prevSelectedQuestion
  }
  
  var peakQuestions: [PeakQuestion]
  var selectedQuestion: PeakQuestion?
  var prevSelectedQuestion: PeakQuestion?
  var selectQuestion: (PeakQuestion) -> ()
  var ns: Namespace.ID
  var body: some View {
    VStack(alignment: .center) {
      ForEach(questions) { q in
        PeakQuestionView(peakQuestion: q, ns: ns, isSelected: selectedQuestion == q, toggleSelected: selectQuestion).equatable()
          .zIndex(selectedQuestion == q ? 5 : prevSelectedQuestion == q ? 3 : 1)
      }
    }
  }
}


struct PeakQuestionsOverlay: View {
  var peakQuestions: [PeakQuestion]
  @State private var selectedQuestion: PeakQuestion? = nil
  @State private var prevSelectedQuestion: PeakQuestion? = nil
  @State private var pressed = false
  @State private var open = false
  @State private var scaledDown = false
  @Namespace private var ns
  
  func toggle(_ q: PeakQuestion) {
    let isSelected = selectedQuestion == q
    Task(priority: .background) {
      Hap.shared.play(intensity: 0.5, sharpness: 0.5)
    }
      
    if isSelected {
      withAnimation(.smooth(duration: isSelected ? 0.25 : 0.35)) {
        scaledDown = !isSelected
      }
    }
    doThisAfter(isSelected ? 0.1 : 0) {
      withAnimation(.snappy) {
        prevSelectedQuestion = selectedQuestion
        if !isSelected { scaledDown = !isSelected }
//        if !isAnswer { shadow = true }
        selectedQuestion = isSelected ? nil : q
      }
    }
  }
  
  var body: some View {
    VStack(alignment: .center, spacing: 24) {
      if open {
        PeakQuestionsScroller(peakQuestions: peakQuestions, selectedQuestion: selectedQuestion, prevSelectedQuestion: prevSelectedQuestion, selectQuestion: toggle, ns: ns)
          .padding(.top, 32)
          .zIndex(1)
          .scaleEffect(scaledDown ? 0.9 : 1)
          .allowsHitTesting(open)
      }
      
      HStack(spacing: open ? -2 : 1) {
        Text("Any questions")
          .fontSize(open ? 22 : 18, open ? .bold : .semibold, design: .rounded)
        Image(systemName: "questionmark.bubble.fill")
          .symbolRenderingMode(.hierarchical)
          .fontSize(open ? 26 : 19, open ? .bold : .semibold, design: .rounded)
          .ifIOS17 { v in
            if #available(iOS 17, *) {
              v.symbolEffect(.bounce, value: open)
            }
          }
          .rotationEffect(.degrees(open ? 7 : 0))
      }
      .brightness(open ? 0.075 : 0)
      .padding(.horizontal, 24)
      .frame(height: 48)
      .compositingGroup()
      .scaleEffect(scaledDown ? 0.95 : 1, anchor: .top)
      .drawingGroup()
      .contentShape(Rectangle())
      .foregroundStyle(Color.accentColor)
      .onTapGesture { withAnimation(.bouncy) { open.toggle() } }
      .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 30, perform: { }) { val in
        Hap.shared.play(intensity: val ? 0.5 : 0.65, sharpness: 0)
        withAnimation(.smooth(duration: 0.2)) { pressed = val }
      }
    }
    .frame(width: open ? .screenW - 16 : nil, alignment: .bottom)
    .padding(.bottom, open ? 20 : 0)
    .clipShape(RoundedRectangle(cornerRadius: open ? 32 : 24, style: .continuous))
    .background(RoundedRectangle(cornerRadius: open ? 32 : 24, style: .continuous).fill(Material.ultraThin).scaleEffect(scaledDown ? 0.95 : 1))
    .overlay {
      RoundedRectangle(cornerRadius: open ? 32 : 24, style: .continuous)
        .stroke(Color.primary.opacity(0.05), lineWidth: 0.5)
        .padding(.all, 0.5)
        .scaleEffect(scaledDown ? 0.95 : 1)
        .drawingGroup()
    }
    .contrast(scaledDown ? 0.65 : 1)
    .brightness(scaledDown ? -0.175 : pressed ? 0.075 : 0)
    .allowsHitTesting(selectedQuestion == nil)
    .overlay(alignment: .center) {
      if let selectedQuestion, open {
        PeakQuestionView(peakQuestion: selectedQuestion, ns: ns, isSelected: true, toggleSelected: toggle, isAnswer: true).zIndex(5).id(selectedQuestion.id)
      }
    }
    .padding(.bottom, open ? 24 : 44)
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    .background(!open ? nil : Color.black.opacity(0.5).onTapGesture {
      if open {
        if let selectedQuestion {
          toggle(selectedQuestion)
        } else {
          withAnimation(.bouncy(duration: 0.35)) {
            Hap.shared.play(intensity: 0.75, sharpness: 1.0)
            open = false
          }
        }
      }
    }.allowsHitTesting(open))
  }
}
