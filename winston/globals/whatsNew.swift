//
//  whatsNew.swift
//  winston
//
//  Created by Daniel Inama on 09/11/23.
//

import Foundation
import WhatsNewKit

// Function to read JSON file and append WhatsNew to the collection
func getCurrentChangelog() -> WhatsNewCollection {
    let filePath = Bundle.main.path(forResource: "changelog", ofType: "json") ?? ""
    print("Get")

    // Read JSON content from the file
    guard let jsonData = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else { return [] }

    let decoder = JSONDecoder()

    // Decode JSON data into a WhatsNewRelease object
    do {
        let changelog = try decoder.decode(WhatsNewRelease.self, from: jsonData)
        print(changelog)

        // Extract relevant information from the WhatsNewRelease object
        let version = changelog.version
        let title = changelog.title
        let features = changelog.features

        // Create a new mutable copy of the current collection
        var newCollection: WhatsNewCollection = []

        // Create an array to store WhatsNew.Feature instances for the current feature
        var featureArray: [WhatsNew.Feature] = []

        // Loop through all features and add them to the feature array
        if let features = features {
            for feature in features {
                let systemImage = feature.systemImage
                let featureTitle = feature.title
                let featureSubtitle = feature.subtitle

                // Create a new WhatsNew.Feature for each feature detail
                let newFeature = WhatsNew.Feature(
                    image: .init(systemName: systemImage),
                    title: WhatsNew.Text(stringLiteral: featureTitle),
                    subtitle: WhatsNew.Text(stringLiteral: featureSubtitle)
                )

                // Append the new feature to the array
                featureArray.append(newFeature)
            }
        }

        // Create a new WhatsNew object with the array of features
        let newWhatsNew = WhatsNew(
            version: WhatsNew.Version(stringLiteral: version ?? "0.0.0"),
            title: WhatsNew.Title(stringLiteral: title ?? ""),
            features: featureArray,
            primaryAction: getDefaultPrimaryAction(),
            secondaryAction: getDefaultSecondaryAction()
        )

        // Append the new WhatsNew to the new collection
        newCollection.append(newWhatsNew)

        // Return the updated collection
        return newCollection

    } catch {
        print(error)
    }

    return []
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

struct WhatsNewRelease: Decodable {
    let title: String?
    let version: String?
    let features: [WhatsNewFeatureDetail]?
}

struct WhatsNewFeatureDetail: Decodable {
    let subtitle: String
    let systemImage: String
    let title: String
}

