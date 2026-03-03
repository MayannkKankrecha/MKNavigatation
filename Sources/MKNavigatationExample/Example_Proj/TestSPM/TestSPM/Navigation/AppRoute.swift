// AppRoute.swift
// TestSPM — MVVM-C Demo
//
// All navigable destinations in the app are declared here as a single,
// type-safe enum. ViewModels never use strings or UIKit; they just push
// one of these cases onto the coordinator.

import MKNavigatation

/// Every screen in the demo app.
enum AppRoute: NavigationRoute {
    /// The product listing (root).
    case home
    /// Product detail for the given product ID.
    case productDetail(productID: Int)
    /// User profile for the given username.
    case profile(username: String)
    /// Shopping cart.
    case cart
}
