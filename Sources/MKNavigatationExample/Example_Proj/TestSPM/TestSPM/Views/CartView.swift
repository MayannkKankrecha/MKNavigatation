// CartView.swift
// TestSPM — MVVM-C Demo
//
// Reached via deep-link (replace stack). "Continue Shopping" pops to root.

import SwiftUI

struct CartView: View {

    @StateObject var viewModel: CartViewModel

    var body: some View {
        VStack(spacing: 0) {
            // ── Item List ──
            List {
                Section {
                    ForEach(viewModel.items) { item in
                        CartRow(item: item)
                    }
                } header: {
                    Text("Your Items")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }

                Section {
                    // Demo explanation
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Deep-link / replace() Demo", systemImage: "info.circle.fill")
                            .font(.caption.bold())
                            .foregroundStyle(Color.pink)

                        Text("You arrived here via `router.replace(with: [.cart])`. The entire previous navigation stack was **discarded** and replaced with just this screen.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                    .listRowBackground(Color.pink.opacity(0.06))
                }
            }
            .listStyle(.insetGrouped)

            // ── Footer ──
            VStack(spacing: 12) {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(String(format: "$%.2f", viewModel.totalPrice))
                        .font(.title3.bold())
                        .foregroundStyle(Color.accentColor)
                }

                Button {
                    viewModel.continueShopping()
                } label: {
                    Label("Continue Shopping  (popToRoot)", systemImage: "house.fill")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.pink.gradient)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            .padding()
            .background(.background)
            .shadow(color: .black.opacity(0.06), radius: 8, y: -4)
        }
        .navigationTitle("Cart 🛒")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.continueShopping()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "house.fill").font(.callout)
                        Text("Home")
                    }
                    .foregroundStyle(Color.pink)
                }
            }
        }
    }
}

// MARK: - Cart Row

private struct CartRow: View {
    let item: CartViewModel.CartItem

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 52, height: 52)
                Image(systemName: item.product.systemImage)
                    .font(.title3)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(Color.accentColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.name)
                    .font(.subheadline.bold())
                Text("Qty: \(item.quantity)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(item.formattedSubtotal)
                .font(.subheadline.bold())
                .foregroundStyle(Color.accentColor)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        CartView(viewModel: CartViewModel(coordinator: AppCoordinator()))
    }
}
