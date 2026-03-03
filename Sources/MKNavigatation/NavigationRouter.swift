// NavigationRouter.swift
// MKNavigatation
//
// The central navigation state-holder. ViewModels own an instance of this
// class and call its methods to drive all navigation. Views never touch it.

import SwiftUI
import Combine

/// A generic, ObservableObject router that owns the `NavigationPath` for a
/// given `Route` type. Instantiate one router per navigation stack scope
/// (e.g., per tab or per feature flow).
///
/// - Important: Only ViewModels should call navigation methods. Views only
///   read `router.path` via the bound `NavigationContainer`.
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
@MainActor
public final class NavigationRouter<Route: NavigationRoute>: ObservableObject {

    // MARK: - Published State

    /// The navigation path consumed by `NavigationStack`. Mutations here are
    /// automatically reflected in the bound `NavigationContainer`.
    @Published public var path: NavigationPath

    // MARK: - Init

    /// Creates a router with an empty (root) navigation path.
    public init() {
        self.path = NavigationPath()
    }

    // MARK: - Navigation API

    /// Pushes a new route onto the stack — equivalent to a forward navigation.
    /// - Parameter route: The destination to navigate to.
    public func push(_ route: Route) {
        path.append(route)
    }

    /// Pops the top-most route off the stack — equivalent to pressing Back.
    /// A no-op when already at the root.
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops all routes back to the root — equivalent to tapping a tab bar icon.
    public func popToRoot() {
        path.removeLast(path.count)
    }

    /// Replaces the entire navigation stack with a new set of routes.
    /// Useful for deep-link handling or resetting flow state.
    /// - Parameter routes: An ordered array of routes forming the new stack.
    public func replace(with routes: [Route]) {
        var newPath = NavigationPath()
        routes.forEach { newPath.append($0) }
        path = newPath
    }
}
