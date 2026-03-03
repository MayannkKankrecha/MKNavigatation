// NavigationContainer.swift
// MKNavigatation
//
// A thin SwiftUI wrapper around NavigationStack that binds to the router.
// This is the ONLY navigation-aware view — all other views stay pure.

import SwiftUI

/// A SwiftUI view that wraps `NavigationStack` and wires it to a `NavigationRouter`.
///
/// Place `NavigationContainer` at the root of your navigation scope and provide
/// a `content` closure that returns the root view plus any `navigationDestination`
/// modifiers. The router drives all pushes and pops; child views remain completely
/// ignorant of the navigation infrastructure.
///
/// ```swift
/// NavigationContainer(router: appRouter) {
///     HomeView()
///         .navigationDestination(for: AppRoute.self) { route in
///             switch route {
///             case .profile(let id): ProfileView(userID: id)
///             case .settings:        SettingsView()
///             }
///         }
/// }
/// ```
@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
public struct NavigationContainer<Route: NavigationRoute, Content: View>: View {

    // MARK: - Dependencies

    /// The router whose `path` is bound to the underlying `NavigationStack`.
    @ObservedObject private var router: NavigationRouter<Route>

    /// The root content (and destination declarations) for the navigation stack.
    private let content: () -> Content

    // MARK: - Init

    /// Creates a `NavigationContainer` bound to the given router.
    /// - Parameters:
    ///   - router: The `NavigationRouter` that controls this stack.
    ///   - content: A view-builder closure returning the root view.
    public init(
        router: NavigationRouter<Route>,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.router = router
        self.content = content
    }

    // MARK: - Body

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
        }
    }
}
