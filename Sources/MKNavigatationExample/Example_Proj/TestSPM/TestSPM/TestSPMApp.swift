//
//  TestSPMApp.swift
//  TestSPM
//
//  Created by Mayank  on 03/03/26.
//

import SwiftUI
import MKNavigatation

@main
struct TestSPMApp: App {

    // MARK: - Coordinator (root of the MVVM-C tree)

    /// One coordinator per navigation scope. @StateObject keeps it alive
    /// for the lifetime of the app's window group.
    @StateObject private var coordinator = AppCoordinator()

    var body: some Scene {
        WindowGroup {
            // NavigationContainer is the ONLY view that knows about NavigationStack.
            // It binds the coordinator's router.path to the stack.
            NavigationContainer(router: coordinator.router) {
                HomeView(viewModel: HomeViewModel(coordinator: coordinator))

                    // ── All Route → View mappings live HERE (not in views) ──
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {

                        case .home:
                            HomeView(viewModel: HomeViewModel(coordinator: coordinator))

                        case .productDetail(let productID):
                            // Look up the product by ID; fall back to first sample.
                            let product = Product.samples.first { $0.id == productID }
                                       ?? Product.samples[0]
                            ProductDetailView(
                                viewModel: ProductDetailViewModel(
                                    product: product,
                                    coordinator: coordinator
                                )
                            )

                        case .profile(let username):
                            ProfileView(
                                viewModel: ProfileViewModel(
                                    username: username,
                                    coordinator: coordinator
                                )
                            )

                        case .cart:
                            CartView(viewModel: CartViewModel(coordinator: coordinator))
                        }
                    }
            }
            // Surface coordinator changes to every child view that needs depth.
            .environmentObject(coordinator)
        }
    }
}
