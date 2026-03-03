// HomeView.swift
// Example — not part of the MKNavigatation library target.
//
// IMPORTANT: This view has ZERO navigation imports or calls.
// It only owns its ViewModel and reacts to user input by calling ViewModel methods.

import SwiftUI

/// The root home screen.
/// Navigation is driven entirely by `HomeViewModel` — this view is navigation-agnostic.
@available(iOS 16.0, macOS 13.0, *)
public struct HomeView: View {

    // MARK: - Dependencies

    @StateObject private var viewModel: HomeViewModel

    // MARK: - Init

    public init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    public var body: some View {
        List {
            ForEach(viewModel.items.indices, id: \.self) { index in
                Button(viewModel.items[index]) {
                    viewModel.didSelectItem(at: index)
                }
            }
        }
        .navigationTitle("Home")
        .toolbar {
#if os(iOS)
            ToolbarItem(placement: .topBarLeading) {
                Button("Profile") {
                    viewModel.didTapProfile()
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings") {
                    viewModel.didTapSettings()
                }
            }
#else
            ToolbarItem(placement: .navigation) {
                Button("Profile") { viewModel.didTapProfile() }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Settings") { viewModel.didTapSettings() }
            }
#endif
        }
    }
}
