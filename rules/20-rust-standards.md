# Rust Production Standards

## Style

- `cargo fmt` and `cargo clippy -- -D warnings` are mandatory — no style debates
- Variables and functions: `snake_case`; types, traits, enums: `PascalCase`; constants: `SCREAMING_SNAKE_CASE`
- Module names: lowercase, single-word; file matches module name
- Keep functions under 50 lines; extract helpers liberally

## Core Design Principles

- Prefer composition over inheritance: use traits and trait bounds, not deep trait object hierarchies
- `#[derive(Debug, Clone, PartialEq)]` by default on all data structs; add `Eq`, `Hash`, `Serialize`,
  `Deserialize` when needed
- Newtype pattern for domain types: `struct UserId(Uuid);` — prevents primitive obsession and
  enables trait impl isolation
- Accept `impl Trait` in function signatures for ergonomics; return concrete types so callers can name them
- No global state or singletons — pass dependencies via constructors or function parameters

## Error Handling

- `Result<T, E>` for all fallible operations; `?` operator to propagate
- Library crates: use `thiserror` — `#[derive(Error)]` with `#[error("...")]` per variant;
  one error enum per module boundary
- Application / binary crates: use `anyhow::Result` and `anyhow::Context::context` for rich error context
- Never `.unwrap()` outside tests and `main`; when invariant justifies it, add a comment explaining
  why it cannot fail
- Never `.expect("")` with an empty message — always write a human-readable reason

## Patterns

- Builder pattern for structs with 4+ fields or optional configuration
- Typestate pattern for compile-time state machines: `struct Connection<S: State>` — prevents
  invalid transitions at zero runtime cost
- `From` / `TryFrom` for infallible / fallible conversions; implement both directions
- `Into<T>` in function parameters (`fn send(msg: impl Into<Message>)`) for call-site ergonomics
- Repository trait per aggregate root; mock with a blanket impl over `Arc<Mutex<Vec<T>>>` in tests

## Async (Tokio 1.40+)

- `#[tokio::main]` as the binary entry point; `#[tokio::test]` for async tests
- `tokio::spawn` returns `JoinHandle` — always `.await` or store it; never fire-and-forget without supervision
- `tokio::select!` for concurrent coordination and cancellation-aware branches
- Pin `tokio`, `tokio-stream`, and `futures-util` to explicit minor versions in `Cargo.toml`
- `async fn in traits` is stable as of Rust 1.85 (AFIT) — use it directly; no need for `async-trait`
  on new code
- Use `impl Future<Output = T>` return types in public trait APIs where boxing is undesirable

## Memory and Borrowing

- Prefer references over clones on hot paths; clone only at ownership boundaries
- `Cow<'a, T>` when a function sometimes borrows and sometimes needs ownership
- Lifetime elision where the compiler can infer; explicit lifetimes only when truly needed
- `Box<dyn Trait>` only when heterogeneous collections or dynamic dispatch is required
- `Arc<T>` for shared ownership across threads; `Rc<T>` only in single-threaded contexts

## Unsafe Code

- `#![forbid(unsafe_code)]` at the crate root in application code — no exceptions without a PR reason
- In library crates where unsafe is justified: every `unsafe` block must have a `// SAFETY:` comment
  above it explaining which invariants hold and why
- Wrap all unsafe in a safe public API; the unsafe surface area must be as small as possible
- Run `cargo miri test` in CI for crates that contain unsafe

## Testing

- `cargo test` with `#[test]` for unit tests; `#[cfg(test)]` module at the bottom of each source file
- `#[tokio::test]` for async tests
- Property-based testing with `proptest` or `quickcheck` for parsing, serialization, and algorithmic code
- Integration tests in `tests/` directory — one file per feature boundary
- Coverage: `cargo llvm-cov --all-features --workspace` — target 80%+
- Benchmarks: `cargo bench` via `criterion` for any hot path — check for regressions in CI

## Project Structure

```text
src/
  lib.rs or main.rs
  error.rs              # domain error enum(s) — thiserror
  domain/               # value objects, aggregates, domain events
  service/              # business logic — pure functions where possible
  repository/           # data access traits + concrete impls
  handler/ or api/      # HTTP handlers, CLI commands, gRPC services
  bin/                  # additional binary entry points
tests/                  # integration tests (access only public API)
benches/                # criterion benchmarks
Cargo.toml              # explicit version pins; [features] for opt-in deps
Cargo.lock              # committed in binaries; excluded for libraries
```

## Performance

- Profile before optimizing: `cargo flamegraph` or `perf` + `inferno`; never micro-optimize blindly
- `#[inline]` only after profiling shows the call-site overhead is measurable
- `rayon` for data parallelism on CPU-bound workloads; drop-in replace `.iter()` with `.par_iter()`
- `Vec::with_capacity(n)` when the final size is known; avoids re-allocation on grow
- Prefer `&str` over `String` in hot paths; only allocate at ownership boundaries
- `SmallVec` or `ArrayVec` for collections that are nearly always short (8 items or fewer)

## Dependency Hygiene

- Run `cargo audit` + `cargo deny check` in CI — block on critical advisories
- Pin major versions in `Cargo.toml`; review transitive graph with `cargo tree` before adding new deps
- Prefer well-maintained crates with 1,000+ reverse-dependencies on crates.io; check last release date

## April 2026 Specifics (Rust 1.85)

- `async fn in traits` (AFIT) is stable — drop `async-trait` on new code; migrate existing when convenient
- `let ... else` pattern for ergonomic early returns: `let Ok(val) = expr else { return Err(...) };`
- `impl Trait` in AFIT return positions: `fn fetch(&self) -> impl Future<Output = Result<T, E>> + Send`
- `#[diagnostic::on_unimplemented]` on custom traits for human-readable compile errors
- Edition 2024 is stable — prefer it for new crates (`edition = "2024"` in `Cargo.toml`)
