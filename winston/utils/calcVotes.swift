//
//  calcVotes.swift
//  winston
//
//  Created by Daniel Inama on 12/08/23.
//
import Foundation

//source: https://www.reddit.com/r/TheoryOfReddit/comments/a0yt70/how_to_calculate_individual_upvotes_and_downvotes/
///This Function approximately calculates the number of upvotes a post has using the score (upvotes - donvotes) and the upvote ratio
func calculateUpvotes(upvoteRatio: Double, score: Int) -> Int {
  let upvotes = abs(ceil((Double(score) * upvoteRatio) / (2 * upvoteRatio - 1)))
  //I have to check for the edgecase where the score is 0 and the ratio is 0.5. This should result in 1 upvote and 1 donvote but instead it halts the app because it can't convert the Double into an Int
  return Int(!upvotes.isNaN && upvotes.isFinite ? upvotes : 1)
}

///Calculate the approximate downvotes using the score (upvotes - donvotes) and the upvote ratio
func calculateDownvotes(upvoteRatio: Double, score: Int) -> Int {
  return calculateUpvotes(upvoteRatio: upvoteRatio, score: score) - score
}


/// Returns a struct containing both the upvotes and downvotes so you only have to call the function once
func calculateUpAndDownVotes(upvoteRatio: Double, score: Int) -> CalculatedVotes{
  return CalculatedVotes(upvotes: calculateUpvotes(upvoteRatio: upvoteRatio, score: score), downvotes: calculateDownvotes(upvoteRatio: upvoteRatio, score: score))
}

struct CalculatedVotes{
  var upvotes: Int
  var downvotes: Int
}
