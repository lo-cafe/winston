//
//  replyModalPresenter.swift
//  winston
//
//  Created by Igor Marcossi on 09/08/23.
//

import SwiftUI

struct ReplyModalPresenter: ViewModifier {
  @ObservedObject var shared = ReplyModalInstance.shared
  func body(content: Content) -> some View {
    content
      .sheet(isPresented: Binding(get: { shared.isShowing == .post }, set: { if !$0 { shared.disable() } })) {
        ReplyModalPost(post: shared.subjectPost)
      }
      .sheet(isPresented: Binding(get: { shared.isShowing == .comment }, set: { if !$0 { shared.disable() } })) {
        ReplyModalComment(comment: shared.subjectComment)
      }
      .sheet(isPresented: Binding(get: { shared.isShowing == .commentEdit }, set: { if !$0 { shared.disable() } })) {
        EditReplyModalComment(comment: shared.subjectCommentEdit)
      }
  }
}

extension View {
  func replyModalPresenter() -> some View {
    self
      .modifier(ReplyModalPresenter())
  }
}

class ReplyModalInstance: ObservableObject {
  static var shared = ReplyModalInstance()
  static private let placeholderPost = Post.placeholder()
  static private let placeholderComment = Comment.placeholder()
  @Published public private(set) var subjectPost: Post = ReplyModalInstance.placeholderPost
  @Published public private(set) var subjectComment: Comment = ReplyModalInstance.placeholderComment
  @Published public private(set) var subjectCommentEdit: Comment = ReplyModalInstance.placeholderComment
  @Published public private(set) var isShowing: Showing = .none { didSet { if isShowing == .none { self.clearSubjects() } } }
  
  func enable(_ subject: Subject) {
    switch subject {
    case .commentEdit(let comment):
      subjectCommentEdit = comment
      doThisAfter(0) {
        withAnimation(spring) {
          self.isShowing = .commentEdit
        }
      }
    case .comment(let comment):
      subjectComment = comment
      doThisAfter(0) {
        withAnimation(spring) {
          self.isShowing = .comment
        }
      }
    case .post(let post):
      subjectPost = post
      doThisAfter(0) {
        withAnimation(spring) {
          self.isShowing = .post
        }
      }
    }
  }
  
  func disable() {
    withAnimation(spring) { self.isShowing = .none }
    self.clearSubjects()
  }
  
  private func clearSubjects() {
    doThisAfter(0.4) {
      self.subjectPost = ReplyModalInstance.placeholderPost;
      self.subjectComment = ReplyModalInstance.placeholderComment
      self.subjectCommentEdit = ReplyModalInstance.placeholderComment
    }
  }
  
  enum Subject {
    case post(Post)
    case comment(Comment)
    case commentEdit(Comment)
  }
  
  enum Showing: String {
    case post
    case comment
    case commentEdit
    case none
  }
}
