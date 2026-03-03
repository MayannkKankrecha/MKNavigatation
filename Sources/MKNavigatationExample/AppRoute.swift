// AppRoute.swift
// Example — not part of the MKNavigatation library target.
//
// Each app (or feature module) defines its own Route enum.
// Add this file directly to your app target — do NOT add it to the SPM library.

import MKNavigatation

// MARK: - Route Definition

/// All navigable screens in the demo application.
/// Conforms to `NavigationRoute` (which inherits `Hashable`).
public enum AppRoute: NavigationRoute {
    case home
    case profile(userID: String)
    case settings
    case detail(itemID: Int)
}
