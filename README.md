# MKNavigatation

A lightweight, ViewModel-driven navigation framework for SwiftUI — no NavigationLink spaghetti, no UIKit.

---

## Why MKNavigatation?

SwiftUI's built-in navigation works well for simple apps, but it does not scale. As applications grow, three problems emerge consistently:

**NavigationLink couples views to destinations.** A view must know which screen it leads to. In a modular codebase, this forces feature modules to import each other, breaking the dependency hierarchy.

**Views become responsible for navigation logic.** Conditional navigation, deep-link handling, and programmatic stack resets all end up in the view layer — where they do not belong.

**Navigation state is hard to test.** NavigationLink is declarative but opaque. Testing whether a navigation event happened requires launching the full view hierarchy.

MKNavigatation separates navigation intent from navigation execution. ViewModels decide where to go. A central router holds the state. Views remain completely unaware.

---

## Key Features

- **ViewModel-driven navigation** — views call ViewModel methods; ViewModels call the router
- **Type-safe routes** — every destination is an `enum` case, not a string or type-erased value
- **Single `NavigationPath` owner** — one router per navigation scope; no hidden state
- **Full programmatic control** — push, pop, pop-to-root, and full stack replacement
- **Zero UIKit dependency** — built entirely on `NavigationStack` and `NavigationPath`
- **Coordinator-inspired** — centralized route-to-view mapping in one switch statement
- **Modular-architecture ready** — each feature module defines its own `Route` enum
- **iOS 16+, macOS 13+** — no minimum version compromises

---

## Architecture Overview

The framework has three public types:

### `NavigationRoute`

A marker protocol. Every app or feature module defines a `Route` enum that conforms to it. Conforming types must be `Hashable` so they integrate with `NavigationPath`.

```swift
public protocol NavigationRoute: Hashable {}
```

### `NavigationRouter<Route>`

A generic `ObservableObject` that owns the `NavigationPath` for a given route type. It exposes four navigation methods:

| Method | Effect |
|---|---|
| `push(_ route:)` | Pushes one screen onto the stack |
| `pop()` | Removes the top-most screen |
| `popToRoot()` | Clears the entire stack |
| `replace(with:)` | Replaces the stack with a new ordered sequence of routes |

Only ViewModels should call these methods. Views never hold a reference to a router.

### `NavigationContainer<Route, Content>`

A thin `SwiftUI.View` wrapper around `NavigationStack`. It binds to a `NavigationRouter` and provides the navigation stack. Place it once at the root of a navigation scope — one `NavigationContainer` per tab, one per flow.

The `content` closure is where `navigationDestination(for:)` lives. This is the only place in the app where routes are mapped to views.

### Navigation Flow

```
User action
    │
    ▼
View (navigation-free)
    │ calls ViewModel method
    ▼
ViewModel
    │ calls router.push / pop / popToRoot / replace
    ▼
NavigationRouter (ObservableObject)
    │ mutates @Published path
    ▼
NavigationContainer
    │ NavigationStack reflects new path
    ▼
navigationDestination resolves Route → View
```

This mirrors the Coordinator pattern without requiring UIKit, protocol delegates, or a separate coordinator object.

---

## Installation

### Swift Package Manager (Xcode)

1. Open your project in Xcode.
2. Go to **File > Add Package Dependencies**.
3. Enter the repository URL:

```
https://github.com/MayannkKankrecha/MKNavigatation
```

4. Select **Up to Next Major Version** starting from `1.0.0`.
5. Add `MKNavigatation` to your app target.

### Package.swift

```swift
dependencies: [
    .package(url: "https://github.com/MayannkKankrecha/MKNavigatation", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["MKNavigatation"]
    )
]
```

---

## Quick Start

### Step 1 — Define your routes

Create an enum in your app target (not in a library target) that conforms to `NavigationRoute`.

```swift
import MKNavigatation

enum AppRoute: NavigationRoute {
    case home
    case profile(userID: String)
    case settings
    case detail(itemID: Int)
}
```

Associated values are fully supported. The enum is type-safe — invalid routes cannot be constructed.

### Step 2 — Create a router

Instantiate `NavigationRouter` at the appropriate scope. For most apps this is the `App` struct or a tab root. The generic parameter ties the router to your route type.

```swift
@StateObject private var router = NavigationRouter<AppRoute>()
```

### Step 3 — Wrap your root view with NavigationContainer

`NavigationContainer` owns the `NavigationStack`. Provide the router and a content closure. Inside the closure, declare all `navigationDestination` modifiers for your route type — this is the single, centralized switch from `AppRoute` to a SwiftUI view.

```swift
NavigationContainer(router: router) {
    HomeView(viewModel: HomeViewModel(router: router))
        .navigationDestination(for: AppRoute.self) { route in
            switch route {
            case .home:
                HomeView(viewModel: HomeViewModel(router: router))
            case .profile(let userID):
                ProfileView(userID: userID)
            case .settings:
                SettingsView()
            case .detail(let itemID):
                DetailView(itemID: itemID)
            }
        }
}
```

### Step 4 — Trigger navigation from a ViewModel

The ViewModel receives the router via initializer injection. It calls router methods in response to user actions or business logic.

```swift
import MKNavigatation

@MainActor
final class HomeViewModel: ObservableObject {
    private let router: NavigationRouter<AppRoute>

    init(router: NavigationRouter<AppRoute>) {
        self.router = router
    }

    func didSelectItem(at index: Int) {
        router.push(.detail(itemID: index))
    }

    func didTapProfile() {
        router.push(.profile(userID: "usr_42"))
    }

    func didTapSettings() {
        router.push(.settings)
    }

    func didTapBack() {
        router.pop()
    }

    func didTapHome() {
        router.popToRoot()
    }

    func handleDeepLink(routes: [AppRoute]) {
        router.replace(with: routes)
    }
}
```

### Step 5 — Keep views navigation-free

The view owns its ViewModel and nothing else. There is no `NavigationLink`, no router reference, no route import.

```swift
import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List(viewModel.items.indices, id: \.self) { index in
            Button(viewModel.items[index]) {
                viewModel.didSelectItem(at: index)
            }
        }
        .navigationTitle("Home")
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Profile") { viewModel.didTapProfile() }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button("Settings") { viewModel.didTapSettings() }
            }
        }
    }
}
```

The view has no knowledge of `AppRoute`, `NavigationRouter`, or any navigation infrastructure.

---

## Complete Example

The following shows a minimal but complete wiring in the `App` entry point.

```swift
import SwiftUI
import MKNavigatation

@main
struct ExampleApp: App {

    @StateObject private var router = NavigationRouter<AppRoute>()

    var body: some Scene {
        WindowGroup {
            NavigationContainer(router: router) {
                HomeView(viewModel: HomeViewModel(router: router))
                    .navigationDestination(for: AppRoute.self) { route in
                        destination(for: route)
                    }
            }
        }
    }

    @ViewBuilder
    private func destination(for route: AppRoute) -> some View {
        switch route {
        case .home:
            HomeView(viewModel: HomeViewModel(router: router))
        case .profile(let userID):
            ProfileView(userID: userID)
        case .settings:
            SettingsView()
        case .detail(let itemID):
            DetailView(itemID: itemID)
        }
    }
}
```

This is the only file in the app that imports both `MKNavigatation` and every feature view. All other files import only what they need.

---

## Package Structure

```
MKNavigatation/
├── Package.swift
├── Sources/
│   ├── MKNavigatation/                  # Public library — add this as your dependency
│   │   ├── MKNavigatation.swift         # Module umbrella / public re-exports
│   │   ├── NavigationRoute.swift        # NavigationRoute protocol
│   │   ├── NavigationRouter.swift       # NavigationRouter<Route> class
│   │   └── NavigationContainer.swift    # NavigationContainer<Route, Content> view
│   │
│   └── MKNavigatationExample/           # Reference example — not a library product
│       ├── AppRoute.swift               # Sample route enum
│       ├── ExampleApp.swift             # App entry point and router wiring
│       ├── HomeView.swift               # Navigation-free root view
│       ├── HomeViewModel.swift          # ViewModel that drives navigation
│       └── DestinationViews.swift       # Destination screen stubs
│
└── Tests/
    └── MKNavigatationTests/             # Unit tests for router behaviour
```

The library target (`MKNavigatation`) contains the four source files. The example target (`MKNavigatationExample`) is not shipped as a library product — it is reference material. Copy the patterns into your own app target.

---

## When to Use MKNavigatation

This framework is well-suited for:

- **Medium to large apps** with multiple screens and navigation flows
- **Modular architectures** where features are separate Swift targets or packages
- **MVVM or MVVM-C** codebases where business logic lives outside views
- **Apps with deep linking** that require programmatic stack replacement
- **Teams** that want a consistent, testable navigation contract across features

---

## When Not to Use MKNavigatation

- **Single-screen apps** or simple two-screen demos where NavigationLink is sufficient
- **Apps targeting iOS 15 or earlier** — `NavigationStack` is an iOS 16+ API
- Projects where navigation is not a maintenance concern

---

## Requirements

| Requirement | Minimum Version |
|---|---|
| iOS | 16.0 |
| macOS | 13.0 |
| tvOS | 16.0 |
| watchOS | 9.0 |
| Swift | 5.9 |
| Xcode | 15.0 |

---

## Roadmap

The following capabilities are planned for future releases:

- **Modal navigation** — `sheet`, `fullScreenCover`, and `popover` support driven through the router
- **Deep link parsing** — URL-to-route conversion utilities with composable matchers
- **Multi-router support** — coordinated navigation across independent stacks (e.g., tabbed apps with isolated flows)
- **Router composition** — child routers that can delegate upward to a parent scope

Contributions and issue reports are welcome via GitHub.

---

## License

MIT License

Copyright (c) 2024 Mayank Kankrecha

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
