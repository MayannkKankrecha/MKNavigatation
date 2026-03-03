// ProductDetailViewModel.swift
// TestSPM — MVVM-C Demo

import Foundation
import Combine

@MainActor
final class ProductDetailViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var product: Product
    @Published var addedToCart: Bool = false

    // MARK: - Dependencies

    private let coordinator: AppCoordinator

    // MARK: - Init

    init(product: Product, coordinator: AppCoordinator) {
        self.product = product
        self.coordinator = coordinator
    }

    // MARK: - Intents

    func goBack() {
        coordinator.goBack()
    }

    /// Demonstrates `replace(with:)` — tapping "Buy Now" deep-links to Cart
    /// discarding the Detail screen from the stack.
    func addToCartAndGoToCart() {
        addedToCart = true
        // Small delay so the user sees the feedback before the stack replaces.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { [weak self] in
            self?.coordinator.deepLinkToCart()
        }
    }
}
