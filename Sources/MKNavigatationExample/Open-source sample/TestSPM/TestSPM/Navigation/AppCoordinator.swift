// AppCoordinator.swift
// TestSPM — MVVM-C Demo
//
// The Coordinator sits between ViewModels and the NavigationRouter.
// ViewModels call semantic methods (showProductDetail, goHome, …) —
// they never touch AppRoute cases directly, keeping route knowledge
// centralised here and making ViewModels independently testable.

import SwiftUI
import Combine
import MKNavigatation

@MainActor
final class AppCoordinator: ObservableObject {

    // MARK: - Core Router (owned by the Coordinator)

    /// The MKNavigatation router that drives the NavigationStack.
    let router: NavigationRouter<AppRoute>

    // MARK: - Init

    init() {
        self.router = NavigationRouter<AppRoute>()
    }

    // MARK: - Semantic Navigation API

    /// Navigate to the product detail screen.
    func showProductDetail(_ product: Product) {
        router.push(.productDetail(productID: product.id))
    }

    /// Navigate to the user profile screen.
    func showProfile(username: String) {
        router.push(.profile(username: username))
    }

    /// Navigate to the shopping cart.
    func showCart() {
        router.push(.cart)
    }

    /// Go back one step (pop).
    func goBack() {
        router.pop()
    }

    /// Jump straight to the root (Home), clearing the entire stack.
    func goHome() {
        router.popToRoot()
    }

    /// Deep-link: replace the entire stack with a direct path to Cart.
    /// Simulates tapping a push notification "View Cart" action.
    func deepLinkToCart() {
        router.replace(with: [.cart])
    }

    // MARK: - Stack Info (for the live counter badge)

    /// Current depth of the navigation stack.
    var stackDepth: Int {
        router.path.count
    }
}
