// ProfileView.swift
// TestSPM — MVVM-C Demo
//
// Demonstrates popToRoot (goHome) — jumps directly to Home clearing the stack.

import SwiftUI

struct ProfileView: View {

    @StateObject var viewModel: ProfileViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ── Avatar ──
                avatarSection
                    .padding(.top, 16)

                // ── Info ──
                infoCards

                // ── Navigation Demo Explanation ──
                democard

                Spacer(minLength: 32)

                // ── Actions ──
                actionsSection
                    .padding(.horizontal)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { viewModel.goBack() } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left").font(.callout.bold())
                        Text("Back")
                    }
                    .foregroundStyle(Color.accentColor)
                }
            }
        }
    }

    // MARK: - Sub Views

    private var avatarSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor, Color.purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 16)

                Image(systemName: "person.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.white)
            }

            Text("@\(viewModel.username)")
                .font(.title2.bold())

            Text("Member since \(viewModel.joinDate)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var infoCards: some View {
        HStack(spacing: 16) {
            StatCard(label: "Orders", value: "\(viewModel.orderCount)", icon: "shippingbox.fill")
            StatCard(label: "Wishlist", value: "7", icon: "heart.fill")
            StatCard(label: "Reviews", value: "4", icon: "star.fill")
        }
    }

    private var democard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("popToRoot() Demo", systemImage: "info.circle.fill")
                .font(.caption.bold())
                .foregroundStyle(Color.indigo)

            Text("Tapping **\"Go Home\"** calls `coordinator.goHome()` → `router.popToRoot()`. This removes every screen from the stack and returns you directly to Home in one step.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.indigo.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
        )
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.goHome()
            } label: {
                Label("Go Home  (popToRoot)", systemImage: "house.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.indigo.gradient)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }

            Button {
                viewModel.goBack()
            } label: {
                Label("Go Back  (pop)", systemImage: "chevron.left")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.primary)
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let label: String
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color.accentColor)
                .symbolRenderingMode(.hierarchical)
            Text(value)
                .font(.title3.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    NavigationStack {
        ProfileView(
            viewModel: ProfileViewModel(username: "mayank_dev", coordinator: AppCoordinator())
        )
    }
}
