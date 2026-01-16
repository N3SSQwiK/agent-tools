#!/usr/bin/env python3
"""
Nexus-AI Installer - Python + Textual Version
Fraternal colors: Red, White, Navy Blue, Gold
"""

import asyncio
import os
import json
from pathlib import Path
from dataclasses import dataclass

from textual import on, work
from textual.app import App, ComposeResult
from textual.binding import Binding
from textual.containers import Container, Vertical, Center, Middle
from textual.screen import Screen
from textual.widgets import Static, Footer, Label, Button
from textual.widget import Widget
from rich.text import Text
from rich.style import Style

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# FRATERNAL COLORS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

RED = "#C41E3A"
WHITE = "#FFFFFF"
NAVY = "#1E3A8A"
GOLD = "#E8C547"

BG_MAIN = "#0f172a"
BG_PANEL = "#1e293b"
TEXT_PRIMARY = "#f1f5f9"
TEXT_MUTED = "#64748b"
SUCCESS = "#34d399"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# NEXUS BANNER
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NEXUS_BANNER = [
    "███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗",
    "████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝",
    "██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗",
    "██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║",
    "██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║",
    "╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝",
]

BANNER_COLORS = [NAVY, RED, WHITE, GOLD, RED, NAVY]


def render_banner() -> Text:
    """Render the NEXUS banner with nested solid color borders."""
    text = Text()

    # Banner dimensions
    banner_width = len(NEXUS_BANNER[0])  # 44 chars

    # Border characters
    h = "─"
    v = "│"
    tl = "╭"
    tr = "╮"
    bl = "╰"
    br = "╯"

    # Sparkles
    text.append("✦   ✦   ✦\n\n", style=Style(color=GOLD, bold=True))

    # Widths for each border (outer to inner)
    w_navy = banner_width + 14
    w_red = banner_width + 10
    w_gold = banner_width + 6
    w_white = banner_width + 2

    # Navy top
    text.append(f"{tl}{h * w_navy}{tr}\n", style=Style(color=NAVY))

    # Red top
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{tl}{h * w_red}{tr}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # Gold top
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{v}  ", style=Style(color=RED))
    text.append(f"{tl}{h * w_gold}{tr}", style=Style(color=GOLD))
    text.append(f"  {v}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # White top
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{v}  ", style=Style(color=RED))
    text.append(f"{v}  ", style=Style(color=GOLD))
    text.append(f"{tl}{h * w_white}{tr}", style=Style(color=WHITE))
    text.append(f"  {v}", style=Style(color=GOLD))
    text.append(f"  {v}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # Banner content
    for i, line in enumerate(NEXUS_BANNER):
        color = BANNER_COLORS[i % len(BANNER_COLORS)]
        text.append(f"{v}  ", style=Style(color=NAVY))
        text.append(f"{v}  ", style=Style(color=RED))
        text.append(f"{v}  ", style=Style(color=GOLD))
        text.append(f"{v} ", style=Style(color=WHITE))
        text.append(line, style=Style(color=color, bold=True))
        text.append(f" {v}", style=Style(color=WHITE))
        text.append(f"  {v}", style=Style(color=GOLD))
        text.append(f"  {v}", style=Style(color=RED))
        text.append(f"  {v}\n", style=Style(color=NAVY))

    # White bottom
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{v}  ", style=Style(color=RED))
    text.append(f"{v}  ", style=Style(color=GOLD))
    text.append(f"{bl}{h * w_white}{br}", style=Style(color=WHITE))
    text.append(f"  {v}", style=Style(color=GOLD))
    text.append(f"  {v}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # Gold bottom
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{v}  ", style=Style(color=RED))
    text.append(f"{bl}{h * w_gold}{br}", style=Style(color=GOLD))
    text.append(f"  {v}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # Red bottom
    text.append(f"{v}  ", style=Style(color=NAVY))
    text.append(f"{bl}{h * w_red}{br}", style=Style(color=RED))
    text.append(f"  {v}\n", style=Style(color=NAVY))

    # Navy bottom
    text.append(f"{bl}{h * w_navy}{br}\n", style=Style(color=NAVY))

    return text


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# DATA
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

@dataclass
class Tool:
    id: str
    name: str
    description: str
    selected: bool = True


@dataclass
class Feature:
    id: str
    name: str
    description: str
    selected: bool = True


TOOLS = [
    Tool("claude", "Claude Code", "Anthropic's AI coding assistant", True),
    Tool("gemini", "Gemini CLI", "Google's AI command-line interface", True),
    Tool("codex", "Codex CLI", "OpenAI's coding assistant", False),
]

FEATURES = [
    Feature("continuity", "continuity", "Session continuity tracking across projects", True),
    Feature("maestro", "maestro", "Multi-agent orchestration with hub-spoke model", False),
]


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# CUSTOM WIDGETS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class Banner(Static):
    """Static NEXUS banner."""

    def on_mount(self) -> None:
        self.update(render_banner())


class SelectableItem(Static):
    """A selectable item with checkbox."""

    def __init__(self, name: str, description: str, selected: bool = False, highlighted: bool = False) -> None:
        super().__init__()
        self.item_name = name
        self.description = description
        self.selected = selected
        self.highlighted = highlighted

    def on_mount(self) -> None:
        self.render_item()

    def render_item(self) -> None:
        text = Text()

        # Cursor
        if self.highlighted:
            text.append("› ", style=Style(color=GOLD, bold=True))
        else:
            text.append("  ")

        # Checkbox
        if self.selected:
            text.append("◉ ", style=Style(color=GOLD, bold=True))
        else:
            text.append("○ ", style=Style(color=TEXT_MUTED))

        # Name
        if self.highlighted:
            text.append(self.item_name, style=Style(color=GOLD, bold=True))
        else:
            text.append(self.item_name, style=Style(color=TEXT_PRIMARY))

        text.append(f"\n      {self.description}", style=Style(color=TEXT_MUTED))

        self.update(text)

    def set_highlighted(self, highlighted: bool) -> None:
        self.highlighted = highlighted
        self.render_item()

    def toggle_selected(self) -> None:
        self.selected = not self.selected
        self.render_item()


class ProgressItem(Static):
    """A progress item with status."""

    def __init__(self, label: str, status: str = "pending") -> None:
        super().__init__()
        self.label_text = label
        self.status = status

    def on_mount(self) -> None:
        self.render_item()

    def render_item(self) -> None:
        text = Text()

        if self.status == "done":
            text.append("  ✓ ", style=Style(color=SUCCESS, bold=True))
            text.append(self.label_text, style=Style(color=SUCCESS))
        elif self.status == "active":
            text.append("  ● ", style=Style(color=GOLD))
            text.append(self.label_text, style=Style(color=GOLD))
        else:
            text.append("  ○ ", style=Style(color=TEXT_MUTED))
            text.append(self.label_text, style=Style(color=TEXT_MUTED))

        self.update(text)

    def set_status(self, status: str) -> None:
        self.status = status
        self.render_item()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# SCREENS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class WelcomeScreen(Screen):
    """Welcome screen."""

    BINDINGS = [
        Binding("enter", "continue_app", "Continue"),
        Binding("q", "quit", "Quit"),
    ]

    def compose(self) -> ComposeResult:
        yield Container(
            Banner(id="banner"),
            Static("AI Assistant Configuration", id="subtitle"),
            Static("Press enter to continue • q to quit", id="help"),
            id="welcome-container"
        )

    def action_continue_app(self) -> None:
        self.app.push_screen(ToolsScreen())

    def action_quit(self) -> None:
        self.app.exit()


class ToolsScreen(Screen):
    """Tool selection screen."""

    BINDINGS = [
        Binding("up", "move_up", "Up"),
        Binding("down", "move_down", "Down"),
        Binding("k", "move_up", "Up", show=False),
        Binding("j", "move_down", "Down", show=False),
        Binding("space", "toggle", "Toggle"),
        Binding("enter", "confirm", "Confirm"),
        Binding("escape", "back", "Back"),
        Binding("q", "quit", "Quit"),
    ]

    cursor = 0

    def compose(self) -> ComposeResult:
        yield Container(
            Banner(id="banner"),
            Container(
                Static("Select Tools", id="panel-title"),
                Static("Choose which AI assistants to configure", id="panel-subtitle"),
                *[SelectableItem(t.name, t.description, t.selected, i == 0) for i, t in enumerate(TOOLS)],
                Static("↑/↓ navigate • space toggle • enter confirm • esc back", id="panel-help"),
                id="panel"
            ),
            id="main-container"
        )

    def on_mount(self) -> None:
        self.cursor = 0
        self._update_highlights()

    def _update_highlights(self) -> None:
        items = list(self.query(SelectableItem))
        for i, item in enumerate(items):
            item.set_highlighted(i == self.cursor)

    def action_move_up(self) -> None:
        if self.cursor > 0:
            self.cursor -= 1
            self._update_highlights()

    def action_move_down(self) -> None:
        if self.cursor < len(TOOLS) - 1:
            self.cursor += 1
            self._update_highlights()

    def action_toggle(self) -> None:
        items = list(self.query(SelectableItem))
        items[self.cursor].toggle_selected()
        TOOLS[self.cursor].selected = items[self.cursor].selected

    def action_confirm(self) -> None:
        self.app.push_screen(FeaturesScreen())

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_quit(self) -> None:
        self.app.exit()


class FeaturesScreen(Screen):
    """Feature selection screen."""

    BINDINGS = [
        Binding("up", "move_up", "Up"),
        Binding("down", "move_down", "Down"),
        Binding("k", "move_up", "Up", show=False),
        Binding("j", "move_down", "Down", show=False),
        Binding("space", "toggle", "Toggle"),
        Binding("enter", "install", "Install"),
        Binding("escape", "back", "Back"),
        Binding("q", "quit", "Quit"),
    ]

    cursor = 0

    def compose(self) -> ComposeResult:
        yield Container(
            Banner(id="banner"),
            Container(
                Static("Select Features", id="panel-title"),
                Static("Choose features to install", id="panel-subtitle"),
                *[SelectableItem(f.name, f.description, f.selected, i == 0) for i, f in enumerate(FEATURES)],
                Static("↑/↓ navigate • space toggle • enter install • esc back", id="panel-help"),
                id="panel"
            ),
            id="main-container"
        )

    def on_mount(self) -> None:
        self.cursor = 0
        self._update_highlights()

    def _update_highlights(self) -> None:
        items = list(self.query(SelectableItem))
        for i, item in enumerate(items):
            item.set_highlighted(i == self.cursor)

    def action_move_up(self) -> None:
        if self.cursor > 0:
            self.cursor -= 1
            self._update_highlights()

    def action_move_down(self) -> None:
        if self.cursor < len(FEATURES) - 1:
            self.cursor += 1
            self._update_highlights()

    def action_toggle(self) -> None:
        items = list(self.query(SelectableItem))
        items[self.cursor].toggle_selected()
        FEATURES[self.cursor].selected = items[self.cursor].selected

    def action_install(self) -> None:
        self.app.push_screen(InstallingScreen())

    def action_back(self) -> None:
        self.app.pop_screen()

    def action_quit(self) -> None:
        self.app.exit()


class InstallingScreen(Screen):
    """Installation progress screen."""

    def __init__(self) -> None:
        super().__init__()
        self.steps = []

    def compose(self) -> ComposeResult:
        # Build steps
        self.steps = []
        for feature in FEATURES:
            if not feature.selected:
                continue
            for tool in TOOLS:
                if not tool.selected:
                    continue
                self.steps.append((f"Installing {feature.name} for {tool.name}", tool.id, feature.id))

        yield Container(
            Banner(id="banner"),
            Container(
                Static("Installing", id="panel-title"),
                *[ProgressItem(step[0], "pending") for step in self.steps],
                id="panel"
            ),
            id="main-container"
        )

    def on_mount(self) -> None:
        self.run_installation()

    @work(exclusive=True)
    async def run_installation(self) -> None:
        items = list(self.query(ProgressItem))

        for i, (step_name, tool_id, feature_id) in enumerate(self.steps):
            items[i].set_status("active")
            await self.install_step(tool_id, feature_id)
            await asyncio.sleep(0.3)
            items[i].set_status("done")

        await asyncio.sleep(0.5)
        self.app.push_screen(DoneScreen())

    async def install_step(self, tool_id: str, feature_id: str) -> None:
        home = Path.home()
        repo = self.app.repo_path

        if tool_id == "claude":
            await self.install_claude(home, repo, feature_id)
        elif tool_id == "gemini":
            await self.install_gemini(home, repo, feature_id)
        elif tool_id == "codex":
            await self.install_codex(home, repo, feature_id)

    async def install_claude(self, home: Path, repo: Path, feature: str) -> None:
        claude_dir = home / ".claude"
        commands_dir = claude_dir / "commands"
        commands_dir.mkdir(parents=True, exist_ok=True)

        src_config = repo / "features" / feature / "claude" / "CLAUDE.md"
        dst_config = claude_dir / "CLAUDE.md"
        install_managed_config(src_config, dst_config)

        # Install all command files from the feature's commands directory
        src_commands_dir = repo / "features" / feature / "claude" / "commands"
        if src_commands_dir.exists():
            for src_cmd in src_commands_dir.glob("*.md"):
                dst_cmd = commands_dir / src_cmd.name
                if dst_cmd.exists():
                    dst_cmd.unlink()
                dst_cmd.symlink_to(src_cmd)

    async def install_gemini(self, home: Path, repo: Path, feature: str) -> None:
        gemini_dir = home / ".gemini"
        ext_dir = gemini_dir / "extensions" / feature
        cmd_dir = ext_dir / "commands"
        cmd_dir.mkdir(parents=True, exist_ok=True)

        src_config = repo / "features" / feature / "gemini" / "GEMINI.md"
        dst_config = gemini_dir / "GEMINI.md"
        install_managed_config(src_config, dst_config)

        src_ext = repo / "features" / feature / "gemini" / "extensions" / feature
        (ext_dir / "gemini-extension.json").write_text((src_ext / "gemini-extension.json").read_text())

        # Install all command files from the feature's commands directory
        src_commands_dir = src_ext / "commands"
        if src_commands_dir.exists():
            for src_cmd in src_commands_dir.glob("*.toml"):
                (cmd_dir / src_cmd.name).write_text(src_cmd.read_text())

        enablement_path = gemini_dir / "extensions" / "extension-enablement.json"
        update_enablement(enablement_path, feature)

    async def install_codex(self, home: Path, repo: Path, feature: str) -> None:
        codex_dir = home / ".codex"
        prompts_dir = codex_dir / "prompts"
        prompts_dir.mkdir(parents=True, exist_ok=True)

        src_config = repo / "features" / feature / "codex" / "AGENTS.md"
        dst_config = codex_dir / "AGENTS.md"
        install_managed_config(src_config, dst_config)

        # Install all prompt files from the feature's prompts directory
        src_prompts_dir = repo / "features" / feature / "codex" / "prompts"
        if src_prompts_dir.exists():
            for src_prompt in src_prompts_dir.glob("*.md"):
                dst_prompt = prompts_dir / src_prompt.name
                if dst_prompt.exists():
                    dst_prompt.unlink()
                dst_prompt.symlink_to(src_prompt)


class DoneScreen(Screen):
    """Completion screen."""

    BINDINGS = [
        Binding("enter", "quit", "Exit"),
        Binding("q", "quit", "Exit"),
    ]

    def compose(self) -> ComposeResult:
        tools = [t.name for t in TOOLS if t.selected]
        features = [f.name for f in FEATURES if f.selected]

        yield Container(
            Banner(id="banner"),
            Container(
                Static(Text("✓ Installation Complete", style=Style(color=SUCCESS, bold=True)), id="panel-title"),
                Static(Text.assemble(
                    ("Tools: ", Style(color=TEXT_MUTED)),
                    (", ".join(tools), Style(color=GOLD))
                ), id="summary-tools"),
                Static(Text.assemble(
                    ("Features: ", Style(color=TEXT_MUTED)),
                    (", ".join(features), Style(color=GOLD))
                ), id="summary-features"),
                Static("Press enter or q to exit", id="panel-help"),
                id="panel"
            ),
            id="main-container"
        )

    def action_quit(self) -> None:
        self.app.exit()


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# HELPERS
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

START_MARKER = "<!-- AGENT-TOOLS:START -->"
END_MARKER = "<!-- AGENT-TOOLS:END -->"


def install_managed_config(src_path: Path, dst_path: Path) -> None:
    if not src_path.exists():
        return

    src_content = src_path.read_text()
    managed_block = f"{START_MARKER}\n{src_content}\n{END_MARKER}"

    if not dst_path.exists():
        dst_path.write_text(managed_block)
        return

    existing = dst_path.read_text()

    if START_MARKER in existing:
        start = existing.index(START_MARKER)
        end = existing.index(END_MARKER) + len(END_MARKER)
        content = existing[:start] + managed_block + existing[end:]
    else:
        content = existing + "\n" + managed_block

    dst_path.write_text(content)


def update_enablement(path: Path, extension_name: str) -> None:
    if path.exists():
        try:
            data = json.loads(path.read_text())
        except json.JSONDecodeError:
            data = {}
    else:
        path.parent.mkdir(parents=True, exist_ok=True)
        data = {}

    data[extension_name] = True
    path.write_text(json.dumps(data, indent=2))


# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# APP
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class NexusInstaller(App):
    """NEXUS Installer Application."""

    CSS = """
    Screen {
        background: #0f172a;
    }

    #welcome-container {
        width: 100%;
        height: 100%;
        align: center middle;
        background: #0f172a;
    }

    #main-container {
        width: 100%;
        height: 100%;
        align: center top;
        background: #0f172a;
        padding-top: 1;
    }

    #banner {
        width: 100%;
        height: auto;
        content-align: center middle;
        text-align: center;
        background: #0f172a;
        padding: 1;
    }

    #subtitle {
        width: 100%;
        height: auto;
        content-align: center middle;
        text-align: center;
        color: #94a3b8;
        text-style: italic;
        background: #0f172a;
    }

    #help {
        width: 100%;
        height: auto;
        content-align: center middle;
        text-align: center;
        color: #64748b;
        background: #0f172a;
        margin-top: 1;
    }

    #panel {
        width: 70;
        height: auto;
        background: #1e293b;
        border: round #334155;
        padding: 1 2;
        margin: 1;
    }

    #panel-title {
        color: #f1f5f9;
        text-style: bold;
        background: #1e293b;
        width: 100%;
    }

    #panel-subtitle {
        color: #94a3b8;
        text-style: italic;
        background: #1e293b;
        width: 100%;
        margin-bottom: 1;
    }

    #panel-help {
        color: #64748b;
        background: #1e293b;
        width: 100%;
        margin-top: 1;
    }

    #summary-tools, #summary-features {
        background: #1e293b;
        width: 100%;
        padding: 0 0 1 0;
    }

    SelectableItem {
        width: 100%;
        height: auto;
        background: #1e293b;
        padding: 1 0;
    }

    ProgressItem {
        width: 100%;
        height: auto;
        background: #1e293b;
        padding: 0 0 1 0;
    }
    """

    BINDINGS = [
        Binding("ctrl+c", "quit", "Quit"),
    ]

    def __init__(self) -> None:
        super().__init__()
        self.repo_path = Path.cwd()
        if not (self.repo_path / "features").exists():
            for parent in self.repo_path.parents:
                if (parent / "features").exists():
                    self.repo_path = parent
                    break

    def on_mount(self) -> None:
        self.push_screen(WelcomeScreen())


if __name__ == "__main__":
    app = NexusInstaller()
    app.run()
