# Maximum Mathematics Unified API

## Overview

The **Unified API** is the recommended way to create diagrams in Maximum Mathematics. It provides a clean, declarative interface with automatic rendering and sensible defaults at every level.

## Architecture Layers

The system has four distinct layers:

```
┌─────────────────────────────────────────┐
│  Layer 4: Gallery (optional)            │  Multiple images in grid
├─────────────────────────────────────────┤
│  Layer 3: Image                          │  Canvas with zones (caption + content)
├─────────────────────────────────────────┤
│  Layer 2: Diagrams                       │  TreeDiagram, TruthTableDiagram, RelationDiagram
├─────────────────────────────────────────┤
│  Layer 1: Data + Config                  │  Your data + optional configuration
└─────────────────────────────────────────┘
```

### Layer 1: Data & Configuration

**Data Structures:**
- `string[][]` - For tree diagrams
- `Proposition[]` - For truth tables
- `SetData[]` - For relation diagrams

**Configuration Structs:**
- `ImageConfig` - Image-wide settings (size, caption, background)
- `TreeConfig` - Tree-specific settings
- `TruthTableConfig` - Truth table-specific settings
- `RelationDiagramConfig` - Relation diagram-specific settings

### Layer 2: Diagram Wrappers

- `TreeDiagram` - Wraps tree data and config
- `TruthTableDiagram` - Wraps truth table data and config
- `RelationDiagram` - Wraps relation data and config

### Layer 3: Image Coordinator

- `Image` - Manages single diagram with zones and auto-rendering

### Layer 4: Gallery (Optional)

- `Gallery` - Arranges multiple diagrams in a grid layout

---

## Quick Start Examples

### Example 1: Simplest Possible (All Defaults)

```asy
import MaximumMathematics;

string[] A = {"H", "T"};
string[] B = {"B", "R"};

TreeDiagram tree = TreeDiagram(new string[][] {A, B});
Image().add(tree);
```

That's it! 5 lines for a complete, rendered diagram.

### Example 2: With Caption

```asy
import MaximumMathematics;

TreeDiagram tree = TreeDiagram(new string[][] {A, B});

ImageConfig config = ImageConfig();
config.caption = "Coin Flip Outcomes";
config.width = 12;
config.height = 10;

Image(config).add(tree);
```

### Example 3: Customized at All Levels

```asy
import MaximumMathematics;

// 1. Configure diagram
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 10;

TreeDiagram tree = TreeDiagram(sets, tree_config);
tree.prune("T");
tree.show_pruned_branches(true);

// 2. Configure image
ImageConfig img_config = ImageConfig();
img_config.caption = "Probability Tree with Pruning";
img_config.width = 14;
img_config.height = 12;
img_config.background_color = rgb(0.98, 0.98, 1.0);

// 3. Create and auto-render
Image(img_config).add(tree);
```

### Example 4: Truth Table

```asy
import MaximumMathematics;

bool[] p_and_q = {false, false, false, true};
bool[] p_or_q = {false, true, true, true};

Proposition[] props = {
    Proposition("$p \\land q$", p_and_q),
    Proposition("$p \\lor q$", p_or_q)
};

TruthTableDiagram table = TruthTableDiagram(2, props);
table.highlight_cell(1, 0);

ImageConfig config = ImageConfig();
config.caption = "AND vs OR Operations";
config.width = 8;
config.height = 6;

Image(config).add(table);
```

### Example 5: Relation Diagram

```asy
import MaximumMathematics;

SetData[] sets = {
    SetData("A", new string[] {"1", "2", "3"}),
    SetData("B", new string[] {"a", "b", "c"})
};

RelationDiagram diagram = RelationDiagram(sets);
diagram.add_relation(0, new pair[] {(0,0), (1,1), (2,2)});

ImageConfig config = ImageConfig();
config.caption = "Bijective Function";
config.width = 10;
config.height = 8;

Image(config).add(diagram);
```

### Example 6: Gallery (Multiple Diagrams)

```asy
import MaximumMathematics;

// Create a gallery with 2 rows and 2 columns
Gallery gallery = Gallery(2, 2, visual_width=4, visual_height=3);

// Create relation diagrams for each cell
RelationDiagram diagram1 = RelationDiagram();
diagram1.add_set(new string[] {"1", "2"}, "A");
diagram1.add_set(new string[] {"a", "b"}, "B");
diagram1.add_relation(0, 1, new pair[] {(0,0), (1,1)});

RelationDiagram diagram2 = RelationDiagram();
diagram2.add_set(new string[] {"3", "4"}, "C");
diagram2.add_set(new string[] {"c", "d"}, "D");
diagram2.add_relation(0, 1, new pair[] {(0,1), (1,0)});

// Add diagrams to gallery with captions
gallery.add(diagram1, 0, 0, "Figure 1: First relation");
gallery.add(diagram2, 0, 1, "Figure 2: Second relation");

// Ensure gallery is rendered
gallery.render();
```

---

## API Reference

### ImageConfig

```asy
struct ImageConfig {
    real width = 10;
    real height = 8;
    real unit = 1cm;
    pen background_color = white;
    real caption_zone_factor = 0.1;
    real content_margin = 0.2;
    string caption = "";
    real caption_text_factor = 1.5;
    pen caption_pen = black;
}
```

**Key Members:**
- `width`, `height` - Image dimensions in units
- `unit` - Unit size (default: 1cm)
- `caption` - Text at bottom (empty = no caption)
- `caption_zone_factor` - Caption height as fraction of total (default: 0.1 = 10%)
- `content_margin` - Margin around diagram content
- `background_color` - Image background

### TreeConfig

```asy
struct TreeConfig {
    real[] label_location_factors;  // Empty = auto
    real[] label_widths;            // Empty = auto
    real[] branch_margins;          // Empty = auto
    real[] dot_margins;             // Empty = auto
    real dot_factor = 8;
    pen label_pen = black;
    bool draw_pruned_branches = false;
    PrunedBranches pruned_branches;
}
```

### TruthTableConfig

```asy
struct TruthTableConfig {
    real header_row_factor = -1;      // -1 = auto
    string[] variable_names;          // Empty = default (p, q, r, ...)
    pair[] highlighted_cells;
    pen highlight_color = lightyellow;
    pair[] hidden_cells;
}
```

### RelationDiagramConfig

```asy
struct RelationDiagramConfig {
    real dot_factor = 0.5;
    real element_text_factor = 1.5;
    real set_text_factor = 3;
}
```

### TreeDiagram

```asy
struct TreeDiagram {
    TreeDiagram(string[][] sets, TreeConfig config = TreeConfig());
    
    // Convenience methods
    void prune(string element);
    void prune(string e1, string e2);
    void prune(string e1, string e2, string e3);
    void show_pruned_branches(bool show = true);
    void set_label_locations(real[] factors);
    void set_label_widths(real[] widths);
}
```

### TruthTableDiagram

```asy
struct TruthTableDiagram {
    TruthTableDiagram(int num_variables, Proposition[] propositions,
                      TruthTableConfig config = TruthTableConfig());
    
    // Convenience methods
    void highlight_cell(int row, int col);
    void highlight_cells(pair[] cells);
    void set_variable_names(string[] names);
    void hide_cell(int row, int col);
}
```

### RelationDiagram

```asy
struct RelationDiagram {
    RelationDiagram(SetData[] sets, RelationDiagramConfig config = RelationDiagramConfig());
    
    // Convenience methods
    void add_relation(int from_set, pair[] arrows);
    void add_relation(int from_set, int to_set, pair[] arrows);
}
```

### Image

```asy
struct Image {
    Image(ImageConfig config = ImageConfig());
    
    void add(TreeDiagram diagram);          // Adds and auto-renders
    void add(TruthTableDiagram diagram);    // Adds and auto-renders
    void add(RelationDiagram diagram);      // Adds and auto-renders
}
```

**Auto-rendering**: When you call `Image().add(diagram)`, the image is automatically rendered to `currentpicture`. No explicit render call needed!

### Gallery

```asy
struct Gallery {
    Gallery(int rows, int cols, real visual_width = 5, real visual_height = 4);
    
    void add(RelationDiagram diagram, int row, int col, string caption_label = "");
    void add(picture pic, int row, int col, string caption_label = "");
    void render();  // Explicit render (recommended for picture-based galleries)
}
```

**Auto-rendering**: When adding a `RelationDiagram`, the gallery automatically re-renders. For `picture`-based galleries, call `render()` explicitly after all `add()` calls.

---

## Design Philosophy

### 1. Declarative Over Imperative

**Old way (imperative):**
```asy
Tree tree = Tree(...);
tree.set_label_locations(...);
tree.set_label_widths(...);
tree.draw(pic);
add(currentpicture, pic);
```

**New way (declarative):**
```asy
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);
```

### 2. Sensible Defaults Everywhere

You only configure what you want to change:

```asy
// Minimal - just data
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);

// Customize diagram only
TreeConfig config = TreeConfig();
config.dot_factor = 10;
TreeDiagram tree = TreeDiagram(sets, config);
Image().add(tree);

// Customize image only  
TreeDiagram tree = TreeDiagram(sets);
ImageConfig img_config = ImageConfig();
img_config.caption = "My Tree";
Image(img_config).add(tree);

// Customize both
TreeDiagram tree = TreeDiagram(sets, tree_config);
Image(img_config).add(tree);
```

### 3. Automatic Rendering

No need to call output/render methods:
- `Image().add(diagram)` - Automatically renders to `currentpicture`
- `gallery.add(img, pos)` - Automatically re-renders gallery
- `settings.outformat = "svg"` - Automatically set

### 4. Layered Configuration

Configuration happens at the appropriate level:

- **Diagram-level**: Pruning, highlighting, relations
- **Image-level**: Size, caption, background
- **Gallery-level**: Grid layout, spacing

### 5. Config Inheritance

Diagrams inherit settings from ImageConfig where appropriate (like `unit` size).

---

## Image Zone Layout

```
┌───────────────────────────────────────┐
│           Image (total size)          │
│                                       │
│  ┌─────────────────────────────────┐ │
│  │      Caption Zone (bottom)      │ │  ← caption_zone_factor * height
│  │   "Probability Tree Diagram"    │ │     (only if caption provided)
│  ├─────────────────────────────────┤ │
│  │  margin                         │ │  ← content_margin
│  │  ┌───────────────────────────┐  │ │
│  │  │                           │  │ │
│  │  │    Content Zone          │  │ │  ← Diagram draws here
│  │  │  (TreeDiagram draws here) │  │ │
│  │  │                           │  │ │
│  │  └───────────────────────────┘  │ │
│  │                      margin     │ │
│  └─────────────────────────────────┘ │
└───────────────────────────────────────┘
```

---

## Common Patterns

### Pattern 1: Quick Visualization (No Config)

```asy
import MaximumMathematics;

// Just describe what you want
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);
```

### Pattern 2: With Caption

```asy
ImageConfig config = ImageConfig();
config.caption = "My Diagram Title";

TreeDiagram tree = TreeDiagram(sets);
Image(config).add(tree);
```

### Pattern 3: Customized Diagram

```asy
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 12;

TreeDiagram tree = TreeDiagram(sets, tree_config);
tree.prune("element");

Image().add(tree);
```

### Pattern 4: Fully Customized

```asy
// Configure everything
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 12;
tree_config.draw_pruned_branches = true;

TreeDiagram tree = TreeDiagram(sets, tree_config);
tree.prune("T");

ImageConfig img_config = ImageConfig();
img_config.caption = "Custom Tree";
img_config.width = 14;
img_config.height = 12;
img_config.background_color = rgb(0.95, 0.95, 1.0);

Image(img_config).add(tree);
```

### Pattern 5: Gallery

```asy
// Create gallery
Gallery gallery = Gallery(1, 2, visual_width=4, visual_height=3);

// Create diagrams
RelationDiagram diagram1 = RelationDiagram();
diagram1.add_set(new string[] {"1", "2"}, "A");
diagram1.add_set(new string[] {"a", "b"}, "B");
diagram1.add_relation(0, 1, new pair[] {(0,0), (1,1)});

RelationDiagram diagram2 = RelationDiagram();
diagram2.add_set(new string[] {"3", "4"}, "C");
diagram2.add_set(new string[] {"c", "d"}, "D");
diagram2.add_relation(0, 1, new pair[] {(0,1), (1,0)});

// Add to gallery with captions
gallery.add(diagram1, 0, 0, "Figure 1: First relation");
gallery.add(diagram2, 0, 1, "Figure 2: Second relation");

// Render gallery
gallery.render();
```

---

## Complete Examples by Diagram Type

### Tree Diagrams

```asy
import MaximumMathematics;

string[] A = {"H", "T"};
string[] B = {"$\\spadesuit$", "$\\heartsuit$", "$\\diamondsuit$", "$\\clubsuit$"};
string[] C = {"B", "R"};

// Create and configure diagram
TreeConfig tree_config = TreeConfig();
tree_config.draw_pruned_branches = true;

TreeDiagram tree = TreeDiagram(new string[][] {A, B, C}, tree_config);
tree.prune("T");
tree.prune("H", "$\\diamondsuit$");

// Create image
ImageConfig img_config = ImageConfig();
img_config.caption = "Card Drawing with Pruned Branches";
img_config.width = 14;
img_config.height = 11;

Image(img_config).add(tree);
```

### Truth Tables

```asy
import MaximumMathematics;

// Define propositions for 3 variables
bool[] prop1 = {false, false, false, true, false, true, false, true};
bool[] prop2 = {false, false, false, true, true, true, true, true};

Proposition[] props = {
    Proposition("$(p \\lor q) \\land r$", prop1, 2),
    Proposition("$p \\lor (q \\land r)$", prop2, 2)
};

// Create diagram
TruthTableDiagram table = TruthTableDiagram(3, props);
table.highlight_cells(new pair[] {(4,0), (4,1), (6,0), (6,1)});
table.set_variable_names(new string[] {"p", "q", "r"});

// Create image
ImageConfig config = ImageConfig();
config.caption = "Demonstrating Associativity";
config.width = 9;
config.height = 7;

Image(config).add(table);
```

### Relation Diagrams

```asy
import MaximumMathematics;

SetData[] sets = {
    SetData("$\\mathbb{Z}_6$", new string[] {"0", "1", "2", "3", "4", "5"}),
    SetData("$\\mathbb{Z}_3$", new string[] {"0", "1", "2"})
};

RelationDiagram diagram = RelationDiagram(sets);
diagram.add_relation(0, new pair[] {
    (0,0), (1,1), (2,2), (3,0), (4,1), (5,2)
});

ImageConfig config = ImageConfig();
config.caption = "$f: \\mathbb{Z}_6 \\to \\mathbb{Z}_3$, $f(x) = x \\bmod 3$";
config.width = 10;
config.height = 10;

Image(config).add(diagram);
```

---

## Benefits of Unified API

### 1. Consistent Interface

All diagram types use the same pattern:
```asy
Diagram diagram = Diagram(data, config);
diagram.configure();
Image(img_config).add(diagram);
```

### 2. Automatic Everything

- Automatic zone calculation
- Automatic layout
- Automatic rendering
- Automatic defaults

### 3. Minimal Code

Compare line counts for same output:

| Approach | Lines | Description |
|----------|-------|-------------|
| Legacy procedural | 100+ | Manual everything |
| Old OOP API | 10-15 | Better, but still verbose |
| **Unified API** | **3-8** | **Declarative and minimal** |

### 4. Separation of Concerns

- **Data**: What to visualize
- **Diagram Config**: How to visualize it
- **Image Config**: How to present it
- **Gallery**: How to arrange multiple

### 5. Extensibility

Easy to add new diagram types:
1. Create `*Config` struct
2. Create `*Diagram` struct with `draw_in_zone()` method
3. Add overload to `Image.add()`

Done!

---

## Backward Compatibility

All old APIs still work:

```asy
// Legacy procedural API
truth_table_2(...);
arrow_diagram_3(...);
simple_tree_diagram(...);

// Old OOP API (now deprecated)
Tree tree = Tree(sets);
tree.draw();

TruthTable table = TruthTable(2, props);
table.draw();

ArrowDiagram diagram = ArrowDiagram(sets);
diagram.draw();
```

**Recommendation**: Migrate to unified API for new code. Old code continues to work indefinitely.

---

## Migration Guide

### From Legacy Procedural → Unified

**Before:**
```asy
truth_table_2(1cm, 7, 5, propositions, {}, lightyellow, {});
```

**After:**
```asy
TruthTableDiagram table = TruthTableDiagram(2, propositions);
Image().add(table);
```

### From Old OOP → Unified

**Before:**
```asy
Tree tree = Tree(sets, 14, 11);
tree.prune("T");
tree.draw();
```

**After:**
```asy
TreeDiagram tree = TreeDiagram(sets);
tree.prune("T");

ImageConfig config = ImageConfig();
config.width = 14;
config.height = 11;

Image(config).add(tree);
```

---

## Tips & Best Practices

### 1. Start Simple

Begin with defaults, then customize only what you need:

```asy
// Start here
TreeDiagram tree = TreeDiagram(sets);
Image().add(tree);

// Add caption if needed
ImageConfig config = ImageConfig();
config.caption = "My Tree";
Image(config).add(tree);

// Customize diagram if needed
TreeConfig tree_config = TreeConfig();
tree_config.dot_factor = 12;
TreeDiagram tree = TreeDiagram(sets, tree_config);
Image(config).add(tree);
```

### 2. Use Convenience Methods

Diagram wrappers provide convenience methods:

```asy
TreeDiagram tree = TreeDiagram(sets);
tree.prune("T");  // Easier than config.pruned_branches.prune_branch(...)

TruthTableDiagram table = TruthTableDiagram(2, props);
table.highlight_cell(0, 0);  // Easier than config.highlighted_cells.push(...)
```

### 3. Reuse Configs

Create config templates for consistent styling:

```asy
// Define once
ImageConfig standard_image = ImageConfig();
standard_image.width = 12;
standard_image.height = 10;
standard_image.background_color = rgb(0.98, 0.98, 1.0);

// Reuse multiple times
ImageConfig config1 = standard_image;
config1.caption = "Diagram 1";

ImageConfig config2 = standard_image;
config2.caption = "Diagram 2";
```

### 4. Gallery for Comparisons

Use galleries to show related diagrams:

```asy
Gallery gallery = Gallery(1, 3, visual_width=4, visual_height=3);  // 1 row, 3 columns
gallery.add(diagram1, 0, 0, "Figure 1:");
gallery.add(diagram2, 0, 1, "Figure 2:");
gallery.add(diagram3, 0, 2, "Figure 3:");
gallery.render();
```

---

## Frequently Asked Questions

**Q: Do I need to call anything to render the output?**  
A: No! `Image().add(diagram)` automatically renders. Just set `settings.outformat` if you want a format other than SVG.

**Q: Can I add multiple diagrams to one Image?**  
A: No, one diagram per Image. Use `Gallery` for multiple diagrams in a grid layout.

**Q: What if I don't want a caption?**  
A: Just leave `config.caption` empty (default). No caption zone is created.

**Q: Can I still use the old Tree/TruthTable/ArrowDiagram structs?**  
A: Yes, they're deprecated but still work. Migrate when convenient.

**Q: How do I control output format?**  
A: Use `settings.outformat = "svg"` (or "eps", "pdf", etc.) - this is standard Asymptote.

**Q: What's the practical limit for gallery size?**  
A: 2x2 or 3x2 works well. Larger galleries may need larger output sizes.

**Q: How is the code organized?**  
A: The library is modular:
- `MaximumMathematics.asy` - Main entry point (includes all modules)
- `Utilities/` - Utility modules (TextWrapping, Image, Gallery)
- `Visualizations/` - Visualization modules (RelationDiagram)
- All modules are automatically included when you `import MaximumMathematics;`

---

## Project Structure

The Maximum Mathematics library is organized into modular components:

```
Asymptote/
├── MaximumMathematics.asy          # Main library (includes all modules)
│
├── Utilities/                      # Utility modules
│   ├── TextWrapping.asy            # Text wrapping for captions
│   ├── Image.asy                   # Image struct (zone management)
│   └── Gallery.asy                 # Gallery struct (grid layouts)
│
├── Visualizations/                 # Visualization modules
│   └── RelationDiagram.asy         # Relation diagram implementation
│
└── Examples/                       # Example files
    ├── Gallery/                    # Gallery examples
    ├── Image/                      # Image examples
    └── RelationDiagram/            # Relation diagram examples
```

**Usage**: Simply `import MaximumMathematics;` - all modules are automatically included.

## See Also

- `Examples/Gallery/` - Gallery layout examples
- `Examples/Image/` - Image and layout examples
- `Examples/RelationDiagram/` - Relation diagram examples
- `MaximumMathematics.asy` - Main library file
- `Utilities/` - Utility modules (text wrapping, image, gallery)
- `Visualizations/` - Visualization modules (relation diagrams)

