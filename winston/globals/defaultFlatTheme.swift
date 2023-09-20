//
//  defaultFlatTheme.swift
//  winston
//
//  Created by Igor Marcossi on 19/09/23.
//

import Foundation

private let defaultAvatarTheme = AvatarTheme(size: 30, cornerRadius: 15, visible: true)
private let primary: ColorSchemes<ThemeColor> = .init(light: .init(hex: "000000"), dark: .init(hex: "ffffff"))
private let primaryInverted: ColorSchemes<ThemeColor> = .init(light: .init(hex: "ffffff"), dark: .init(hex: "000000"))
private let clearColor: ColorSchemes<ThemeColor> = .init(light: .init(hex: "ffffff", alpha: 0), dark: .init(hex: "ffffff", alpha: 0))
private let dividerColor: ColorSchemes<ThemeColor> = .init(light: .init(hex: "C6C6C8"), dark: .init(hex: "3D3C41"))

let defaultFlatTheme = WinstonTheme(
  metadata: .init(
    name: "Default flat",
    description: "The default Winston Apollo-like flat theme. Follows iOS style.",
    color: .init(hex: "0B84FE"),
    icon: "paintbrush.fill",
    author: "lo.cafe"
  ),
  id: "default-flat",
  postLinks: .init(
    theme: .init(
      type: .card,
      cornerRadius: 20,
      mediaCornerRadius: 12,
      innerPadding: .init(horizontal: 16, vertical: 14),
      outerHPadding: 8,
      stickyPostBorderColor: .init(thickness: 4, color: .init(light: .init(hex: "2FD058", alpha: 0.3), dark: .init(hex: "2FD058", alpha: 0.3))),
      titleText: .init(size: 15, color: primary, weight: .medium),
      bodyText: .init(size: 14, color: .init(light: ThemeColor(hex: "000000", alpha: 0.75), dark: .init(hex: "ffffff", alpha: 0.75))),
      badge: badgeTheme,
      verticalElementsSpacing: 8,
      bg: .init(blurry: false, color: listSectionBGTheme),
      unseenType: .dot(.init(light: .init(hex: "4FFF85"), dark: .init(hex: "4FFF85")))
    ),
    spacing: 16,
    divider: .init(style: .no, thickness: 6, color: listSectionBGTheme),
    bg: defaultThemeBG
  ),
  posts: .init(
    padding: .init(horizontal: 8, vertical: 6),
    spacing: 12,
    badge: badgeTheme,
    bg: defaultThemeBG,
    commentsDistance: 16,
    titleText: .init(size: 20, color: primary),
    bodyText: .init(size: 15, color: primary)
  ),
  comments: .init(
    theme: .init(
      type: .card,
      innerPadding: .init(horizontal: 13, vertical: 6),
      outerHPadding: 8,
      repliesSpacing: 0,
      indentCurve: 12,
      indentColor: dividerColor,
      cornerRadius: 10,
      badge: badgeTheme,
      bodyText: .init(size: 15, color: primary),
      bodyAuthorSpacing: 6,
      bg: listSectionBGTheme
    ),
    spacing: 12,
    divider: .init(style: .line, thickness: 1, color: dividerColor)
    //    bg: defaultThemeBG
  ),
  lists: .init(
    bg: defaultThemeBG,
    foreground: .init(blurry: false, color: listSectionBGTheme),
    dividersColors: dividerColor
  ),
  general: .init(
    navPanelBG: .init(blurry: true, color: clearColor),
    tabBarBG: .init(blurry: true, color: clearColor),
    floatingPanelsBG: .init(blurry: true, color: clearColor),
    modalsBG: .init(blurry: true, color: clearColor),
    accentColor: .init(light: .init(hex: "0B84FE"), dark: .init(hex: "0B84FE"))
  )
)
