---
paths:
  - "**/*.swift"
  - "**/*.pbxproj"
  - "**/*.xcconfig"
  - "**/*.entitlements"
  - "**/Info.plist"
---

# Xcode Build & Test Tooling

**Prefer Xcode MCP tools over the `xcodebuild` CLI** for building and running
tests (`BuildProject`, `RunAllTests`, `RunSomeTests`, etc.). They integrate with
the user's workflow better. Fall back to `xcodebuild` only when the Xcode MCP
server is unavailable.
