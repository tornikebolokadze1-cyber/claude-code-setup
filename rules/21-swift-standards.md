# Swift Production Standards

## Style

- `swift-format` and `swiftlint` are mandatory — no style debates
- Variables and functions: `lowerCamelCase`; types, protocols, enums: `UpperCamelCase`
- Maximum line length: 120 characters; trailing commas in multi-line collections
- One type per file when the type exceeds 200 lines; co-locate tests in the same module
- `// MARK: -` sections to separate lifecycle, private helpers, and protocol conformances

## Type Safety

- Prefer `struct` over `class` for value semantics; use `class` only for identity, reference sharing, or ObjC interop
- `let` over `var` everywhere — mutate only what must be mutable
- Never force-unwrap (`!`) outside `@IBOutlet`; use `guard let`, `if let`, or `??` with a sensible default
- `guard` + `defer` for early-exit and cleanup; keeps the happy path unindented
- `Codable` for all JSON serialization; define `CodingKeys` explicitly when server keys differ from Swift names

## Concurrency (Swift 6 Strict)

- All asynchronous code uses `async/await` — no callbacks or Combine publishers for new code
- `@Sendable` on all closures that cross actor or task boundaries — the compiler enforces this in strict mode
- `actor` for any shared mutable state accessed from multiple tasks; prefer actors over locks
- `@MainActor` on every class, function, or property that reads or writes UIKit/SwiftUI state
- Never block the main thread: no `Thread.sleep`, no synchronous networking, no heavy computation on `@MainActor`
- `TaskGroup` / `withThrowingTaskGroup` for structured concurrency; always cancel sibling tasks on first failure
- `async let` for concurrent independent operations within a single scope
- Never apply `@unchecked Sendable` without a documented invariant explaining why the type is safe

## Error Handling

- `throws` functions return specific error enums conforming to `Error`, not generic `Error` or `NSError`
- `Result<Success, Failure>` at async module boundaries where the caller decides how to handle failure
- Errors intended for user display conform to `LocalizedError` and provide `errorDescription`
- `do/catch` with exhaustive `catch` clauses — never bare `catch` that swallows the error type
- Log errors where they are handled, not where they are thrown; include context (function name, parameters)

## SwiftUI (April 2026 — iOS 17+ / macOS 14+)

- `@Observable` macro on all view models (replaces `ObservableObject` + `@Published`); requires iOS 17+
- `@State` for view-local ephemeral state; `@Bindable` to pass an `@Observable` model to a child view
- `@Environment` for dependency injection of services and repositories into the view hierarchy
- `.task { }` modifier for async work tied to a view's lifetime; `async let` inside for concurrency
- `PreviewProvider` (or `#Preview` macro) with realistic, non-empty data — never `Text("Hello")`
- Accessibility modifiers on every interactive element: `.accessibilityLabel`, `.accessibilityHint`, `.accessibilityRole`
- Extract subviews aggressively: `body` should read like a document outline, not a 200-line function
- `NavigationStack` over deprecated `NavigationView`; typed navigation paths for deep-link support

## Architecture

- MVVM: views are dumb, view models are `@Observable` and own async operations
- Dependency injection via initializers — no singletons, no global state accessible without injection
- Repository pattern for data access: protocol defines the interface; concrete impl lives in `Core/`
- Feature-based folder structure (not type-based): all files for a feature live together
- `@MainActor` on view model classes; background work dispatched explicitly with `Task.detached` or `actor`

## Testing

- Swift Testing framework (`@Test`, `@Suite`, `#expect`, `#require`) for all new test code; requires Swift 5.9+
- XCTest kept for legacy tests and UI test bundles where Swift Testing support is incomplete
- `ViewInspector` for asserting SwiftUI view hierarchy structure and state
- Snapshot tests via `swift-snapshot-testing` for complex layouts
- Async tests: `@Test` functions are `async` natively; `#expect(throws:)` for error cases
- `ConfirmationKind` (Swift Testing) for asserting that an async event fires exactly N times
- Coverage target: 80%+; run with `xcodebuild test -enableCodeCoverage YES`

## Project Structure

```text
Sources/
  MyApp/
    App.swift                 # @main entry point
    Features/
      Home/                   # HomeView.swift, HomeViewModel.swift, HomeRepository.swift
      Profile/
    Core/
      Networking/             # URLSession wrappers, API client, interceptors
      Persistence/            # SwiftData / CoreData stack, file storage
    Shared/
      UI/                     # reusable views, modifiers, view extensions
      Extensions/             # Foundation + SwiftUI extensions
Tests/
  MyAppTests/                 # unit + integration (@Test)
  MyAppUITests/               # XCUITest UI tests
Package.swift                 # or MyApp.xcodeproj
```

## Dependency Management

- Swift Package Manager (SPM) is preferred for all new projects — no CocoaPods in greenfield code
- Commit `Package.resolved` to lock transitive dependency versions
- Review SPM dependencies with `swift package show-dependencies` before adding new ones
- Minimum viable dependency list — avoid packages that replicate standard library functionality

## Performance

- Profile with Instruments before optimizing: Time Profiler for CPU, Allocations for memory
- `@inlinable` on hot-path public functions in SPM framework targets
- Avoid ARC retain cycles: `[weak self]` in closures that outlive the capturing scope; verify with Instruments Leaks
- Batch UI updates in a single `@MainActor` context rather than dispatching many small updates
- `LazyVStack` / `LazyHStack` / `List` over `VStack` / `HStack` for large collections

## Platform Support

- iOS 17+ and macOS 14+ as the minimum for new projects — required for `@Observable` macro
- visionOS 1.2+ when building spatial features
- `#available(iOS 17, *)` guards when back-deploying a feature to an older target; always provide a fallback path
- Universal purchase / multi-platform targets share `Sources/`; platform-specific code in `#if os(iOS)` blocks
