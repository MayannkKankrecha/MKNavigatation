// MKNavigatationTests.swift
// MKNavigatationTests
//
// Unit tests for NavigationRouter covering all public API surfaces.

import XCTest
@testable import MKNavigatation

// MARK: - Test Route

/// A minimal route enum used exclusively in tests.
private enum TestRoute: NavigationRoute {
    case alpha
    case beta
    case gamma(id: Int)
}

// MARK: - NavigationRouter Tests

@MainActor
final class NavigationRouterTests: XCTestCase {

    private var router: NavigationRouter<TestRoute>!

    override func setUp() async throws {
        try await super.setUp()
        router = NavigationRouter<TestRoute>()
    }

    override func tearDown() async throws {
        router = nil
        try await super.tearDown()
    }

    // MARK: Initial State

    func testInitialPathIsEmpty() {
        XCTAssertTrue(router.path.isEmpty, "Router path should be empty on init.")
        XCTAssertEqual(router.path.count, 0)
    }

    // MARK: push(_:)

    func testPushAppendsRoute() {
        router.push(.alpha)
        XCTAssertEqual(router.path.count, 1)
    }

    func testMultiplePushesAccumulate() {
        router.push(.alpha)
        router.push(.beta)
        router.push(.gamma(id: 7))
        XCTAssertEqual(router.path.count, 3)
    }

    // MARK: pop()

    func testPopDecreasesCount() {
        router.push(.alpha)
        router.push(.beta)
        router.pop()
        XCTAssertEqual(router.path.count, 1)
    }

    func testPopOnEmptyPathIsNoOp() {
        // Should not crash or mutate state.
        router.pop()
        XCTAssertEqual(router.path.count, 0)
    }

    // MARK: popToRoot()

    func testPopToRootClearsStack() {
        router.push(.alpha)
        router.push(.beta)
        router.push(.gamma(id: 1))
        router.popToRoot()
        XCTAssertTrue(router.path.isEmpty)
        XCTAssertEqual(router.path.count, 0)
    }

    func testPopToRootOnEmptyPathIsNoOp() {
        router.popToRoot()
        XCTAssertEqual(router.path.count, 0)
    }

    // MARK: replace(with:)

    func testReplaceWithRoutesBuildsNewStack() {
        // Start with a populated stack.
        router.push(.alpha)
        router.push(.beta)

        // Replace with a single route.
        router.replace(with: [.gamma(id: 42)])
        XCTAssertEqual(router.path.count, 1)
    }

    func testReplaceWithEmptyArrayClearsStack() {
        router.push(.alpha)
        router.push(.beta)
        router.replace(with: [])
        XCTAssertTrue(router.path.isEmpty)
    }

    func testReplaceWithMultipleRoutesBuildsCorrectCount() {
        router.replace(with: [.alpha, .beta, .gamma(id: 99)])
        XCTAssertEqual(router.path.count, 3)
    }

    // MARK: @Published change notification

    func testPushPublishesChange() {
        let expectation = XCTestExpectation(description: "path change published")
        let cancellable = router.$path.dropFirst().sink { _ in
            expectation.fulfill()
        }

        router.push(.alpha)

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }

    func testPopPublishesChange() {
        router.push(.alpha) // pre-populate

        let expectation = XCTestExpectation(description: "pop change published")
        let cancellable = router.$path.dropFirst().sink { _ in
            expectation.fulfill()
        }

        router.pop()

        wait(for: [expectation], timeout: 1.0)
        cancellable.cancel()
    }
}
