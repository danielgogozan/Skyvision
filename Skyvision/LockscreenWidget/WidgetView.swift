//
//  WidgetView.swift
//  LockscreenWidgetExtension
//
//  Created by Daniel Gogozan on 15.07.2022.
//

import SwiftUI
import WidgetKit

struct SkyWidgetView : View {
    var entry: Provider.Entry

    var body: some View {
        Text("Skyvision is here")
        Text(entry.configuration.Location?.locality ?? "Idk")
    }
}
