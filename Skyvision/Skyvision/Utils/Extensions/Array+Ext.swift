//
//  Array+Ext.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 16.07.2022.
//

import Foundation

extension Array where Element: Hashable {
    var unique: [Element] {
        return Array(Set(self))
    }
}
