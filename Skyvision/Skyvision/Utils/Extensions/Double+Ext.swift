//
//  Double+Ext.swift
//  Skyvision
//
//  Created by Daniel Gogozan on 14.07.2022.
//

import Foundation

extension Double {
    var fancy: String {
        String(format: "%.1f", self)
    }
    
    var percent: String {
        self.formatted(.percent)
    }
}
