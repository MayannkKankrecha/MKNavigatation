// DestinationViews.swift
// Example — not part of the MKNavigatation library target.
//
// Leaf views for each route. Each is navigation-agnostic.

import SwiftUI

// MARK: - Profile

/// Displays a user profile. No navigation knowledge.
@available(iOS 16.0, macOS 13.0, *)
public struct ProfileView: View {
    public let userID: String

    public init(userID: String) {
        self.userID = userID
    }

    public var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 72))
                .foregroundStyle(.tint)
            Text("User ID: \(userID)")
                .font(.headline)
        }
        .navigationTitle("Profile")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}

// MARK: - Settings

/// Settings screen. No navigation knowledge.
@available(iOS 16.0, macOS 13.0, *)
public struct SettingsView: View {
    public init() {}

    public var body: some View {
        List {
            Label("Notifications", systemImage: "bell")
            Label("Privacy", systemImage: "lock.shield")
            Label("About", systemImage: "info.circle")
        }
        .navigationTitle("Settings")
    }
}

// MARK: - Detail

/// Item detail screen. No navigation knowledge.
@available(iOS 16.0, macOS 13.0, *)
public struct DetailView: View {
    public let itemID: Int

    public init(itemID: Int) {
        self.itemID = itemID
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 56))
                .foregroundStyle(.tint)
            Text("Detail for Item #\(itemID)")
                .font(.title2.bold())
        }
        .navigationTitle("Detail")
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
    }
}
