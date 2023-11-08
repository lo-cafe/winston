//
//  defaultTheme.swift
//  winston
//
//  Created by Igor Marcossi on 07/09/23.
//

import Foundation
import SwiftUI

let defaultAvatarTheme = AvatarTheme(size: 30, cornerRadius: 15, visible: true)
let themeFontPrimary: ColorSchemes<ThemeColor> = .init(light: .init(hex: "000000"), dark: .init(hex: "ffffff"))
private let themeFontPrimaryInverted: ColorSchemes<ThemeColor> = .init(light: .init(hex: "ffffff"), dark: .init(hex: "000000"))
let listSectionBGTheme: ColorSchemes<ThemeColor> = .init(light: .init(hex: "ffffff"), dark: .init(hex: "1C1C1E"))
let defaultBG: ColorSchemes<ThemeColor> = .init(light: .init(hex: "F2F2F7"), dark: .init(hex: "000000"))
private let clearColor: ColorSchemes<ThemeColor> = .init(light: .init(hex: "ffffff", alpha: 0), dark: .init(hex: "ffffff", alpha: 0))
let defaultThemeDividerColor: ColorSchemes<ThemeColor> = .init(light: .init(hex: "C6C6C8"), dark: .init(hex: "3D3C41"))
let listDefaultBGImage: ColorSchemes<String> = .init(light: "winstonNoBG", dark: "winstonNoBG")
let defaultFancyDivider: LineTheme = .init(style: .fancy, thickness: 6, color: .init(light: .init(hex: "ffffff", alpha: 0.5), dark: .init(hex: "1C1C1E", alpha: 0.5)))
let defaultThemeBG: ThemeBG = .color(defaultBG)

let badgeTheme: BadgeTheme = .init(
  avatar: AvatarTheme(size: 30, cornerRadius: 15, visible: true),
  authorText: .init(size: 13, color: themeFontPrimary, weight: .semibold),
  flairText: .init(size: 12, color: .init(light: .init(hex: "999999"), dark: .init(hex: "767676")), weight: .bold),
  flairBackground: .init(light: .init(hex: "EEEEEE"), dark: .init(hex: "2C2C2C")),
  statsText: .init(size: 12, color: .init(light: .init(hex: "000000", alpha: 0.5), dark: .init(hex: "ffffff", alpha: 0.5)), weight: .medium), spacing: 5)

let defaultTheme = WinstonTheme(
  metadata: .init(
    name: "Default",
    description: "The default Winston theme. Follows iOS style.",
    color: .init(hex: "0B84FE"),
    icon: "paintbrush.fill",
    author: "lo.cafe"
  ),
  id: "default",
  postLinks: .init(
    theme: .init(
      cornerRadius: 20,
      mediaCornerRadius: 12,
      innerPadding: .init(horizontal: 16, vertical: 14),
      outerHPadding: 8,
      stickyPostBorderColor: .init(thickness: 4, color: .init(light: .init(hex: "2FD058", alpha: 0.3), dark: .init(hex: "2FD058", alpha: 0.3))),
      titleText: .init(size: 16, color: themeFontPrimary, weight: .medium),
      bodyText: .init(size: 15, color: .init(light: ThemeColor(hex: "000000", alpha: 0.75), dark: .init(hex: "ffffff", alpha: 0.75))),
      linespacing: 0,
      badge: badgeTheme,
      verticalElementsSpacing: 8,
      bg: .init(blurry: false, color: listSectionBGTheme),
      unseenType: .dot(.init(light: .init(hex: "4FFF85"), dark: .init(hex: "4FFF85"))),
      unseenFadeOpacity : 0.6
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
    titleText: .init(size: 20, color: themeFontPrimary),
    bodyText: .init(size: 15, color: themeFontPrimary),
    linespacing: 0
  ),
  comments: .init(
    theme: .init(
      innerPadding: .init(horizontal: 13, vertical: 6),
      outerHPadding: 8,
      repliesSpacing: 0,
      indentCurve: 12,
      indentColor: defaultThemeDividerColor,
      cornerRadius: 10,
      badge: badgeTheme,
      bodyText: .init(size: 15, color: themeFontPrimary),
      bodyAuthorSpacing: 6,
      linespacing: 0,
      bg: listSectionBGTheme,
      loadMoreInnerPadding: .init(horizontal: 10, vertical: 6),
      loadMoreOuterTopPadding: 12,
      loadMoreText: .init(size: 15, color: .init(light: .init(hex: "0B84FE"), dark: .init(hex: "0B84FE")), weight: .semibold),
      loadMoreBackground: defaultThemeDividerColor,
      unseenDot : .init(light: .init(hex: "0B84FE"), dark: .init(hex: "0B84FE"))
    ),
    spacing: 12,
    divider: .init(style: .no, thickness: 1, color: defaultThemeDividerColor)
    //    bg: defaultThemeBG
  ),
  lists: .init(
    bg: defaultThemeBG,
    foreground: .init(blurry: false, color: listSectionBGTheme),
    dividersColors: defaultThemeDividerColor
  ),
  general: .init(
    navPanelBG: .init(blurry: true, color: clearColor),
    tabBarBG: .init(blurry: true, color: clearColor),
    floatingPanelsBG: .init(blurry: true, color: clearColor),
    modalsBG: .init(blurry: true, color: clearColor),
    accentColor: .init(light: .init(hex: "0B84FE"), dark: .init(hex: "0B84FE"))
  )
)
