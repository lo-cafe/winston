//
//  whatsNew.swift
//  winston
//
//  Created by Daniel Inama on 09/11/23.
//

import Foundation
import WhatsNewKit

public var whatsNewCollection: WhatsNewCollection {
  [
    WhatsNew(
      // The Version that relates to the features you want to showcase
      version: "1.0.0",
      // The title that is shown at the top
      title: "What's New",
      // The features you want to showcase
      features: [
        WhatsNew.Feature(
          image: .init(systemName: "star.fill"),
          title: "Title",
          subtitle: "Subtitle"
        )
      ],
      // The primary action that is used to dismiss the WhatsNewView
      primaryAction: getDefaultPrimaryAction(),
      // The optional secondary action that is displayed above the primary action
      secondaryAction: getDefaultSecondaryAction()
    )
  ]
}

func getDefaultPrimaryAction() -> WhatsNew.PrimaryAction {
  return WhatsNew.PrimaryAction(
    title: "Continue",
    backgroundColor: .accentColor,
    foregroundColor: .white,
    hapticFeedback: .notification(.success),
    onDismiss: {
    }
  )
}

func getDefaultSecondaryAction() -> WhatsNew.SecondaryAction {
  return WhatsNew.SecondaryAction(
    title: "Learn more",
    foregroundColor: .accentColor,
    hapticFeedback: .selection,
    action: .openURL(
      .init(string: "https://github.com/lo-cafe/winston")
    )
  )
}
