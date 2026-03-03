// CartViewModel.swift
// TestSPM — MVVM-C Demo

import Foundation
import Combine

@MainActor
final class CartViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var items: [CartItem] = CartItem.sampleItems
    @Published private(set) var totalPrice: Double = 0

    // MARK: - Types

    struct CartItem: Identifiable {
        let id: UUID = UUID()
        let product: Product
        var quantity: Int

        var subtotal: Double { product.price * Double(quantity) }
        var formattedSubtotal: String { String(format: "$%.2f", subtotal) }

        static let sampleItems: [CartItem] = [
            CartItem(product: Product.samples[0], quantity: 1),
            CartItem(product: Product.samples[2], quantity: 1),
        ]
    }

    // MARK: - Dependencies

    private let coordinator: AppCoordinator

    // MARK: - Init

    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        recalculate()
    }

    // MARK: - Intents

    /// Continue shopping — pop the entire stack back to Home.
    func continueShopping() {
        coordinator.goHome()
    }

    // MARK: - Private

    private func recalculate() {
        totalPrice = items.reduce(0) { $0 + $1.subtotal }
    }
}
