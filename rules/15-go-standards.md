# Go Production Standards

## Style
- `gofmt` and `goimports` are mandatory — no style debates
- Short variable names for small scopes; descriptive for larger scopes
- Exported names: PascalCase; unexported: camelCase
- Package names: lowercase, single-word, no underscores

## Core Design Principles
- Accept interfaces, return structs
- Keep interfaces small: 1-3 methods, defined at point of use (not implementation)
- No globals or singletons — pass dependencies via constructor functions
- Prefer composition over inheritance (embed structs)

## Error Handling
- ALWAYS check returned errors: `if err != nil { return fmt.Errorf("context: %w", err) }`
- Wrap errors with context using `fmt.Errorf("failed to X: %w", err)`
- Define sentinel errors: `var ErrNotFound = errors.New("not found")`
- Use `errors.Is()` and `errors.As()` for error checking
- Never `panic` in library code — only in unrecoverable startup failures

## Patterns
- Functional Options: `type Option func(*Server)` for flexible constructors
- Table-driven tests: mandatory pattern for Go tests
- Repository pattern with interface at consumer side
- Dependency injection via struct fields set in constructors

## Concurrency
- Goroutines are cheap — use them; but always manage their lifecycle
- Use `context.Context` for cancellation and timeouts
- Channels for communication; mutexes for protecting shared state
- `sync.WaitGroup` for goroutine coordination
- `errgroup.Group` for concurrent operations that can fail

## Testing
- Standard `go test` with table-driven tests
- ALWAYS run with `-race` flag: `go test -race ./...`
- Coverage: `go test -cover ./...`
- Subtests: `t.Run("case name", func(t *testing.T) { ... })`
- Test helpers: accept `t *testing.T` as first parameter, call `t.Helper()`
- Use `testify/assert` or `testify/require` for assertions
- Coverage target: 80%+

## Project Structure
```
cmd/           # Entry points
internal/      # Private packages
  handler/     # HTTP handlers
  service/     # Business logic
  repository/  # Data access
  model/       # Domain types
pkg/           # Public packages (if any)
go.mod
go.sum
```

## Performance
- Use `sync.Pool` for frequently allocated objects
- Preallocate slices: `make([]T, 0, expectedCap)`
- Profile before optimizing: `go tool pprof`
- Benchmark critical paths: `func BenchmarkX(b *testing.B) { ... }`
