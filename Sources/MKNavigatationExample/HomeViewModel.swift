// HomeViewModel.swift
// Example — not part of the MKNavigatation library target.
//
// ViewModels are the ONLY layer that may call router methods.
// Views receive the ViewModel and know nothing about navigation.

import Foundation
import MKNavigatation

@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class HomeViewModel: ObservableObject {

    // MARK: - Dependencies

    /// Injected router — the ViewModel drives navigation, not the View.
    private let router: NavigationRouter<AppRoute>

    // MARK: - Published State

    @Published public var items: [String] = ["Item A", "Item B", "Item C"]

    // MARK: - Init

    public init(router: NavigationRouter<AppRoute>) {
        self.router = router
    }

    // MARK: - Navigation Actions

    /// Called when the user taps a list row.
    public func didSelectItem(at index: Int) {
        router.push(.detail(itemID: index))
    }

    /// Called when the user taps the Profile button.
    public func didTapProfile() {
        router.push(.profile(userID: "usr_42"))
    }

    /// Called when the user taps the Settings button.
    public func didTapSettings() {
        router.push(.settings)
    }

    /// Pops back one level (e.g., bound to a custom Back button).
    public func didTapBack() {
        router.pop()
    }

    /// Resets the stack to root (e.g., used on tab re-selection).
    public func didTapHome() {
        router.popToRoot()
    }

    /// Deep-link: replaces the entire stack.
    public func handleDeepLink(routes: [AppRoute]) {
        router.replace(with: routes)
    }
}
