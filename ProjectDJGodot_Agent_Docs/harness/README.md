# Harness Rules

This harness helps Godot game-development agents use PDJE safely. It does not
replace the source tree. Always check the current checkout before making claims
about API availability, packaging, platform support, or release state.

## Agent Workflow

1. Identify the module: core, input, judge, util, or packaging/debugging.
2. Read the matching page in this directory.
3. Probe the matching `Project-DJ-Engine-Docs/*.html` module page, not just
   the public `Project-DJ-Engine/` landing page.
4. Before saying an API cannot be found, search the page for `GDSCRIPT`,
   `Godot`, `Wrapper`, the class name, and the method name.
5. Use Godot class and method names as documented in the official wrapper references.
6. Verify deeper engine behavior in the official documentation or upstream `AGENT_DOCS`.
7. Use Godot-native values at boundaries: `String`, `Array`, `Dictionary`,
   `Packed*Array`, `RefCounted`, and `Node`.
8. Report wrapper failures by checking return values and Godot console errors.

When the official native C++ signature and a Godot wrapper snippet disagree,
record both facts separately: keep the native documented return for engine
semantics, and use the current Godot call shape from the wrapper snippet or
checkout examples for generated GDScript.

When writing new GDScript from this harness, prefer enum namespaces and call
shapes used by the current checkout's runnable examples, especially
`addons/Project_DJ_Godot/examples/GAME_TEMPLATE.tscn` and
`AutoBench/Bench-Core.tscn`. If flat constants and nested enum aliases both
appear to exist, harness examples use the nested enum form to avoid ambiguity.

## Official Documentation Map

Use the maintained `Project-DJ-Engine-Docs` pages as the first source for API
meaning, arguments, return values, and failure behavior:

| Harness area | Official page |
| --- | --- |
| Core facade, playback, player panels | https://rliop913.github.io/Project-DJ-Engine-Docs/Core_Engine.html |
| Editor workflow and render/push behavior | https://rliop913.github.io/Project-DJ-Engine-Docs/Editor_Workflows.html |
| Input lifecycle and device data lines | https://rliop913.github.io/Project-DJ-Engine-Docs/Input_Engine.html |
| Judge startup contract and callbacks | https://rliop913.github.io/Project-DJ-Engine-Docs/Judge_Engine.html |
| Utility DB, MIR, waveform, AI wrappers | https://rliop913.github.io/Project-DJ-Engine-Docs/Util_Engine.html |
| Case-sensitive runtime FX argument keys | https://rliop913.github.io/Project-DJ-Engine-Docs/FX_ARGS.html |

If an official Godot wrapper snippet conflicts with the current checkout's
runnable examples, use the current checkout wrapper signature and mark the
official page as conceptual background rather than the exact call shape.

## Documentation Probing Checklist

Use this table before concluding that the official docs do not describe an API.
Search for the listed anchors or keywords inside the matching official page.

| Module | First probes in official docs |
| --- | --- |
| Core | `Wrapper Bindings`, `GDSCRIPT`, `Selected facade methods`, `Player Control`, `Editor Entry Points` |
| Editor | `Project Setup`, `Mutation Workflow`, `Persistence Workflow`, `Preview And Validation` |
| Input | `Selected methods`, `Current Lifecycle`, `Godot Wrapper Example` |
| Judge | `Startup Contract`, `Initialization API`, `Godot Wrapper Flow` |
| Util | `Godot DB wrapper examples`, `Godot MIR wrapper examples`, `Godot Wrapper Surface` |
| FX | `FX_ARGS`, each FX heading's exact key list, `Usage Example` |

## Documentation References

For detailed documentation, refer to:
- **Official Documentation**: https://rliop913.github.io/Project-DJ-Engine/
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
Do not say the official docs lack an API until you have checked the module
page, searched the page keywords above, and compared the current checkout's
runnable examples.

If a return value is not documented, do not infer a type from naming alone.
Write `Not documented; observed usage: ...` and include the example or source
that shows the observed GDScript call shape.

## Failure Convention

The wrapper generally reports failures with the narrowest Godot fallback:

- `false` for boolean operations
- empty arrays, dictionaries, strings, or packed arrays for value queries
- null/default `Ref<>` values for missing result objects
- `print_error` or `print_method_error` for diagnostics

Agents must check return values. Do not assume a method succeeded because it did
not throw.
