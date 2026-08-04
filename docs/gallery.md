---
title: Gallery
nav_order: 4
---

# The `Gallery`
{: .no_toc }

1. TOC
{:toc}

---

`Gallery` arranges several visualizations in a grid. Create it with the grid shape (required, fixed for the gallery's lifetime) and configure it with fluent methods, the same way as [`Image`]({% link image.md %}). `width`/`height` describe the grid's own area only — a gallery-wide caption, if you add one, is stacked below that area and sized to fit its own content, rather than being carved out of the height you give it. See [Sizing](#sizing) below.

```asy
Gallery gallery = Gallery(2, 3);   // 2 rows, 3 columns — required, fixed for the gallery's life
```

Size can be set after construction with `width(w)` / `height(h)` (defaults `20 x 8`).

Visualizations are added one at a time with `add(visualization)`: the gallery places each one in row-major order — row 0 left to right, then row 1 left to right, and so on — starting at the top left.

```asy
gallery.add(diagram_a);   // top-left
gallery.add(diagram_b);   // next cell to the right
```

There's no way to target a specific cell, and no way to leave a gap partway through — this keeps the API to one method with no parameters to get wrong. It's fine to add fewer visualizations than there are cells; the remaining cells are simply left empty. Adding more than `rows * cols` visualizations aborts.

Like [`Image`]({% link image.md %}), the gallery **renders automatically** as you add to it, so you never call a render function yourself.

## Configuration methods

| Concern | Methods |
|---|---|
| **Dimensions** | `width(w)`, `height(h)` — the grid area only, see [Sizing](#sizing) |
| **Padding** (around the grid, inside its area) | `padding(p)` / `padding(h, v)` / `padding(l, t, r, b)`, `padding_horizontal/vertical(p)`, `padding_left/right/top/bottom(p)` |
| **Margin** (between adjacent cells only) | `margin(m)` — see [The grid](#the-grid) |
| **Caption** | `caption_title(text)`, `caption_text(text)` — see [Captions](#captions) |
| **Background** | `background_color(pen)` |
| **Cell coloring** | `color_scheme(scheme)` — see [Color schemes](#color-schemes) |
| **Cell labels** | `label_scheme(scheme)` — see [Label schemes](#label-schemes) |
| **Debug** | `debug()` |
| **Add + render** | `add(visualization)`, `add_visual(picture)` |

`padding` is overloaded by argument count, exactly like `Image`'s: the 1-argument form sets all four sides, the 2-argument form sets horizontal then vertical, and the 4-argument form sets left, top, right, and bottom independently. `margin` takes a single value — the gap between adjacent cells only, never at the grid's outer boundary, which `padding` governs instead (see below).

## Sizing

`width`/`height` size the grid area only. With no caption, that's also the size of the whole rendered picture. With one, the caption zone sits directly beneath the grid, spanning the same width, with its own height auto-sized to exactly fit its content — the same additive model `Image` uses.

## The grid

Once the grid area is bounded by `padding`, the remaining space is evenly divided into `rows x cols` cells. `margin` is the gap **between** adjacent cells only — like a CSS grid-gap, not a per-cell inset — so it never applies at the grid's outer edge:

- An interior cell gets `margin` on all four sides (shared with its neighbors).
- A top-left cell gets `margin` only on its right and bottom.
- An edge cell (not a corner) gets `margin` on every side except the one touching the outer boundary.

Every cell is the same size. If `label_scheme` is active (see below), part of each cell's height — just enough to fit the label — is reserved at the bottom for the label, and the visualization itself is confined to the rest.

A visualization added to a cell is automatically **centered** within that cell (or its visual sub-area, if a label is present) if it doesn't fill it exactly, the same as `Image`'s centering behavior.

## Captions

A gallery-wide caption works exactly like `Image`'s: an optional left-aligned **title** and left-aligned, word-wrapped **text**, laid out as one line beneath the grid. When both are given, a colon and a space are inserted between them automatically. Provide only `caption_title`, only `caption_text`, or both — provide neither and no caption zone is created. See `Image`'s [Captions](image.md#captions) section for the full behavior, including how wrapped continuation lines stay indented.

```asy
gallery.caption_title("Figure 1");
gallery.caption_text("Three kinds of relations between two sets.");
```

There's no per-cell caption — only the one gallery-wide caption below the grid, and (optionally) the short automatic labels described next.

## Color schemes

`color_scheme(scheme)` tints every cell's background:

| Scheme | Effect |
|---|---|
| `NONE` (default) | No additional coloring — just `background_color` shows through |
| `RED`, `ORANGE`, `YELLOW`, `GREEN`, `BLUE`, `INDIGO`, `VIOLET`, `BROWN` | Every cell gets the same single tinted background |
| `CHECKERBOARD_RED`, `CHECKERBOARD_ORANGE`, `CHECKERBOARD_YELLOW`, `CHECKERBOARD_GREEN`, `CHECKERBOARD_BLUE`, `CHECKERBOARD_INDIGO`, `CHECKERBOARD_VIOLET`, `CHECKERBOARD_BROWN`, `CHECKERBOARD_GRAY` | Cells alternate between two shades of that hue, by row/col parity |
| `CHECKERBOARD` | Cells alternate between two shades of the theme's own brand colors |

## Label schemes

`label_scheme(scheme)` reserves a strip at the bottom of every filled cell for a short automatic label, numbered by row-major `add()` order and wrapped in parentheses:

| Scheme | Labels |
|---|---|
| `NONE` (default) | No labels |
| `LOWERCASE` | `(a)`, `(b)`, `(c)`, ... (up to 26 cells) |
| `UPPERCASE` | `(A)`, `(B)`, `(C)`, ... (up to 26 cells) |
| `NUMERIC` | `(1)`, `(2)`, `(3)`, ... |
| `ROMAN` | `(i)`, `(ii)`, `(iii)`, ... |

## Adding visualizations

`Gallery` accepts a `RelationDiagram` directly (and several other visualization types — see each visualization's own page for its `Gallery.add(...)` overload). To place any other visualization, or a picture you built yourself, render it to a picture first and add that:

```asy
TruthTable table = TruthTable();
table.add("p & q");
gallery.add_visual(table.render(4, 3, 1cm));
```
