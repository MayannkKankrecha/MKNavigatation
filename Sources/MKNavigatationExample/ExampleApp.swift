// ExampleApp.swift
// Example — not part of the MKNavigatation library target.
//
// The App entry point. This is the ONE place that wires the router,
// declares navigationDestination, and injects the ViewModel.
//
// Copy this pattern into your actual @main App struct.

import SwiftUI
import MKNavigatation

@available(iOS 16.0, macOS 13.0, *)
@main
struct ExampleApp: App {

    // MARK: - Navigation Router
    //
    // The router lives at the App scope (or per-tab for tabbed apps).
    // It is injected down the tree — never created inside a View.
    @StateObject private var router = NavigationRouter<AppRoute>()

    var body: some Scene {
        WindowGroup {
            // NavigationContainer owns the NavigationStack.
            // All push/pop/replace calls go through `router` from ViewModels.
            NavigationContainer(router: router) {
                // Root view — ViewModel receives the router.
                HomeView(
                    viewModel: HomeViewModel(router: router)
                )
                // Single navigationDestination declaration for AppRoute.
                // The container view is the ONLY place that maps routes → views.
                .navigationDestination(for: AppRoute.self) { route in
                    destination(for: route)
                }
            }
        }
    }

    // MARK: - Route → View Mapping

    /// Centralized switch that converts an `AppRoute` into a SwiftUI view.
    /// Add new cases here as your feature set grows.
    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(viewModel: HomeViewModel(router: router))

        case .profile(let userID):
            ProfileView(userID: userID)

        case .settings:
            SettingsView()

        case .detail(let itemID):
            DetailView(itemID: itemID)
        }
    }
}
