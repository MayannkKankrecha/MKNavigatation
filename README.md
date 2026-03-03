# MKNavigatation

> A lightweight, SwiftUI-native navigation framework for iOS 16+.  
> No UIKit. No third-party dependencies. Just clean, testable routing.

---

## 📖 Table of Contents

1. [Why This Library Exists](#1-why-this-library-exists)
2. [Core Concept — The Problem With SwiftUI Navigation](#2-core-concept--the-problem-with-swiftui-navigation)
3. [How MKNavigatation Solves It](#3-how-mknavigation-solves-it)
4. [Architecture Overview](#4-architecture-overview)
5. [File & Folder Structure](#5-file--folder-structure)
6. [Deep Dive — Each File Explained](#6-deep-dive--each-file-explained)
   - [NavigationRoute.swift](#61-navigationrouteswift)
   - [NavigationRouter.swift](#62-navigationrouterswift)
   - [NavigationContainer.swift](#63-navigationcontainerswift)
7. [Step-by-Step Integration Guide](#7-step-by-step-integration-guide)
   - [Step 1 — Add the Package](#step-1--add-the-package)
   - [Step 2 — Define Your Routes](#step-2--define-your-routes)
   - [Step 3 — Create Your ViewModel](#step-3--create-your-viewmodel)
   - [Step 4 — Create Your Views](#step-4--create-your-views)
   - [Step 5 — Wire Everything at the App Level](#step-5--wire-everything-at-the-app-level)
8. [Complete Working Example](#8-complete-working-example)
9. [Navigation Cheat Sheet](#9-navigation-cheat-sheet)
10. [Multi-Tab Apps](#10-multi-tab-apps)
11. [Deep Linking](#11-deep-linking)
12. [Unit Testing Your ViewModels](#12-unit-testing-your-viewmodels)
13. [Common Mistakes to Avoid](#13-common-mistakes-to-avoid)
14. [Glossary](#14-glossary)

---

## 1. Why This Library Exists

When you first learn SwiftUI navigation, you might write something like this:

```swift
// ❌ Common beginner approach — navigation logic inside the View
struct HomeView: View {
    @State private var showProfile = false

    var body: some View {
        Button("Go to Profile") {
            showProfile = true   // navigation triggered from View
        }
        .navigationDestination(isPresented: $showProfile) {
            ProfileView()
        }
    }
}
```

This works for tiny apps, but **breaks down quickly** because:

- Navigation state is scattered across many Views — hard to track
- You cannot navigate from a ViewModel or in response to an API result
- You cannot deep-link (jump 3 screens deep) easily
- Unit testing navigation is nearly impossible

**MKNavigatation fixes all of this** by centralising navigation in one place: the `NavigationRouter`.

---

## 2. Core Concept — The Problem With SwiftUI Navigation

Think of navigation like a **stack of cards**:

```
Bottom (Root)
┌─────────────┐
│  Home       │  ← always here
├─────────────┤
│  Detail     │  ← pushed on top
├─────────────┤
│  Profile    │  ← pushed on top of Detail
└─────────────┘  ← user sees this
```

- **Push** = add a card on top (go forward)
- **Pop** = remove the top card (go back)
- **Pop to Root** = remove all cards except the bottom one
- **Replace** = throw away all cards, build a brand new stack

SwiftUI 16+ provides `NavigationStack` and `NavigationPath` to manage this stack. MKNavigatation provides a clean, ViewModel-friendly wrapper around them.

---

## 3. How MKNavigatation Solves It

The golden rule:

> **Views display UI. ViewModels decide where to go.**

```
User taps button
      │
      ▼
   View calls viewModel.didTapProfile()
      │
      ▼
   ViewModel calls router.push(.profile(userID: "123"))
      │
      ▼
   NavigationRouter updates its NavigationPath
      │
      ▼
   NavigationContainer (bound to router) automatically shows ProfileView
```

The View never imports navigation APIs. The ViewModel never imports SwiftUI.

---

## 4. Architecture Overview

```
┌──────────────────────────────────────────────────────────┐
│                        Your App                          │
│                                                          │
│   ┌─────────────────────────────────────────────────┐   │
│   │          NavigationContainer (Root)              │   │
│   │  (wraps NavigationStack, binds to router.path)  │   │
│   │                                                  │   │
│   │   ┌────────────┐    ┌───────────┐               │   │
│   │   │  HomeView  │───▶│DetailView │ ···           │   │
│   │   └─────┬──────┘    └───────────┘               │   │
│   │         │ calls                                  │   │
│   │   ┌─────▼──────────────┐                        │   │
│   │   │   HomeViewModel    │                         │   │
│   │   │  router.push(...)  │──────────────────┐      │   │
│   │   └────────────────────┘                  │      │   │
│   │                                           ▼      │   │
│   │                              ┌────────────────┐  │   │
│   │                              │NavigationRouter│  │   │
│   │                              │  (path: [...]) │  │   │
│   │                              └────────────────┘  │   │
│   └─────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

| Component | What it does | Who uses it |
|---|---|---|
| `NavigationRoute` | Protocol all route enums conform to | You define your routes |
| `NavigationRouter` | Holds the navigation stack state | ViewModels call its methods |
| `NavigationContainer` | Wraps `NavigationStack`, auto-reacts to router | App entry point only |

---

## 5. File & Folder Structure

```
MKNavigatation/
│
├── Package.swift                          ← SPM manifest
│
├── Sources/
│   │
│   ├── MKNavigatation/                   ← 📦 The library (import this)
│   │   ├── MKNavigatation.swift          ← Module re-export
│   │   ├── NavigationRoute.swift         ← Route protocol
│   │   ├── NavigationRouter.swift        ← Stack manager
│   │   └── NavigationContainer.swift     ← Root view wrapper
│   │
│   └── MKNavigatationExample/            ← 📱 Reference app (copy to your project)
│       ├── AppRoute.swift                ← Your app's routes
│       ├── HomeViewModel.swift           ← ViewModel with nav calls
│       ├── HomeView.swift                ← Pure UI, no nav logic
│       ├── DestinationViews.swift        ← Profile, Settings, Detail
│       └── ExampleApp.swift             ← @main entry point
│
└── Tests/
    └── MKNavigatationTests/
        └── MKNavigatationTests.swift     ← 12 unit tests
```

---

## 6. Deep Dive — Each File Explained

### 6.1 `NavigationRoute.swift`

```swift
public protocol NavigationRoute: Hashable {}
```

**What is a protocol?**  
A protocol is like a contract. Any type that says "I conform to `NavigationRoute`" is
promising to be `Hashable` (meaning each unique value can be used as a dictionary key or
inside a `NavigationPath`).

**What is `Hashable`?**  
SwiftUI's `NavigationPath` needs to identify each route uniquely. `Hashable` provides
that identity. Enums with associated values are `Hashable` by default when all their
associated values are also `Hashable`.

**Why a protocol and not a class/struct?**  
Using a protocol lets every feature module define its own `AppRoute` enum independently.
The library doesn't need to know your specific routes — it only needs to know they're `Hashable`.

---

### 6.2 `NavigationRouter.swift`

```swift
@available(iOS 16.0, macOS 13.0, *)
@MainActor
public final class NavigationRouter<Route: NavigationRoute>: ObservableObject {

    @Published public var path: NavigationPath

    public init() {
        self.path = NavigationPath()
    }

    public func push(_ route: Route)          { path.append(route) }
    public func pop()                          { guard !path.isEmpty else { return }; path.removeLast() }
    public func popToRoot()                    { path.removeLast(path.count) }
    public func replace(with routes: [Route]) { /* builds a new path */ }
}
```

**Breaking it down for beginners:**

| Keyword | Meaning |
|---|---|
| `final class` | This class cannot be subclassed |
| `<Route: NavigationRoute>` | Generic — works with *any* Route enum that conforms to our protocol |
| `ObservableObject` | SwiftUI will watch this object. When `path` changes, all bound views re-render |
| `@Published` | Marks `path` as a value SwiftUI observes — changes trigger UI updates |
| `@MainActor` | All navigation calls run on the main thread (required for UI updates) |
| `NavigationPath` | Apple's built-in type that represents an ordered stack of routes |

**What each method does:**

```swift
router.push(.profile(userID: "123"))
// Stack before: [home]
// Stack after:  [home, profile("123")]

router.pop()
// Stack before: [home, profile("123")]
// Stack after:  [home]

router.popToRoot()
// Stack before: [home, detail(1), profile("123")]
// Stack after:  [home]

router.replace(with: [.settings, .profile(userID: "456")])
// Stack before: (anything)
// Stack after:  [settings, profile("456")]
```

---

### 6.3 `NavigationContainer.swift`

```swift
@available(iOS 16.0, macOS 13.0, *)
public struct NavigationContainer<Route: NavigationRoute, Content: View>: View {

    @ObservedObject private var router: NavigationRouter<Route>
    private let content: () -> Content

    public init(router: NavigationRouter<Route>, @ViewBuilder content: @escaping () -> Content) {
        self.router = router
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            content()
        }
    }
}
```

**Breaking it down:**

| Part | Meaning |
|---|---|
| `@ObservedObject` | Watch the router — re-render when `router.path` changes |
| `$router.path` | The `$` creates a two-way binding so the stack and the router stay in sync |
| `@ViewBuilder` | Allows you to pass a closure that returns any SwiftUI View |
| `NavigationStack(path:)` | Apple's native iOS 16 stack, driven by our router's path |

**Why this indirection instead of using `NavigationStack` directly?**  
By hiding `NavigationStack` inside `NavigationContainer`, you ensure:
1. There is exactly ONE navigation stack per scope
2. Child views cannot accidentally create a second stack
3. You can swap the underlying implementation later without touching any View

---

## 7. Step-by-Step Integration Guide

### Step 1 — Add the Package

In Xcode: **File → Add Package Dependencies…**  
Paste your repository URL, or add locally via:

```swift
// In your app's Package.swift (if you use SPM for your app):
.package(path: "../MKNavigatation")
```

Then add `MKNavigatation` as a dependency of your app target.

---

### Step 2 — Define Your Routes

Create a file `AppRoute.swift` **in your app target** (not in the library):

```swift
import MKNavigatation

// Each case = one screen in your app
enum AppRoute: NavigationRoute {
    case home
    case productList
    case productDetail(id: Int)
    case userProfile(username: String)
    case settings
    case checkout
}
```

**Tips:**
- Use `case screenName` for screens with no parameters
- Use `case screenName(param: Type)` when the screen needs data
- All associated value types must be `Hashable` (String, Int, UUID are fine)

---

### Step 3 — Create Your ViewModel

```swift
import Foundation
import MKNavigatation

@available(iOS 16.0, *)
@MainActor
final class HomeViewModel: ObservableObject {

    // Inject the router — never create it here
    private let router: NavigationRouter<AppRoute>

    @Published var products: [Product] = []

    init(router: NavigationRouter<AppRoute>) {
        self.router = router
    }

    // MARK: - User Actions → Navigation

    func didTapProduct(_ product: Product) {
        router.push(.productDetail(id: product.id))
    }

    func didTapProfile() {
        router.push(.userProfile(username: "mayank"))
    }

    func didTapSettings() {
        router.push(.settings)
    }

    func didTapCheckout() {
        // Jump directly to checkout skipping intermediate screens
        router.replace(with: [.checkout])
    }

    func didTapBackToRoot() {
        router.popToRoot()
    }

    // MARK: - Business Logic (no navigation here)

    func loadProducts() async {
        // fetch from API...
        // then maybe navigate on success:
        // router.push(.productList)
    }
}
```

**Key rule:**  
The ViewModel calls `router.push/pop/replace`. The View calls ViewModel methods.  
The View never calls `router` directly.

---

### Step 4 — Create Your Views

```swift
import SwiftUI

struct HomeView: View {

    // The View owns its ViewModel, not the router
    @StateObject private var viewModel: HomeViewModel

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        // ✅ No NavigationLink, no navigationDestination here
        // ✅ No router imported here
        List(viewModel.products) { product in
            Button(product.name) {
                viewModel.didTapProduct(product)  // delegate to ViewModel
            }
        }
        .navigationTitle("Products")
    }
}
```

**What's intentionally missing from Views:**
- ❌ No `import MKNavigatation`
- ❌ No `NavigationLink`
- ❌ No `@State var isShowingX = false`
- ❌ No `.navigationDestination(isPresented:)` 

---

### Step 5 — Wire Everything at the App Level

```swift
import SwiftUI
import MKNavigatation

@available(iOS 16.0, *)
@main
struct MyApp: App {

    // Create ONE router at the top level
    @StateObject private var router = NavigationRouter<AppRoute>()

    var body: some Scene {
        WindowGroup {
            NavigationContainer(router: router) {
                // Root screen, inject router into ViewModel
                HomeView(viewModel: HomeViewModel(router: router))

                    // Declare ALL destinations in ONE place
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .home:
                            HomeView(viewModel: HomeViewModel(router: router))

                        case .productList:
                            ProductListView(viewModel: ProductListViewModel(router: router))

                        case .productDetail(let id):
                            ProductDetailView(productID: id)

                        case .userProfile(let username):
                            UserProfileView(username: username)

                        case .settings:
                            SettingsView()

                        case .checkout:
                            CheckoutView()
                        }
                    }
            }
        }
    }
}
```

**Why ONE `navigationDestination`?**  
Having a single switch statement makes it trivially easy to see every possible navigation destination in your app. Adding a new screen = adding one `case` here and one `case` to `AppRoute`.

---

## 8. Complete Working Example

Here's the full flow from zero to working app:

```
AppRoute.swift       → Defines .home, .profile(userID:), .settings
HomeViewModel.swift  → Calls router.push(.profile(userID: "x"))
HomeView.swift       → Calls viewModel.didTapProfile()
ExampleApp.swift     → Wires router → NavigationContainer → HomeView
```

The files are in `Sources/MKNavigatationExample/` — open them in Xcode to see the full code.

---

## 9. Navigation Cheat Sheet

```swift
// Go forward to a new screen
router.push(.settings)
router.push(.profile(userID: "abc"))

// Go back one screen (same as pressing the Back button)
router.pop()

// Jump all the way back to the first screen
router.popToRoot()

// Build an entirely new stack (great for deep links)
router.replace(with: [.productList, .productDetail(id: 99)])
// User will see productDetail(99). Pressing Back shows productList.

// Replace with empty = just go to root
router.replace(with: [])
```

---

## 10. Multi-Tab Apps

For apps with a tab bar, create **one router per tab**:

```swift
@main
struct MyTabApp: App {
    @StateObject private var homeRouter    = NavigationRouter<HomeRoute>()
    @StateObject private var profileRouter = NavigationRouter<ProfileRoute>()

    var body: some Scene {
        WindowGroup {
            TabView {
                NavigationContainer(router: homeRouter) {
                    HomeView(viewModel: HomeViewModel(router: homeRouter))
                        .navigationDestination(for: HomeRoute.self) { route in
                            // ...
                        }
                }
                .tabItem { Label("Home", systemImage: "house") }

                NavigationContainer(router: profileRouter) {
                    ProfileTabView(viewModel: ProfileTabViewModel(router: profileRouter))
                        .navigationDestination(for: ProfileRoute.self) { route in
                            // ...
                        }
                }
                .tabItem { Label("Profile", systemImage: "person") }
            }
        }
    }
}
```

Each tab has an independent route enum and router — no cross-contamination.

---

## 11. Deep Linking

When your app receives a deep link (e.g., a push notification or a URL), use `replace(with:)` to jump the user directly to any screen:

```swift
// Somewhere in your AppViewModel or SceneDelegate-equivalent
func handleDeepLink(_ url: URL) {
    // Parse the URL and decide the destination stack
    if url.path == "/checkout" {
        router.replace(with: [.productList, .checkout])
    } else if let productID = parseProductID(from: url) {
        router.replace(with: [.productList, .productDetail(id: productID)])
    }
}
```

The user will see the last screen in the array. Pressing Back will walk them back through the stack.

---

## 12. Unit Testing Your ViewModels

Because the router is an `ObservableObject`, you can inject it in tests and assert navigation happened:

```swift
import XCTest
@testable import MKNavigatation

@MainActor
final class HomeViewModelTests: XCTestCase {

    func testTappingProductPushesDetailRoute() {
        let router = NavigationRouter<AppRoute>()
        let viewModel = HomeViewModel(router: router)

        viewModel.didTapProduct(Product(id: 42, name: "Test"))

        // Verify the stack grew by 1
        XCTAssertEqual(router.path.count, 1)
    }

    func testCheckoutReplacesStack() {
        let router = NavigationRouter<AppRoute>()
        // Pre-populate a stack
        router.push(.productList)
        router.push(.productDetail(id: 1))

        let viewModel = HomeViewModel(router: router)
        viewModel.didTapCheckout()

        // Stack should now be just [.checkout]
        XCTAssertEqual(router.path.count, 1)
    }
}
```

**Why is this easy to test?**  
- `NavigationRouter` is a plain Swift class — no views, no simulators needed
- You inject it into the ViewModel, so tests can inspect it after calling actions
- No `XCUITest`, no view rendering — just pure logic

---

## 13. Common Mistakes to Avoid

### ❌ Creating the router inside a View

```swift
// WRONG — router dies when the view is recreated
struct HomeView: View {
    @StateObject private var router = NavigationRouter<AppRoute>()
}
```

```swift
// CORRECT — router lives at App or tab scope
@main
struct MyApp: App {
    @StateObject private var router = NavigationRouter<AppRoute>()
}
```

---

### ❌ Calling router from a View

```swift
// WRONG — View knows about navigation
Button("Profile") {
    router.push(.profile(userID: "123"))
}
```

```swift
// CORRECT — View delegates to ViewModel
Button("Profile") {
    viewModel.didTapProfile()
}
```

---

### ❌ Multiple `navigationDestination` declarations

```swift
// WRONG — declare only ONCE at the root
HomeView()
    .navigationDestination(for: AppRoute.self) { ... }    // ← declaration 1
    .someOtherModifier()

DetailView()
    .navigationDestination(for: AppRoute.self) { ... }    // ← declaration 2 ❌
```

Keep a **single** `.navigationDestination(for: AppRoute.self)` attached to your root view inside `NavigationContainer`.

---

### ❌ Calling `pop()` when the stack is empty

The library handles this gracefully (it's a no-op), but in your ViewModel you should only call `pop()` when you know there's something to pop back to.

---

## 14. Glossary

| Term | Plain English Meaning |
|---|---|
| **SPM** | Swift Package Manager — Apple's built-in tool for adding libraries to a project |
| **Protocol** | A contract/interface a type agrees to follow |
| **Generic** | Code that works with multiple types, specified at call site (e.g., `Router<AppRoute>`) |
| **ObservableObject** | A class that SwiftUI can watch for changes and re-render views accordingly |
| **@Published** | Marks a property so SwiftUI views update when it changes |
| **NavigationPath** | Apple's type representing an ordered list of navigation destinations |
| **NavigationStack** | SwiftUI iOS 16 view that shows content on top of a path-driven stack |
| **@MainActor** | Guarantees code runs on the main thread (required for UI updates) |
| **Coordinator pattern** | Architecture pattern where a separate object manages navigation flow — this library is a SwiftUI-native version |
| **Deep link** | A URL or notification that takes the user directly to a specific screen inside the app |
| **Hashable** | A type whose values can be hashed (used as keys) — required by `NavigationPath` |

---

> **Built with ❤️ for iOS 16+ · Pure SwiftUI · Zero UIKit · Zero third-party dependencies**
