//
//  ContentView.swift
//  TestSPM
//
//  Created by Mayank  on 03/03/26.
//

import SwiftUI

// ContentView is no longer the root of the app.
// TestSPMApp wires NavigationContainer → HomeView directly via AppCoordinator.
// This file is kept as an in-app architecture reference card.

struct ContentView: View {

    let layers: [(icon: String, title: String, subtitle: String, color: Color)] = [
        ("doc.text.fill",          "AppRoute",            "NavigationRoute enum — all destinations",     .blue),
        ("arrow.triangle.branch",  "AppCoordinator",      "Owns NavigationRouter, exposes semantic API", .purple),
        ("brain.head.profile",     "ViewModel",           "Calls coordinator; no SwiftUI dep",           .orange),
        ("rectangle.stack.fill",   "NavigationContainer", "The only NavigationStack-aware view",         .green),
        ("eye.fill",               "View",                "Pure UI — zero routing knowledge",            .pink),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("MVVM-C Architecture")
                    .font(.largeTitle.bold())
                    .padding(.top)

                Text("How `MKNavigatation` maps to MVVM-C layers in this demo:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                ForEach(layers, id: \.title) { layer in
                    HStack(spacing: 14) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(layer.color.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: layer.icon)
                                .foregroundStyle(layer.color)
                                .font(.title3)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(layer.title)
                                .font(.headline)
                            Text(layer.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Divider().padding(.vertical, 4)

                Text("This view is never shown at runtime — `TestSPMApp` starts directly at `HomeView` inside a `NavigationContainer`.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.bottom)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ContentView()
}
