# Bug Report Template

Copy this block into the developer Discord first:

```text
Title:

Symptom:

Expected behavior:

Actual behavior:

Related module:
- core / input / judge / util / AI / packaging / unknown

Godot version:

OS and architecture:

Build source:
- source-built / prebuilt / unknown

PDJE_VERSION:

PDJE_WRAPPER_VERSION:

Godot API call sequence:
1.
2.
3.

Minimal reproduction steps:
1.
2.
3.

Minimal reproduction project or scene:
- attached / can provide privately / not available yet

Logs:

.gdextension path and relevant content:

Wrapper library path:

Runtime library path:

Root DB path:
- res:// / user:// / absolute path / unknown

Audio asset information:
- path:
- import status:
- can share publicly? yes / no

Model information, if AI is involved:
- .onnx path:
- can share publicly? yes / no

Input device information, if input or judge is involved:
- keyboard/mouse devices:
- MIDI ports:
- permissions checked:

Other notes:
```

For reproducible bugs, also prepare a GitHub issue after the Discord report.
Include the minimal reproduction, Godot version, OS, logs, wrapper/core
versions, and the exact call sequence.

Do not post private music, database, or model files publicly unless you have
the right to share them. Use a minimal substitute whenever possible. A human
developer must directly review and send the final Discord or GitHub message.
Developers welcome bug reports, and agent-generated report drafts are fine when
they make reporting easier. Automated reporting or unreviewed message sending
is discouraged because the report may expose personal information, local paths,
private assets, database content, logs, or model files.
