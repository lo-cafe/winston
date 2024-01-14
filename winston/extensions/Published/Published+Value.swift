//
//  Published+Value.swift
//  winston
//
//  Created by Igor Marcossi on 08/12/23.
//

import Foundation

private class PublishedWrapper<T> {
    @Published private(set) var value: T

    init(_ value: Published<T>) {
        _value = value
    }
}

extension Published {
    var unofficialValue: Value {
        PublishedWrapper(self).value
    }
}
