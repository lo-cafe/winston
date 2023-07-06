//
//  structureComments.swift
//  winston
//
//  Created by Igor Marcossi on 05/07/23.
//

import Foundation

func nestComments(_ inputComments: [ListingChild<CommentData>]) -> [ListingChild<CommentData>] {
    var indexedComments = [String: Int]()
    var comments = inputComments
    
    for (index, child) in comments.enumerated() {
        indexedComments[child.data?.id ?? ""] = index
    }
    
    var index = 0
    while index < comments.count {
        if let comment = comments[index].data,
           let parent_id = comment.parent_id, parent_id.starts(with: "t1_"),
           let i = indexedComments[String(parent_id.dropFirst(3))], i < comments.count {
               
            var commentToAppend = comments.remove(at: index)
            if comments.indices.contains(i) {
                if comments[i].data?.replies == nil {
                    comments[i].data?.replies = .second(Listing(kind: "Listing", data: ListingData(after: nil, dist: nil, modhash: nil, geo_filter: nil, children: [commentToAppend])))
                } else if case var .second(listing) = comments[i].data?.replies {
                    listing.data?.children?.append(commentToAppend)
                    comments[i].data?.replies = .second(listing)
                }
            }
        } else {
            index += 1
        }
    }
    
    return comments
}
