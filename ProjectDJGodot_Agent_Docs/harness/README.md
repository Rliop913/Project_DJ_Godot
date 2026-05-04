# Harness Rules

This harness helps Godot game-development agents use PDJE safely. It does not
replace the source tree. Always check the current checkout before making claims
about API availability, packaging, platform support, or release state.

## Agent Workflow

1. Identify the module: core, input, judge, util, or packaging/debugging.
2. Read the matching page in this directory.
3. Use Godot class and method names as documented in the official wrapper references.
4. Verify deeper engine behavior in the official documentation or upstream `AGENT_DOCS`.
5. Use Godot-native values at boundaries: `String`, `Array`, `Dictionary`,
   `Packed*Array`, `RefCounted`, and `Node`.
6. Report wrapper failures by checking return values and Godot console errors.

## Documentation References

For detailed documentation, refer to:
- **Official Documentation**: https://rliop913.github.io/Project-DJ-Engine-Docs/
- **Core Repository**: https://github.com/Rliop913/Project-DJ-Engine
- **Wrapper Repository**: https://github.com/Rliop913/PDJE-Godot-Plugin

## Do Not Guess

Do not invent:

- model packaging paths
- current release/prebuilt status
- unsupported platform behavior
- new FX argument keys
- new editor enum values
- direct Godot access to generic ONNX Runtime sessions

If the current source tree does not show it, state that it must be verified.

## Failure Convention

The wrapper generally reports failures with the narrowest Godot fallback:

- `false` for boolean operations
- empty arrays, dictionaries, strings, or packed arrays for value queries
- null/default `Ref<>` values for missing result objects
- `print_error` or `print_method_error` for diagnostics

Agents must check return values. Do not assume a method succeeded because it did
not throw.

