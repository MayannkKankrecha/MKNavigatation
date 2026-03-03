// ProfileViewModel.swift
// TestSPM — MVVM-C Demo

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {

    // MARK: - State

    @Published private(set) var username: String
    @Published private(set) var joinDate: String = "March 2026"
    @Published private(set) var orderCount: Int = 12

    // MARK: - Dependencies

    private let coordinator: AppCoordinator

    // MARK: - Init

    init(username: String, coordinator: AppCoordinator) {
        self.username = username
        self.coordinator = coordinator
    }

    // MARK: - Intents

    /// Pop back one step to the previous screen.
    func goBack() {
        coordinator.goBack()
    }

    /// Jump all the way back to Home — demonstrates popToRoot().
    func goHome() {
        coordinator.goHome()
    }
}
