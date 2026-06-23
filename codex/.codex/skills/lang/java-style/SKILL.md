---
name: java-style
description: Java coding style guidance with a focus on using local type inference (var) when it improves clarity. Use when writing or reviewing Java code style decisions.
---

# Java Style

## Goal
Prefer local type inference with `var` when the initializer makes the type obvious, while keeping public APIs explicit.

## Rules
- Use `var` for local variables when the initializer clearly indicates the type.
- Do not use `var` for fields, parameters, or return types.
- Do not use `var` for lambda parameters unless annotations require it.
- Avoid `var` when the initializer is `null`, a numeric literal without context, or a complex generic where the type would be unclear.
- Favor explicit types at API boundaries (public/protected methods, interfaces, records).

## Examples
- Prefer: `var user = new UserRepository();`
- Prefer: `var items = List.of("a", "b");`
- Avoid: `var value = null;`
- Avoid: `var count = 1;` (unless the type is obvious from context)
- Exception: `(@Nonnull var value) -> value.toString();`
