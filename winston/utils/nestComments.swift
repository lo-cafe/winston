//
//  structureComments.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import Foundation

func nestComments(_ inputComments: [ListingChild<CommentData>], parentID: String) -> [Comment] {
  var rootComments: [Comment] = []
  var commentsMap: [String:Comment] = [:]
  
  inputComments.compactMap { x in
    if let data = x.data, let name = data.name, let commentParentID = data.parent_id, !name.hasSuffix(parentID) {
      let newComment = Comment(data: data, kind: x.kind)
      commentsMap[name] = newComment
      if parentID != commentParentID {
        return newComment
      } else {
        rootComments.append(newComment)
      }
    }
    return nil
  }.forEach { x in
    if let data = x.data, let parentName = data.parent_id, let parent = commentsMap[parentName] {
      parent.childrenWinston.data.append(x)
    }
  }
  return rootComments
}
