---
name: typescript-style
description: TypeScript coding style guidance focused on preferring const over let, minimizing mutation, and using functional programming patterns when they improve clarity. Use when writing or reviewing TypeScript, TSX, Node.js TypeScript, React TypeScript, or frontend/backend TypeScript code style decisions.
---

# TypeScript Style

## Goal
Prefer immutable bindings and clear data transformations. Use functional patterns where they reduce state, side effects, or control-flow complexity.

## Rules
- Use `const` by default for variables, functions, imports, destructuring, and intermediate values.
- Use `let` only when the binding is reassigned. Do not use `let` for mutated object contents if the binding itself is stable.
- Avoid `var`.
- Prefer pure functions for business logic and transformations.
- Prefer array combinators (`map`, `filter`, `flatMap`, `reduce`, `some`, `every`, `find`) when they make intent clearer than manual loops.
- Use `for...of` when early return, `break`, `continue`, async sequencing, or performance-sensitive logic makes a loop clearer.
- Avoid mutating inputs. Return new arrays/objects instead, unless mutation is required by an API or is clearly more efficient in a hot path.
- Keep side effects at boundaries: I/O, network calls, DOM updates, logging, metrics, and framework lifecycle hooks.
- Prefer precise types at API boundaries and let local variable types infer from clear initializers.
- Do not force point-free or heavily nested functional style when named steps would be easier to read.

## Examples
- Prefer: `const total = items.reduce((sum, item) => sum + item.price, 0);`
- Prefer: `const activeUsers = users.filter((user) => user.active);`
- Prefer: `const nextState = { ...state, count: state.count + 1 };`
- Use `let`: `let remaining = retries; while (remaining > 0) remaining -= 1;`
- Avoid: `let user = getUser();` when `user` is never reassigned.
- Avoid: `items.forEach((item) => results.push(transform(item)));`
- Prefer: `const results = items.map(transform);`

## Review Checklist
- Convert non-reassigned `let` bindings to `const`.
- Replace accumulator mutation with `map`, `filter`, or `reduce` when the result is a transformed collection.
- Preserve loops when they are clearer than a functional rewrite.
- Check that functional rewrites do not add unnecessary allocations, nested callbacks, or obscure names.
- Keep public TypeScript APIs explicit while allowing local inference.
