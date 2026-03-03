// NavigationRoute.swift
// MKNavigatation
//
// A type-safe route contract. Every feature module defines its own enum
// conforming to this protocol — no stringly-typed destinations.

import Foundation

/// Marker protocol that every app-level or feature-level route enum must conform to.
/// Conforming types must be `Hashable` so they work seamlessly with `NavigationPath`.
///
/// Usage:
/// ```swift
/// enum AppRoute: NavigationRoute {
///     case home
///     case profile(userID: String)
///     case settings
/// }
/// ```
public protocol NavigationRoute: Hashable {}
