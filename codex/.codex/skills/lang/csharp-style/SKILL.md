---
name: csharp-style
description: C# coding style guidance with a focus on using local type inference (var) when it improves clarity. Use when writing or reviewing C# code style decisions.
---

# C# Style

## Goal
Prefer local type inference with `var` when the initializer makes the type obvious, while keeping public APIs explicit.

## Rules
- Use `var` for local variables when the initializer clearly indicates the type.
- Do not use `var` for fields, properties, parameters, or return types.
- Avoid `var` when the initializer is `null`, `default`, a numeric literal without context, or a complex generic where the type would be unclear.
- Prefer explicit types at API boundaries (public/protected methods, interfaces, records, delegates).
- Prefer explicit types when they communicate domain intent better than the initializer.
- Avoid `dynamic` unless interop, reflection, serialization, or framework constraints require it.
- Keep nullable intent explicit with C# nullable reference types where the project uses them.

## Examples
- Prefer: `var user = new UserRepository();`
- Prefer: `var items = new List<string>();`
- Prefer: `var activeUsers = users.Where(user => user.IsActive).ToList();`
- Avoid: `var value = null;`
- Avoid: `var count = 1;` (unless the type is obvious from context)
- Consider explicit: `UserId id = user.Id;` when the domain type matters.

## Review Checklist
- Convert obvious local declarations to `var`.
- Keep public and protected API signatures explicit.
- Avoid `var` where the initializer hides important type information.
- Avoid introducing `dynamic` unless the reason is concrete.
- Preserve existing project conventions when they are more specific.
