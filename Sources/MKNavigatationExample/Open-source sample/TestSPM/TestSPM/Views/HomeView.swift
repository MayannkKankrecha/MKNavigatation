// HomeView.swift
// TestSPM — MVVM-C Demo
//
// Pure SwiftUI view. Zero navigation knowledge — all actions delegate to HomeViewModel.

import SwiftUI

struct HomeView: View {

    @StateObject var viewModel: HomeViewModel

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [Color(.systemBackground), Color(.secondarySystemBackground)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // ── Header ──
                    headerSection

                    // ── Product Grid ──
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(viewModel.products) { product in
                            ProductCard(product: product) {
                                viewModel.selectProduct(product)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }

            // ── Deep-link Demo Banner ──
            deepLinkBanner
        }
        .navigationTitle("Shop")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    viewModel.openProfile()
                } label: {
                    Label("Profile", systemImage: "person.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                }
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.openCart()
                } label: {
                    Label("Cart", systemImage: "cart.fill")
                        .symbolRenderingMode(.hierarchical)
                        .font(.title3)
                }
            }
        }
        .onAppear { viewModel.refreshStackDepth() }
    }

    // MARK: - Sub Views

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Welcome back 👋")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text("Discover Products")
                .font(.title2.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var deepLinkBanner: some View {
        Button {
            viewModel.triggerDeepLink()
        } label: {
            HStack {
                Image(systemName: "link.circle.fill")
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Deep-link Demo")
                        .font(.headline)
                    Text("Tap to replace stack → Cart directly")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}

// MARK: - Product Card

private struct ProductCard: View {
    let product: Product
    let onTap: () -> Void

    @State private var pressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 10) {
                // Artwork
                ZStack {
                    RoundedRectangle(cornerRadius: 14)
                        .fill(
                            LinearGradient(
                                colors: [Color.accentColor.opacity(0.15), Color.accentColor.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 110)
                    Image(systemName: product.systemImage)
                        .font(.system(size: 44))
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(Color.accentColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.subheadline.bold())
                        .lineLimit(2)
                        .foregroundStyle(.primary)

                    Text(product.category)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color.secondary.opacity(0.12), in: Capsule())

                    Text(product.formattedPrice)
                        .font(.callout.bold())
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 6)
            }
            .background(.background, in: RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: pressed)
        }
        .buttonStyle(.plain)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in pressed = true }
                .onEnded   { _ in pressed = false }
        )
    }
}

#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(coordinator: AppCoordinator()))
    }
}
