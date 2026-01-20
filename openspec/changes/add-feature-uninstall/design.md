# Design: Feature Uninstall for TUI

## Architectural Overview

The uninstall flow mirrors the existing install flow but operates in reverse. It reuses existing patterns (Screen classes, SelectableItem widget) and inverts the installation logic.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         TUI Screen Flow                                  │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│  WelcomeScreen (modified)                                               │
│       │                                                                 │
│       ├──▶ "Install Features" ──▶ ToolsScreen ──▶ FeaturesScreen ──▶ ...│
│       │                                                                 │
│       └──▶ "Uninstall Features" ──▶ UninstallFeatureScreen             │
│                                            │                            │
│                                            ▼                            │
│                                    UninstallToolsScreen                 │
│                                            │                            │
│                                            ▼                            │
│                                    UninstallConfirmScreen               │
│                                            │                            │
│                                            ▼                            │
│                                    UninstallingScreen                   │
│                                            │                            │
│                                            ▼                            │
│                                    UninstallDoneScreen                  │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

## UX Flow Detail

### Screen 1: WelcomeScreen (Modified)

Add mode selection to existing welcome screen:

```
    ✦   ✦   ✦

╭──────────────────────────────────────────────────────╮
│  ╭────────────────────────────────────────────────╮  │
│  │  ╭──────────────────────────────────────────╮  │  │
│  │  │  ╭────────────────────────────────────╮  │  │  │
│  │  │  │ ███╗   ██╗███████╗██╗  ██╗██╗   ██╗│  │  │  │
│  │  │  │ ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║│  │  │  │
│  │  │  │ ...                                │  │  │  │
│  │  │  ╰────────────────────────────────────╯  │  │  │
│  │  ╰──────────────────────────────────────────╯  │  │
│  ╰────────────────────────────────────────────────╯  │
╰──────────────────────────────────────────────────────╯

         AI Assistant Configuration

    › ◉ Install features
      ○ Uninstall features

    ↑/↓ navigate • enter continue • q quit
```

### Screen 2: UninstallFeatureScreen

Single-select list of detected installed features:

```
╭──────────────────────────────────────────────────────╮
│  Select Feature to Uninstall                         │
│  Choose a feature to remove                          │
│                                                      │
│  › ◉ continuity                                      │
│        Detected in: Claude, Gemini, Codex            │
│                                                      │
│    ○ maestro                                         │
│        Detected in: Claude, Gemini                   │
│                                                      │
│  ↑/↓ navigate • enter select • esc back              │
╰──────────────────────────────────────────────────────╯
```

If no features are detected:

```
╭──────────────────────────────────────────────────────╮
│  No Features Installed                               │
│                                                      │
│  No Nexus-AI features were detected.                 │
│  Use "Install features" to add features.             │
│                                                      │
│  Press esc to go back                                │
╰──────────────────────────────────────────────────────╯
```

### Screen 3: UninstallToolsScreen

Multi-select for which tools to uninstall the feature from:

```
╭──────────────────────────────────────────────────────╮
│  Uninstall "continuity" from:                        │
│  Select tools to remove this feature from            │
│                                                      │
│  › ◉ Claude Code    (installed)                      │
│    ◉ Gemini CLI     (installed)                      │
│    ○ Codex CLI      (not installed)                  │
│                                                      │
│  ↑/↓ navigate • space toggle • enter continue        │
│  + Add another feature • esc back                    │
╰──────────────────────────────────────────────────────╯
```

- Only tools where the feature is detected are checkable
- Tools where feature isn't installed are shown but disabled (grayed out)

### Screen 4: UninstallConfirmScreen

Warning and final confirmation:

```
╭──────────────────────────────────────────────────────╮
│  ⚠️  Confirm Uninstall                               │
│                                                      │
│  The following will be removed:                      │
│                                                      │
│  continuity                                          │
│    • Claude Code: ~/.claude/commands/continuity.md   │
│    • Gemini CLI:  ~/.gemini/extensions/continuity/   │
│                                                      │
│  maestro                                             │
│    • Gemini CLI:  ~/.gemini/extensions/maestro/      │
│                                                      │
│  ⚠️  Make sure Claude Code, Gemini CLI, and Codex    │
│  CLI are not running during uninstall.               │
│                                                      │
│  enter confirm • esc cancel                          │
╰──────────────────────────────────────────────────────╯
```

### Screen 5: UninstallingScreen

Progress feedback (reuses ProgressItem widget):

```
╭──────────────────────────────────────────────────────╮
│  Uninstalling                                        │
│                                                      │
│  ✓ Removed continuity from Claude Code               │
│  ✓ Removed continuity from Gemini CLI                │
│  ● Removing maestro from Gemini CLI...               │
│  ○ Rebuilding config files                           │
│                                                      │
╰──────────────────────────────────────────────────────╯
```

### Screen 6: UninstallDoneScreen

Summary of what was removed:

```
╭──────────────────────────────────────────────────────╮
│  ✓ Uninstall Complete                                │
│                                                      │
│  Removed:                                            │
│    • continuity from Claude Code, Gemini CLI         │
│    • maestro from Gemini CLI                         │
│                                                      │
│  Press enter or q to exit                            │
╰──────────────────────────────────────────────────────╯
```

## Detection Logic

### Function: `detect_installed_features()`

```python
def detect_installed_features() -> dict[str, dict[str, bool]]:
    """
    Returns dict of feature_id -> {tool_id -> is_installed}
    Example: {"continuity": {"claude": True, "gemini": True, "codex": False}}
    """
    home = Path.home()
    result = {}

    for feature in FEATURES:
        feature_status = {}

        # Claude: check for command files
        claude_pattern = home / ".claude" / "commands" / f"{feature.id}*.md"
        feature_status["claude"] = any(claude_pattern.parent.glob(f"{feature.id}*.md"))

        # Gemini: check for extension directory
        gemini_ext = home / ".gemini" / "extensions" / feature.id
        feature_status["gemini"] = gemini_ext.is_dir()

        # Codex: check for prompt files
        codex_pattern = home / ".codex" / "prompts" / f"{feature.id}*.md"
        feature_status["codex"] = any(codex_pattern.parent.glob(f"{feature.id}*.md"))

        # Only include if installed somewhere
        if any(feature_status.values()):
            result[feature.id] = feature_status

    return result
```

## Uninstall Actions

### Claude Code

```python
async def uninstall_claude(feature_id: str) -> None:
    commands_dir = Path.home() / ".claude" / "commands"

    # Delete all command files for this feature
    for cmd_file in commands_dir.glob(f"{feature_id}*.md"):
        cmd_file.unlink()
```

### Gemini CLI

```python
async def uninstall_gemini(feature_id: str) -> None:
    gemini_dir = Path.home() / ".gemini"
    ext_dir = gemini_dir / "extensions" / feature_id

    # Delete extension directory
    if ext_dir.is_dir():
        shutil.rmtree(ext_dir)

    # Update enablement
    enablement_path = gemini_dir / "extensions" / "extension-enablement.json"
    if enablement_path.exists():
        data = json.loads(enablement_path.read_text())
        data.pop(feature_id, None)
        enablement_path.write_text(json.dumps(data, indent=2))
```

### Codex CLI

```python
async def uninstall_codex(feature_id: str) -> None:
    prompts_dir = Path.home() / ".codex" / "prompts"

    # Delete all prompt files for this feature
    for prompt_file in prompts_dir.glob(f"{feature_id}*.md"):
        prompt_file.unlink()
```

### Managed Block Rebuild

After uninstalling files, rebuild managed blocks to exclude removed features:

```python
def rebuild_managed_configs(remaining_features: list[str]) -> None:
    """Rebuild managed blocks with only the remaining installed features."""
    features_path = get_features_path()
    home = Path.home()

    # Claude
    src_paths = [features_path / f / "claude" / "CLAUDE.md" for f in remaining_features]
    write_managed_config(home / ".claude" / "CLAUDE.md", src_paths)

    # Gemini
    src_paths = [features_path / f / "gemini" / "GEMINI.md" for f in remaining_features]
    write_managed_config(home / ".gemini" / "GEMINI.md", src_paths)

    # Codex
    src_paths = [features_path / f / "codex" / "AGENTS.md" for f in remaining_features]
    write_managed_config(home / ".codex" / "AGENTS.md", src_paths)
```

**Note**: The existing `write_managed_config()` function already handles empty content gracefully—if no features remain, it either removes the managed block or leaves an empty one.

## State Management

### Uninstall Queue

To support "Add Another Feature", maintain a queue of pending uninstalls:

```python
@dataclass
class UninstallItem:
    feature_id: str
    tools: list[str]  # ["claude", "gemini", "codex"]

# App-level state
uninstall_queue: list[UninstallItem] = []
```

The queue is populated in `UninstallToolsScreen` and processed in `UninstallingScreen`.

## Edge Case Handling

### Missing Files

```python
# In uninstall_claude()
for cmd_file in commands_dir.glob(f"{feature_id}*.md"):
    try:
        cmd_file.unlink()
    except FileNotFoundError:
        pass  # Already gone, skip silently
```

### Config Directory Missing

```python
# Before attempting uninstall
claude_dir = Path.home() / ".claude"
if not claude_dir.exists():
    # Tool not installed, nothing to uninstall
    return
```

### Managed Block Parsing Failure

```python
# In write_managed_config() (already handles this)
if START_MARKER in existing and END_MARKER in existing:
    # Parse and replace
else:
    # No block found, nothing to remove from config
```

## Trade-offs

| Decision | Alternative | Rationale |
|----------|-------------|-----------|
| Two-step feature→tool flow | Matrix view | Scales to any number of features |
| Filesystem detection | State file | Simpler; no drift between state and reality |
| Single-select feature | Multi-select | Clearer UX; queue handles multiple |
| Warn about running CLIs | Detect running processes | Detection is platform-specific and complex |
| Reuse ProgressItem widget | New widget | Consistency with install flow |
