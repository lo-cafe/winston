//
//  SwipeAction.swift
//  winston
//
//  Created by Igor Marcossi on 09/08/23.
//

import Foundation
import Defaults
import SwiftUI

struct SwipeActionItem: Codable, Defaults.Serializable {
  var normal: String
  var active: String
  
  init(normal: String, active: String) {
    self.normal = normal
    self.active = active
  }
  
  init(normal: String) {
    self.normal = normal
    self.active = normal
  }
}

struct SwipeActionsSet: Codable, Defaults.Serializable, Equatable {
  static func == (prev: SwipeActionsSet, next: SwipeActionsSet) -> Bool {
    return prev.leftFirst == next.leftFirst && prev.leftSecond == next.leftSecond && prev.rightFirst == next.rightFirst && prev.rightSecond == next.rightSecond
  }
  var leftFirst: AnySwipeAction
  var leftSecond: AnySwipeAction
  var rightFirst: AnySwipeAction
  var rightSecond: AnySwipeAction
}


let allPostSwipeActions: [AnySwipeAction] = [AnySwipeAction(UpvotePostAction()), AnySwipeAction(DownvotePostAction()), AnySwipeAction(SavePostAction()), AnySwipeAction(ReplyPostAction()), AnySwipeAction(SeenPostAction()), AnySwipeAction(SharePostAction()), AnySwipeAction(NoneAction())]
let allCommentSwipeActions: [AnySwipeAction] = [AnySwipeAction(UpvoteCommentAction()), AnySwipeAction(DownvoteCommentAction()), AnySwipeAction(ReplyCommentAction()), AnySwipeAction(SaveCommentAction()), AnySwipeAction(SelectTextCommentAction()), AnySwipeAction(ShareCommentAction()), AnySwipeAction(CopyCommentAction()), AnySwipeAction(NoneAction())]
let allSwipeActions = allPostSwipeActions + allCommentSwipeActions

struct AnySwipeAction: Codable, Defaults.Serializable, Identifiable, Hashable {
  static func == (lhs: AnySwipeAction, rhs: AnySwipeAction) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
  
  var id: String { return base.id }
  var label: String { return base.label }
  var icon: SwipeActionItem { return base.icon }
  var color: SwipeActionItem { return base.color }
  var bgColor: SwipeActionItem { return base.bgColor }
  
  let actionClosure: (Any) async -> Void
  let activeClosure: (Any) -> Bool
  
  private let base: Base
  
  init<T: SwipeAction>(_ base: T) where T: Codable {
    self.base = Base(base)
    self.actionClosure = { entity in
      guard let entity = entity as? GenericRedditEntity<T.EntityType> else { return }
      await base.action(entity)
    }
    self.activeClosure = { entity in
      guard let entity = entity as? GenericRedditEntity<T.EntityType> else { return false }
      return base.active(entity)
    }
  }
  
  init(from decoder: Decoder) throws {
    let values = try decoder.container(keyedBy: CodingKeys.self)
    let newBase = try values.decode(Base.self, forKey: .base)
    base = newBase
    
    // restore the action and active closures using the SwipeActionProvider
    if let swipeAction = allSwipeActions.first(where: { $0.id == newBase.id }) {
      actionClosure = swipeAction.actionClosure
      activeClosure = swipeAction.activeClosure
    } else {
      actionClosure = { _ in return }
      activeClosure = { _ in return false }
    }
  }
  
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(base, forKey: .base)
  }
  
  func action(_ entity: Any) async {
    await actionClosure(entity)
  }
  
  func active(_ entity: Any) -> Bool {
    return activeClosure(entity)
  }
  
  private struct Base: Codable, Defaults.Serializable {
    var id: String
    var label: String
    var icon: SwipeActionItem
    var color: SwipeActionItem
    var bgColor: SwipeActionItem
    
    init<T: SwipeAction>(_ base: T) where T: Codable {
      self.id = base.id
      self.label = base.label
      self.icon = base.icon
      self.color = base.color
      self.bgColor = base.bgColor
    }
  }
  
  enum CodingKeys: String, CodingKey {
    case base
  }
}

protocol SwipeAction: Codable, Identifiable, Defaults.Serializable {
  var id: String { get }
  var label: String { get }
  var icon: SwipeActionItem { get }
  var color: SwipeActionItem { get }
  var bgColor: SwipeActionItem { get }
  associatedtype EntityType: GenericRedditEntityDataType
  func action(_ entity: GenericRedditEntity<EntityType>) async
  func active(_ entity: GenericRedditEntity<EntityType>) -> Bool
}

struct UpvotePostAction: SwipeAction {
  var id = "upvote-post-swipe-action"
  var label = "Upvote"
  var icon = SwipeActionItem(normal: "arrow.up")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "FEA00A", active: "FF463B")
  func action(_ entity: Post) async { _ = await entity.vote(action: .up) }
  func active(_ entity: Post) -> Bool { return entity.data?.likes == true }
}

struct DownvotePostAction: SwipeAction {
  var id = "downvote-post-swipe-action"
  var label = "Downvote"
  var icon = SwipeActionItem(normal: "arrow.down")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "0B84FE", active: "FF463B")
  func action(_ entity: Post) async { _ = await entity.vote(action: .down) }
  func active(_ entity: Post) -> Bool { return entity.data?.likes == false }
}

struct SavePostAction: SwipeAction {
  var id = "save-post-swipe-action"
  var label = "Save"
  var icon = SwipeActionItem(normal: "bookmark.fill", active: "bookmark.slash.fill")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "2FD058", active: "FF463B")
  func action(_ entity: Post) async { _ = await entity.saveToggle() }
  func active(_ entity: Post) -> Bool { return entity.data?.saved == true }
}

struct ReplyPostAction: SwipeAction {
  var id = "reply-post-swipe-action"
  var label = "Reply"
  var icon = SwipeActionItem(normal: "arrowshape.turn.up.left.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Post) async { ReplyModalInstance.shared.enable(.post(entity)) }
  func active(_ entity: Post) -> Bool { return false }
}

struct SeenPostAction: SwipeAction {
  var id = "seen-post-swipe-action"
  var label = "See/Unsee"
  var icon = SwipeActionItem(normal: "eye.fill", active: "eye.slash.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Post) async { await MainActor.run { withAnimation { entity.toggleSeen(optimistic: true) } } }
  func active(_ entity: Post) -> Bool { return false }
}

struct SharePostAction: SwipeAction {
  var id = "share-post-swipe-action"
  var label = "Share"
  var icon = SwipeActionItem(normal: "square.and.arrow.up.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Comment) async { }
  func active(_ entity: Comment) -> Bool { return false }
}

struct UpvoteCommentAction: SwipeAction {
  var id = "upvote-comment-swipe-action"
  var label = "Upvote"
  var icon = SwipeActionItem(normal: "arrow.up")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "FEA00A", active: "FF463B")
  func action(_ entity: Comment) async { _ = await entity.vote(action: .up) }
  func active(_ entity: Comment) -> Bool { return entity.data?.likes == true }
}

struct DownvoteCommentAction: SwipeAction {
  var id = "downvote-comment-swipe-action"
  var label = "Downvote"
  var icon = SwipeActionItem(normal: "arrow.down")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "0B84FE", active: "FF463B")
  func action(_ entity: Comment) async {
    print("macabro")
    _ = await entity.vote(action: .down)
  }
  func active(_ entity: Comment) -> Bool { return entity.data?.likes == false }
}

struct ReplyCommentAction: SwipeAction {
  var id = "reply-comment-swipe-action"
  var label = "Reply"
  var icon = SwipeActionItem(normal: "arrowshape.turn.up.left.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Comment) async {
    await MainActor.run {
      ReplyModalInstance.shared.enable(.comment(entity))
    }
  }
  func active(_ entity: Comment) -> Bool { return false }
}

struct SaveCommentAction: SwipeAction {
  var id = "save-comment-swipe-action"
  var label = "Save"
  var icon = SwipeActionItem(normal: "bookmark.fill", active: "bookmark.slash.fill")
  var color = SwipeActionItem(normal: "FFFFFF")
  var bgColor = SwipeActionItem(normal: "2FD058", active: "FF463B")
  func action(_ entity: Comment) async { _ = await entity.saveToggle() }
  func active(_ entity: Comment) -> Bool { return entity.data?.saved == true }
}

struct SelectTextCommentAction: SwipeAction {
  var id = "select-text-comment-swipe-action"
  var label = "Select text"
  var icon = SwipeActionItem(normal: "clipboard.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Comment) async { entity.data?.winstonSelecting = !(entity.data?.winstonSelecting ?? false) }
  func active(_ entity: Comment) -> Bool { return false }
}

struct ShareCommentAction: SwipeAction {
  var id = "share-comment-swipe-action"
  var label = "Share"
  var icon = SwipeActionItem(normal: "square.and.arrow.up.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Comment) async { }
  func active(_ entity: Comment) -> Bool { return false }
}

struct CopyCommentAction: SwipeAction {
  var id = "copy-comment-swipe-action"
  var label = "Copy text"
  var icon = SwipeActionItem(normal: "clipboard.fill")
  var color = SwipeActionItem(normal: "0B84FE")
  var bgColor = SwipeActionItem(normal: "353439")
  func action(_ entity: Comment) async { UIPasteboard.general.string = entity.data?.body ?? "" }
  func active(_ entity: Comment) -> Bool { return false }
}

struct NoneAction: SwipeAction {
  var id = "none"
  var label = "None"
  var icon = SwipeActionItem(normal: "circle.dashed")
  var color = SwipeActionItem(normal: "7F7F80")
  var bgColor = SwipeActionItem(normal: "000000")
  func action(_ entity: Comment) async { }
  func active(_ entity: Comment) -> Bool { return false }
}
