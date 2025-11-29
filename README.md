# Maximum Mathematics

A comprehensive Asymptote library for creating professional mathematical diagrams and visualizations.

## Overview

Maximum Mathematics provides a **declarative, unified architecture** for creating high-quality mathematical figures. The library features automatic rendering, zone management, gallery support, and sensible defaults at every level.

### Key Features

✨ **Declarative API** - Describe what you want, not how to render it  
🎨 **Automatic Rendering** - No explicit output calls needed  
📐 **Zone Management** - Automatic layouts with captions and margins  
📏 **CSS-like Margins** - Flexible margin control with familiar specificity rules  
🖼️ **Gallery Support** - Arrange multiple diagrams in grids  
🎯 **Sensible Defaults** - Minimal configuration required  
♻️ **Backward Compatible** - All legacy code still works  

---

## Quick Start

### Installation

1. Copy `MaximumMathematics.asy` to your Asymptote library path or project directory
2. Import in your `.asy` files:

```asy
import MaximumMathematics;
```

### Simplest Example

```asy
import MaximumMathematics;

string[] A = {"H", "T"};
string[] B = {"B", "R"};

TreeDiagram tree = TreeDiagram(new string[][] {A, B});
Image().add(tree);
```

Run with: `asy myfile.asy`

That's it! This creates a complete tree diagram with automatic rendering.

---

## Diagram Types

### 1. Tree Diagrams

For probability trees, decision trees, and hierarchical outcomes.

```asy
import MaximumMathematics;

string[] coins = {"H", "T"};
string[] colors = {"B", "R"};

TreeDiagram tree = TreeDiagram(new string[][] {coins, colors});

ImageConfig config = ImageConfig();
config.caption = "Coin Flip Outcomes";

Image(config).add(tree);
```

**Features:**
- Arbitrary number of levels
- Branch pruning (show/hide branches)
- Automatic layout
- Customizable spacing and styling

### 2. Truth Tables

For logical propositions and boolean algebra.

```asy
import MaximumMathematics;

bool[] p_and_q = {false, false, false, true};
bool[] p_or_q = {false, true, true, true};

Proposition[] props = {
    Proposition("$p \\land q$", p_and_q),
    Proposition("$p \\lor q$", p_or_q)
};

TruthTableDiagram table = TruthTableDiagram(2, props);
table.highlight_cell(1, 0);  // Show differences

ImageConfig config = ImageConfig();
config.caption = "AND vs OR Operations";

Image(config).add(table);
```

**Features:**
- Arbitrary number of variables (1-8+, practical limit ~4-5)
- Cell highlighting and hiding
- Custom column widths
- LaTeX support in headers

### 3. Relation Diagrams

For functions, relations, and mappings between sets.

```asy
import MaximumMathematics;

SetData[] sets = {
    SetData("Domain", new string[] {"1", "2", "3"}),
    SetData("Codomain", new string[] {"a", "b", "c"})
};

RelationDiagram diagram = RelationDiagram(sets);
diagram.add_relation(0, new pair[] {(0,0), (1,1), (2,2)});

ImageConfig config = ImageConfig();
config.caption = "Bijective Function";

Image(config).add(diagram);
```

**Features:**
- Arbitrary number of sets (2-5+ practical)
- Multiple relations (function composition)
- Automatic layout
- LaTeX support

---

## Gallery Support

Create grids of multiple diagrams:

```asy
import MaximumMathematics;

// Create diagrams
TreeDiagram tree = TreeDiagram(sets1);
TruthTableDiagram table = TruthTableDiagram(2, props);

// Create images with captions
ImageConfig config1 = ImageConfig();
config1.caption = "Tree Diagram";
Image img1 = Image(config1);
img1.add(tree);

ImageConfig config2 = ImageConfig();
config2.caption = "Truth Table";
Image img2 = Image(config2);
img2.add(table);

// Arrange in gallery
Gallery gallery = Gallery(1, 2, visual_width=4, visual_height=3);  // 1 row, 2 columns
gallery.add(diagram1, 0, 0, "Figure 1: First diagram");
gallery.add(diagram2, 0, 1, "Figure 2: Second diagram");
gallery.render();
```

---

## Architecture

Maximum Mathematics uses a **layered architecture**:

```
Layer 4: Gallery          ← Grid layout for multiple diagrams
Layer 3: Image            ← Zone management, captions, auto-rendering
Layer 2: *Diagram         ← TreeDiagram, TruthTableDiagram, RelationDiagram
Layer 1: Implementation   ← Core rendering engines (deprecated but used internally)
Layer 0: Data             ← Your data structures
```

**Design Philosophy:**
- **Data** → **Diagram** → **Image** → **Gallery**
- Configure at the appropriate level
- Sensible defaults everywhere
- Automatic rendering throughout

---

## Documentation

### Getting Started
- **README.md** (this file) - Overview and quick start
- **UNIFIED_API.md** - Complete API reference with examples
- **MARGIN_SYSTEM.md** - CSS-like margin system guide
- **MIGRATION_GUIDE.md** - How to migrate from older APIs

### Architecture & Design
- **ARCHITECTURE.md** - System design and architecture details
- **REFACTORING_SUMMARY.md** - Evolution and refactoring history

### Specific Diagram Types (Deprecated but still useful)
- **TREE_OOP_API.md** - Old tree API (deprecated)
- **TRUTH_TABLE_API.md** - Old truth table API (deprecated)
- **ARROW_DIAGRAM_API.md** - Old relation API (deprecated)

### Refactoring Details
- **TREE_DIAGRAM_REFACTORING.md** - Tree refactoring details
- **TRUTH_TABLE_REFACTORING.md** - Truth table refactoring details
- **ARROW_DIAGRAM_REFACTORING.md** - Relation diagram refactoring details

---

## Examples

All examples are organized in the `Examples/` directory by type:

### Gallery Examples (`Examples/Gallery/`)
- `test_gallery.asy` - 2x2 gallery with relation diagrams
- `test_gallery_simple.asy` - Simple 1x2 gallery
- `test_gallery_minimal.asy` - Minimal single-cell gallery
- `test_gallery_2x3.asy` - 2x3 gallery with colored squares
- `test_gallery_colored_squares.asy` - 2x2 gallery demonstration

### Image Examples (`Examples/Image/`)
- `test_layout.asy` - Image layout and zone management testing

### Relation Diagram Examples (`Examples/RelationDiagram/`)
- `test_relation_diagram.asy` - Basic relation diagram with 3 sets
- `test_relation_types_gallery.asy` - Gallery showing different relation types (injective, surjective, bijective)

All examples use the unified API and demonstrate the modular architecture.

---

## API Comparison

### Generation 3: Unified (RECOMMENDED)

```asy
TreeDiagram tree = TreeDiagram(sets);
ImageConfig config = ImageConfig();
config.caption = "My Tree";
Image(config).add(tree);
```

**Advantages:**
- 2-5 lines for most diagrams
- Auto-rendering
- Built-in captions
- Gallery support
- Consistent across all diagram types

### Generation 2: Old OOP (DEPRECATED)

```asy
Tree tree = Tree(sets, 14, 11);
tree.prune("T");
tree.draw();
```

**Status:** Deprecated but functional. Use Gen 3 for new code.

### Generation 1: Legacy Procedural (DEPRECATED)

```asy
truth_table_2(1cm, 7, 5, propositions, {}, lightyellow, {});
```

**Status:** Deprecated but functional. Use Gen 3 for new code.

---

## Features in Detail

### Automatic Rendering

No need to call `draw()`, `render()`, or manage output:

```asy
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);  // Automatically renders to SVG!
```

The system:
- Automatically adds to `currentpicture`
- Sets `settings.outformat = "svg"` by default
- Handles all coordinate transformations
- Manages zone layout

### Caption Support

**NEW: Two-Part Professional Captions**

Captions with separate title and explanation (publication-ready):

```asy
ImageConfig config = ImageConfig();
config.caption_title = "Figure 1:";              // Left-aligned title
config.caption_text = "Sample space diagram";    // Left-aligned explanation
config.caption_height = 1.2;
config.caption_title_width = 2.0;  // Optional: explicit title width

Image(config).add(diagram);
```

**OLD: Single Centered Caption** (still supported):

```asy
ImageConfig config = ImageConfig();
config.caption = "Probability Distribution";
config.caption_text_factor = 2.0;  // Larger caption
config.caption_pen = blue;         // Colored caption

Image(config).add(diagram);
```

Layout:
```
┌─────────────────────────────────────────┐
│         Caption Zone                    │
│  ┌─────────┬──────────────────────────┐ │
│  │Figure 1:│ The explanation text     │ │
│  │         │ will go here             │ │
│  └─────────┴──────────────────────────┘ │
└─────────────────────────────────────────┘
```

Captions automatically:
- Appear at bottom
- Support two-part (title + text) or single format
- Both left-aligned at same height
- Scale with image size
- Support LaTeX math notation

### CSS-like Box Model (Margins + Padding)

Control spacing with the complete CSS box model:

```asy
ImageConfig config = ImageConfig();
config.canvas_width = 8;                 // Canvas size
config.canvas_height = 6;

// Margins (outside canvas/caption zones)
config.margin = 0.5;                     // Uniform margin
config.margin_horizontal = 1.0;          // Override left + right
config.margin_left = 2.0;                // Override left specifically

// Padding (inside canvas zone)
config.canvas_padding = 0.3;             // Uniform canvas padding
config.canvas_padding_top = 0.5;         // Override top specifically

// Padding (inside caption zone)
config.caption_padding_vertical = 0.2;   // Caption padding

Image(config).add(diagram);
```

**Box Model Priority** (CSS-like specificity):
1. `margin/padding` - All sides (lowest priority)
2. `margin_horizontal/vertical` or `padding_horizontal/vertical` - Override pairs
3. `margin_left/right/top/bottom` or `padding_left/right/top/bottom` - Individual (highest priority)

**Layout:**
- **Margins**: Space outside canvas/caption zones
- **Canvas zone**: Fixed size containing visualization
- **Canvas padding**: Space inside canvas (reduces visualization area)
- **Caption padding**: Space inside caption zone

**See**: `MARGIN_SYSTEM.md` for complete documentation

### Zone Management

Images are divided into zones:

```
┌──────────────────────┐
│  Content Margin      │
│  ┌────────────────┐  │
│  │                │  │
│  │  Content Zone  │  │ ← Your diagram renders here
│  │                │  │
│  └────────────────┘  │
│  Content Margin      │
│  ┌────────────────┐  │
│  │ Caption Zone   │  │ ← Optional caption
│  └────────────────┘  │
└──────────────────────┘
```

All zone calculations are automatic.

### Gallery Layout

Arrange multiple diagrams in a grid:

```asy
Gallery gallery = Gallery(2, 3, visual_width=4, visual_height=3);  // 2 rows, 3 columns
gallery.add(diagram1, 0, 0, "Figure 1:");  // Top-left
gallery.add(diagram2, 0, 1, "Figure 2:");  // Top-middle
gallery.add(diagram3, 0, 2, "Figure 3:");  // Top-right
gallery.add(diagram4, 1, 0, "Figure 4:");  // Bottom-left
gallery.render();
// ... etc
```

Grid positioning:
- `(row, col)` indexing (0-based)
- Automatic spacing and layout
- Individual cell captions
- Gallery-wide caption support
- Handles empty cells

### Layered Configuration

Configure at the appropriate level:

```asy
// Image-level (affects presentation)
ImageConfig img_config = ImageConfig();
img_config.width = 14;
img_config.caption = "My Diagram";
img_config.background_color = lightblue;

// Diagram-level (affects visualization)
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 12;
tree_config.draw_pruned_branches = true;

// Create and combine
TreeDiagram tree = TreeDiagram(sets, tree_config);
tree.prune("T");  // Convenience method

Image(img_config).add(tree);
```

---

## Design Principles

1. **Declarative over Imperative** - Say what you want, not how to do it
2. **Sensible Defaults** - Zero configuration works for 80% of use cases
3. **Automatic Everything** - Rendering, layout, spacing all automatic
4. **Layered Configuration** - Configure at the right level
5. **Backward Compatible** - Never break existing code
6. **Easy to Extend** - Adding new diagram types is straightforward

---

## Color Palette

Maximum Mathematics includes a built-in color scheme:

- **Brand Colors**: Blue (RGB(0,0,255)), Orange (RGB(255,165,0))
- **Table Colors**: Gray headers, medium gray sub-headers
- **Tree Colors**: Red for pruned branches
- **Custom Colors**: Full Asymptote color support

---

## Output Formats

Supported formats (via standard Asymptote):

- **SVG** (default) - Scalable vector graphics
- **EPS** - Encapsulated PostScript
- **PDF** - Portable Document Format
- **PNG** - Raster graphics (with resolution control)

Change format with:
```asy
settings.outformat = "pdf";
```

---

## Requirements

- **Asymptote** 2.70+ (vector graphics language)
- **LaTeX** (for mathematical notation)

### Installation

#### Ubuntu/Debian
```bash
sudo apt install asymptote
```

#### macOS
```bash
brew install asymptote
```

#### Windows
Download from: http://asymptote.sourceforge.io/

---

## Usage

### Command Line

```bash
asy mydiagram.asy          # Creates mydiagram.svg (default)
asy -f pdf mydiagram.asy   # Creates mydiagram.pdf
asy -f eps mydiagram.asy   # Creates mydiagram.eps
```

### In Your Code

```asy
import MaximumMathematics;

// Your diagram code here
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);
```

---

## Project Structure

```
Asymptote/
├── MaximumMathematics.asy          # Main library (includes all modules)
│
├── Utilities/                      # Utility modules
│   ├── TextWrapping.asy            # Text wrapping utilities
│   ├── Image.asy                   # Image struct (zone management, captions)
│   └── Gallery.asy                 # Gallery struct (grid layouts)
│
├── Visualizations/                 # Visualization modules
│   └── RelationDiagram.asy         # Relation diagram implementation
│
└── Examples/                       # Example files organized by type
    ├── Gallery/                    # Gallery examples
    │   ├── test_gallery.asy
    │   ├── test_gallery_simple.asy
    │   ├── test_gallery_minimal.asy
    │   ├── test_gallery_2x3.asy
    │   └── test_gallery_colored_squares.asy
    ├── Image/                      # Image examples
    │   └── test_layout.asy
    └── RelationDiagram/           # Relation diagram examples
        ├── test_relation_diagram.asy
        └── test_relation_types_gallery.asy
```

---

## Common Use Cases

### Academic Papers

```asy
// Clean, professional diagrams with captions
TruthTableDiagram table = TruthTableDiagram(3, propositions);
ImageConfig config = ImageConfig();
config.caption = "Figure 1: De Morgan's Laws";
Image(config).add(table);
```

### Textbooks

```asy
// Multiple related diagrams
Gallery gallery = Gallery(2, 2, visual_width=4, visual_height=3);
gallery.add(example1, 0, 0, "Example 1:");
gallery.add(example2, 0, 1, "Example 2:");
gallery.add(exercise1, 1, 0, "Exercise 1:");
gallery.add(solution1, 1, 1, "Solution 1:");
gallery.render();
```

### Presentations

```asy
// Large, clear diagrams
ImageConfig config = ImageConfig();
config.width = 16;
config.height = 12;
config.background_color = rgb(0.95, 0.95, 1.0);

TreeDiagram tree = TreeDiagram(sets);
Image(config).add(tree);
```

### Problem Sets

```asy
// Hide answers for student exercises
TruthTableDiagram table = TruthTableDiagram(2, props);
table.hide_cells(new pair[] {(0,0), (1,0)});

ImageConfig config = ImageConfig();
config.caption = "Exercise 3.1";
Image(config).add(table);
```

---

## Advanced Features

### Custom Styling

```asy
// Diagram-level styling
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 12;         // Larger dots
tree_config.draw_pruned_branches = true;

// Image-level styling
ImageConfig img_config = ImageConfig();
img_config.background_color = rgb(0.98, 0.98, 1.0);
img_config.content_margin = 0.3;

TreeDiagram tree = TreeDiagram(sets, tree_config);
Image(img_config).add(tree);
```

### Branch Pruning

```asy
TreeDiagram tree = TreeDiagram(sets);
tree.prune("T");                    // Prune entire branch
tree.prune("H", "element");         // Prune specific path
tree.show_pruned_branches(true);    // Show in red

Image().add(tree);
```

### Cell Highlighting

```asy
TruthTableDiagram table = TruthTableDiagram(3, props);
table.highlight_cells(new pair[] {(0,0), (1,1), (2,0)});
table.set_variable_names(new string[] {"p", "q", "r"});

Image().add(table);
```

### Multi-Set Relations

```asy
// Function composition: A → B → C → D
SetData[] sets = {
    SetData("A", elements_A),
    SetData("B", elements_B),
    SetData("C", elements_C),
    SetData("D", elements_D)
};

RelationDiagram diagram = RelationDiagram(sets);
diagram.add_relation(0, arrows_AB);  // A → B
diagram.add_relation(1, arrows_BC);  // B → C
diagram.add_relation(2, arrows_CD);  // C → D

Image().add(diagram);
```

---

## API Evolution

Maximum Mathematics has evolved through three generations:

| Generation | Status | Description |
|------------|--------|-------------|
| **Gen 3** | ✅ **Current** | Unified architecture with auto-rendering |
| Gen 2 | ⚠️ Deprecated | Old OOP API (still works) |
| Gen 1 | ⚠️ Deprecated | Legacy procedural (still works) |

**All generations work simultaneously** - migrate at your own pace.

---

## Performance

- **Rendering Speed**: Fast for typical use cases (< 1 second)
- **Output Size**: SVG files typically 10-50 KB
- **Scalability**: 
  - Trees: Tested with 5+ levels, dozens of branches
  - Truth Tables: Tested with 4 variables (16 rows)
  - Relations: Tested with 5 sets, 50+ arrows
  - Galleries: Tested with 3x3 grids (9 diagrams)

---

## Contributing

When extending the library:

1. Follow the established patterns (see `ARCHITECTURE.md`)
2. Provide sensible defaults for all configuration
3. Create both minimal and advanced examples
4. Document the new features
5. Maintain backward compatibility

### Adding New Diagram Types

See `ARCHITECTURE.md` section "Extension Points" for details on adding new diagram types following the unified architecture pattern.

---

## Version History

### v3.0 (November 2025) - Unified Architecture
- Added `Image` coordinator with zone management
- Added `Gallery` for multiple diagrams
- Created `*Diagram` wrappers with `*Config` structs
- Implemented automatic rendering
- Built-in caption support
- Marked Gen 2 APIs as deprecated

### v3.1 (November 2025) - Modular Refactoring
- Extracted utilities to `Utilities/` folder:
  - `TextWrapping.asy` - Text wrapping functions
  - `Image.asy` - Image struct implementation
  - `Gallery.asy` - Gallery struct implementation
- Extracted visualizations to `Visualizations/` folder:
  - `RelationDiagram.asy` - Relation diagram implementation
- Organized examples by type in `Examples/` subfolders
- Improved code organization and maintainability

### v2.0 (2024) - OOP Refactoring
- Refactored trees to support arbitrary levels
- Refactored truth tables to support arbitrary variables
- Refactored arrow diagrams to support arbitrary sets
- Created OOP interfaces (Tree, TruthTable, ArrowDiagram)
- Eliminated 60-75% code duplication

### v1.0 (2020-2024) - Initial Release
- Procedural functions for trees, truth tables, arrow diagrams
- Support for 1-3 levels/variables/sets
- Basic graphing and plotting functions

---

## License

[Add your license here]

---

## Credits

Maximum Mathematics
Created by Jacob Hiance

---

## Support

For questions, issues, or contributions, see the documentation in this repository.

---

## Quick Reference Card

```asy
// ═══════════════════════════════════════════════
// MAXIMUM MATHEMATICS - QUICK REFERENCE
// ═══════════════════════════════════════════════

import MaximumMathematics;

// ──────── TREE DIAGRAM ────────
TreeDiagram tree = TreeDiagram(new string[][] {A, B});
tree.prune("element");
Image().add(tree);

// ──────── TRUTH TABLE ────────
bool[] values = {false, false, false, true};
Proposition[] props = {Proposition("$p \\land q$", values)};
TruthTableDiagram table = TruthTableDiagram(2, props);
table.highlight_cell(0, 0);
Image().add(table);

// ──────── RELATION DIAGRAM ────────
SetData[] sets = {SetData("A", A), SetData("B", B)};
RelationDiagram diagram = RelationDiagram(sets);
diagram.add_relation(0, arrows);
Image().add(diagram);

// ──────── WITH CAPTION ────────
ImageConfig config = ImageConfig();
config.caption = "My Caption";
config.width = 12;
Image(config).add(diagram);

// ──────── GALLERY ────────
Gallery gallery = Gallery(2, 2, visual_width=4, visual_height=3);
gallery.add(diagram1, 0, 0, "Figure 1:");
gallery.add(diagram2, 0, 1, "Figure 2:");
gallery.render();

// ═══════════════════════════════════════════════
```

---

**Start creating beautiful mathematical diagrams in just 2-5 lines of code!**

