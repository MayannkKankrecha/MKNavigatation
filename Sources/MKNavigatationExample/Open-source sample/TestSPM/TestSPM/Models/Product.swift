// Product.swift
// TestSPM — MVVM-C Demo
//
// The domain model for this demo. Plain Swift struct — zero UI deps.

import Foundation

struct Product: Identifiable, Hashable {
    let id: Int
    let name: String
    let price: Double
    let description: String
    let category: String
    let systemImage: String   // SF Symbol used as product artwork

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }
}

// MARK: - Sample Data

extension Product {
    static let samples: [Product] = [
        Product(
            id: 1,
            name: "AirPods Pro",
            price: 249.00,
            description: "Active noise cancellation for immersive sound. Transparency mode for hearing the world around you.",
            category: "Audio",
            systemImage: "airpodspro"
        ),
        Product(
            id: 2,
            name: "MacBook Air M3",
            price: 1_099.00,
            description: "Strikingly thin design, the M3 chip, and up to 18 hours of battery life.",
            category: "Computers",
            systemImage: "laptopcomputer"
        ),
        Product(
            id: 3,
            name: "iPhone 16 Pro",
            price: 999.00,
            description: "A17 Pro chip. Titanium design. The most powerful iPhone ever built.",
            category: "Phones",
            systemImage: "iphone.gen3"
        ),
        Product(
            id: 4,
            name: "Apple Watch Ultra 2",
            price: 799.00,
            description: "The most rugged and capable Apple Watch. Built for endurance athletes and adventurers.",
            category: "Wearables",
            systemImage: "applewatch.watchface"
        ),
        Product(
            id: 5,
            name: "iPad Pro M4",
            price: 1_299.00,
            description: "Thin beyond belief. Incredibly powerful. The ultimate iPad.",
            category: "Tablets",
            systemImage: "ipad.gen2"
        ),
        Product(
            id: 6,
            name: "Apple TV 4K",
            price: 129.00,
            description: "Cinematic quality streaming with Dolby Vision and Dolby Atmos.",
            category: "TV & Home",
            systemImage: "appletv"
        ),
    ]
}
