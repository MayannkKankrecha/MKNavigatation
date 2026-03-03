// HomeViewModel.swift
// TestSPM — MVVM-C Demo

import Foundation
import Combine

@MainActor
final class HomeViewModel: ObservableObject {

    // MARK: - Published State

    @Published private(set) var products: [Product] = Product.samples
    @Published private(set) var stackDepth: Int = 0

    // MARK: - Dependencies

    private let coordinator: AppCoordinator

    // MARK: - Init

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Intent → Navigation (Views call these; coordinator owns routing)

    func selectProduct(_ product: Product) {
        coordinator.showProductDetail(product)
    }

    func openProfile() {
        coordinator.showProfile(username: "mayank_dev")
    }

    func openCart() {
        coordinator.showCart()
    }

    /// Triggers the deep-link replace demo (straight to Cart, clearing stack).
    func triggerDeepLink() {
        coordinator.deepLinkToCart()
    }

    /// Pull current stack depth so Home can show a badge.
    func refreshStackDepth() {
        stackDepth = coordinator.stackDepth
    }
}
