// ProductDetailView.swift
// TestSPM — MVVM-C Demo
//
// Shows product info + "Add to Cart" (triggers deep-link replace demo).
// Pure SwiftUI — zero navigation logic.

import SwiftUI

struct ProductDetailView: View {

    @StateObject var viewModel: ProductDetailViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ── Hero ──
                heroSection

                // ── Details ──
                detailsSection
                    .padding(.horizontal)
                    .padding(.top, 24)

                // ── Actions ──
                actionsSection
                    .padding()
                    .padding(.bottom, 32)
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.goBack()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.callout.bold())
                        Text("Back")
                    }
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - Sections

    private var heroSection: some View {
        ZStack(alignment: .bottom) {
            // gradient bg
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [Color.accentColor.opacity(0.25), Color.accentColor.opacity(0.06)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 280)

            Image(systemName: viewModel.product.systemImage)
                .font(.system(size: 100))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(Color.accentColor)
                .symbolEffect(.pulse)
                .padding(.bottom, 24)
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.product.category.uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(Color.accentColor)
                    .tracking(1.2)

                Text(viewModel.product.name)
                    .font(.title.bold())

                Text(viewModel.product.formattedPrice)
                    .font(.title2.bold())
                    .foregroundStyle(Color.accentColor)
            }

            Divider()

            Text("About this product")
                .font(.headline)

            Text(viewModel.product.description)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)

            // Navigation demo badge
            VStack(alignment: .leading, spacing: 8) {
                Label("MVVM-C Navigation Demo", systemImage: "info.circle.fill")
                    .font(.caption.bold())
                    .foregroundStyle(Color.orange)

                Text("Tapping **\"Buy Now\"** calls `coordinator.deepLinkToCart()` which calls `router.replace(with: [.cart])` — replacing the entire navigation stack instantly.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange.opacity(0.25), lineWidth: 1)
            )
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.addToCartAndGoToCart()
            } label: {
                HStack {
                    Image(systemName: viewModel.addedToCart ? "checkmark.circle.fill" : "cart.badge.plus")
                        .symbolEffect(.bounce, value: viewModel.addedToCart)
                    Text(viewModel.addedToCart ? "Going to Cart…" : "Buy Now  →  Cart (replace stack)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    viewModel.addedToCart
                        ? Color.green.gradient
                        : Color.accentColor.gradient
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .disabled(viewModel.addedToCart)

            Button {
                viewModel.goBack()
            } label: {
                Text("Go Back  (pop)")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.primary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProductDetailView(
            viewModel: ProductDetailViewModel(
                product: Product.samples[0],
                coordinator: AppCoordinator()
            )
        )
    }
}
