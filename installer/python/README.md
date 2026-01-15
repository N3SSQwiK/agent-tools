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
python nexus.py
```

Or from the repo root:

```bash
python installer/python/nexus.py
```

## Features

- Animated Nexus-AI banner with gradient colors
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

Fraternal colors defined in `nexus.py`:

- **Red**: #C41E3A
- **White**: #FFFFFF
- **Navy**: #1E3A8A
- **Gold**: #E8C547 (accent, sparkles)
- **Success**: #34d399 (emerald)
