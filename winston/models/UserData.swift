//
//  UserData.swift
//  winston
//
//  Created by Igor Marcossi on 28/06/23.
//

import Foundation

struct UserData: Codable, Hashable {
    let isEmployee: Bool?
    let isFriend: Bool?
    let subreddit: UserDataSubreddit?
    let snoovatarSize: [Int?]?
    let awardeeKarma: Int?
    let id: String?
    let verified: Bool?
    let isGold: Bool?
    let isMod: Bool?
    let awarderKarma: Int?
    let hasVerifiedEmail: Bool?
    let iconImg: String?
    let hideFromRobots: Bool?
    let linkKarma: Int?
    let prefShowSnoovatar: Bool?
    let isBlocked: Bool?
    let totalKarma: Int?
    let acceptChats: Bool?
    let name: String?
    let created: Double?
    let createdUtc: Double?
    let snoovatarImg: String?
    let commentKarma: Int?
    let acceptFollowers: Bool?
    let hasSubscribed: Bool?
    let acceptPms: Bool?
}

struct UserDataSubreddit: Codable, Hashable {
    let defaultSet: Bool?
    let userIsContributor: Bool?
    let bannerImg: String?
    let allowedMediaInComments: [String?]?
    let userIsBanned: Bool?
    let freeFormReports: Bool?
    let communityIcon: String?
    let showMedia: Bool?
    let iconColor: String?
    let userIsMuted: Bool?
    let displayName: String?
    let headerImg: String?
    let title: String?
    let previousNames: [String?]?
    let over18: Bool?
    let iconSize: [Int?]?
    let primaryColor: String?
    let iconImg: String?
    let description: String?
    let submitLinkLabel: String?
    let headerSize: [Int?]?
    let restrictPosting: Bool?
    let restrictCommenting: Bool?
    let subscribers: Int?
    let submitTextLabel: String?
    let isDefaultIcon: Bool?
    let linkFlairPosition: String?
    let displayNamePrefixed: String?
    let keyColor: String?
    let name: String?
    let isDefaultBanner: Bool?
    let url: String?
    let quarantine: Bool?
    let bannerSize: [Int?]?
    let userIsModerator: Bool?
    let acceptFollowers: Bool?
    let publicDescription: String?
    let linkFlairEnabled: Bool?
    let disableContributorRequests: Bool?
    let subredditType: String?
    let userIsSubscriber: Bool?
}
