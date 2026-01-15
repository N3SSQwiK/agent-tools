# Python Installer (Textual)

A beautiful TUI installer built with Python and Textual, featuring CSS-like styling.

## Requirements

- Python 3.10+
- pip

## Install Dependencies

```bash
cd installer/python
pip install -r requirements.txt
```

## Run

```bash
python installer.py
```

Or from the repo root:

```bash
python installer/python/installer.py
```

## Features

- Animated NEXUS banner with gradient colors
- Interactive tool and feature selection
- CSS-based styling (nexus.tcss)
- Adaptive light/dark mode
- Managed block config merging
- Async installation with progress tracking

## Customization

Edit `nexus.tcss` to customize the appearance. Textual uses CSS-like syntax:

```css
.glass-panel {
    background: $panel;
    border: round $primary-lighten-2;
    padding: 1 2;
}
```

## Design System

Colors are defined in `installer.py`:

- **Gradient palette**: cyan → teal → blue → indigo → violet → rose
- **Wave colors**: cyan → teal → blue → violet → rose → peach
- **Accent**: amber (sparkles)
- **Success**: emerald green
