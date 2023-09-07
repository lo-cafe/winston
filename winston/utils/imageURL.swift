//
//  imageURL.swift
//  winston
//
//  Created by Daniel Inama on 07/09/23.
//

import Foundation

let imageUrlRegex = #"^https?:\/\/.*\.(?:png|jpe?g|gif|bmp|tiff|webp|svgz?|ico)(?:\?.*)?$"#

func isImageUrl(_ urlString: String) -> Bool {
    if let range = urlString.range(
        of: imageUrlRegex,
        options: .regularExpression,
        range: nil,
        locale: nil
    ) {
        return range.lowerBound == urlString.startIndex && range.upperBound == urlString.endIndex
    }
    return false
}
