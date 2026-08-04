# Maximum Mathematics

A comprehensive Asymptote library for creating professional mathematical diagrams and visualizations.

> Development is active. Full documentation now lives at the [Maximum Mathematics website](https://jakeman582.github.io/Maximum-Asymptote/); this README remains a complete, single-page reference.

---

## Design philosophy

Every figure follows the same path:

1. **Create a visualization** and configure its data (constructor + fluent methods).
2. **Create an `Image`** and configure it with setter methods (size, padding, caption, background).
3. **Add the visualization to the image** with `image.add(visualization)`.

That last step **renders automatically** — you never call a render, draw, or output function yourself. The only exception is the escape hatch: if you want the bare visualization *without* an enclosing image, you call the visualization's own `render(width, height)` directly (see [Standalone rendering](#standalone-rendering)).

```asy
import MaximumMathematics;

// 1. Create + configure a visualization
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});

// 2. Create + configure an image
Image img = Image();
img.padding(0.5);
img.caption_title("Figure 1");
img.caption_text("A bijection between two sets.");

// 3. Add — this renders automatically
img.add(diagram);
```

There are no configuration structs and no wrapper types: you configure everything through setter methods on the object itself.

---

## Installation

Clone the repository anywhere you like:

```bash
git clone <repository-url> ~/.asy/Maximum-Asymptote
```

Asymptote doesn't search subfolders of `~/.asy`, so point your config file (`~/.asy/config.asy`) at the clone:

```asy
dir += "/absolute/path/to/Maximum-Asymptote";
```

Then import it in any `.asy` file:

```asy
import MaximumMathematics;
```

Update anytime with `git pull` — there is no separate build or install step.

**Requirements:** Asymptote 2.70+ and a LaTeX installation (used for mathematical notation).

---

## The `Image`

`Image` is the canvas your visualization is drawn into. Create it with a size (in centimeters) and configure it with fluent methods. `width`/`height` describe the visualization's own area only — a caption, if you add one, is stacked below that area and sized to fit its own content, rather than being carved out of the height you give it. See [Sizing](#sizing) below.

```asy
Image img = Image();   // default 10 x 8
```

Set an explicit size with `width(w)` / `height(h)`.

A visualization is laid out to **fill the visualization area** (the width/height you gave it, minus its padding), and is automatically **centered** within that area on both axes if it doesn't fill it exactly. If the area is too small for the content, the visualization will be cramped — increase the width/height until it looks right. `debug()` draws a border around the entire rendered picture, the visualization area's own border, and, when a caption is present, its zone/title separators, to help you tune sizes — call it after `add()`/`add_visual()`, since there's nothing to outline until the image has actually been rendered.

### Configuration methods

| Concern | Methods |
|---|---|
| **Dimensions** | `width(w)`, `height(h)` — the visualization area only, see [Sizing](#sizing) |
| **Padding** (around the visualization, inside its area) | `padding(p)` / `padding(h, v)` / `padding(l, t, r, b)`, `padding_horizontal/vertical(p)`, `padding_left/right/top/bottom(p)` |
| **Caption** | `caption_title(text)`, `caption_text(text)` — see [Captions](#captions) |
| **Background** | `background_color(pen)` |
| **Debug** | `debug()` |
| **Add + render** | `add(visualization)` |

`padding` is overloaded by argument count rather than needing separate per-side calls: the 1-argument form sets all four sides, the 2-argument form sets horizontal then vertical, and the 4-argument form sets left, top, right, and bottom independently. The `_horizontal`/`_vertical`/`_left`/`_right`/`_top`/`_bottom` methods are there for when you only want to override one axis or side without restating the rest.

### Sizing

`width`/`height` size the visualization area only. With no caption, that's also the size of the whole rendered picture. With one, the caption zone sits directly beneath the visualization area, spanning the same width, with its own height auto-sized to exactly fit its content (title, text, and however many lines the text wraps to) — so the whole rendered picture ends up `height` plus however tall the caption turns out to be, not just `height`. There's no caption height to tune: change the caption text or the image width (which changes how the text wraps) and the zone resizes itself accordingly.

### Captions

A caption has two optional parts, laid out as one line: a left-aligned **title**, and left-aligned, word-wrapped **text** immediately following it. When both are given, a colon and a space are inserted between them automatically — `caption_title("Figure 1")` + `caption_text("A basic sine curve.")` renders as "Figure 1: A basic sine curve.", so leave the colon out of the title yourself. A lone title or lone text (only one of the two given) is rendered as-is, flush with the caption zone's left edge.

```asy
Image img = Image();
img.width(12);
img.height(8);
img.caption_title("Figure 2");
img.caption_text("The distribution of outcomes across the sample space.");
img.add(diagram);
```

Provide only `caption_title`, only `caption_text`, or both. Provide neither and no caption zone is created. Both parts support LaTeX math. Wrapped continuation lines (once the text runs past the first line) stay indented under where the text started, rather than restarting at the caption zone's left edge underneath the title.

---

## Visualizations

Each visualization is created with a constructor, refined with fluent methods, and added to an `Image`. LaTeX math is supported in every label — use a **single** backslash in `.asy` strings (e.g. `"$\land$"`, not `"$\\land$"`).

### RelationDiagram

Functions, relations, and mappings between sets.

```asy
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_set(new string[] {"u", "v", "w"}, "C");

// Relations connect neighboring sets by element index: (source_index, target_index)
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});   // A -> B
diagram.add_relation(1, 2, new pair[] {(0,1), (1,2), (2,0)});   // B -> C

Image img = Image();
img.padding(0.5);
img.add(diagram);
```

| Method | Purpose |
|---|---|
| `RelationDiagram()` / `RelationDiagram(sets, names)` | Empty, or seeded with `string[][]` sets and `string[]` names |
| `add_set(elements, name="", width=0)` | Add one set (`width=0` auto-sizes) |
| `add_sets(sets, names={}, widths={})` | Add several sets at once |
| `set_width(set_index, width)` | Fix a set's width |
| `add_relation(from_set, to_set, pairs)` | Arrows between two sets, by element index |
| `set_debug_mode(bool)` | Draw zones and boundaries |

### TruthTable

Truth tables built up one boolean expression at a time. `add(expression)` parses a plain-text boolean expression string, and discovers any variable it hasn't already seen — there's no separate step to declare variables, and no need to write an evaluator function. Column headers render the expression back out as LaTeX, exactly as typed (`"!(p & q)"` renders as $\neg(p \land q)$, not some logically-equivalent rewrite); the table generates all 2ⁿ rows for you.

```asy
TruthTable table = TruthTable();
table.add("!p");
table.add("p & q");
table.add("!(p & q)");

Image img = Image();
img.width(12);
img.height(6);
img.padding(0.5);
img.add(table);
```

Expressions support parentheses and the operators `!` (not), `&` (and), `|` (or), `^` (xor), `->` (implies), and `<->` (iff), in that binding order (tightest to loosest) — e.g. `"p -> q & r"` parses as `p -> (q & r)`, and `"p | q ^ r"` parses as `(p | q) ^ r`.

Any cell can be highlighted for emphasis. `row` is always a 0-indexed data row; `column` is always a 0-indexed *expression* column (0 = the first `add()`ed expression) — variable columns are never individually targetable.

```asy
table.highlight_row(0);       // Every cell in row 0
table.highlight_column(1);    // The second expression's header and every one of its cells
table.highlight(2, 0);        // Just the (row 2, first expression) cell, plus row 2's propositions and column 0's header
```

| Method | Purpose |
|---|---|
| `TruthTable()` | Create an empty table |
| `add(expression)` | Parse and add one expression column, discovering any new variables |
| `highlight_row(row)` | Highlight every cell in a data row |
| `highlight_column(column)` | Highlight an expression column's header and every one of its cells |
| `highlight(row, column)` | Highlight one interior cell, that row's atomic-proposition cells, and that column's header; every other cell is unaffected |

### AccumulationTable

An iterative accumulation: starting from a seed, each row applies your function to the previous total. Columns are Step, Current Total, Change, and Next Total.

```asy
real compound(real x) { return x * 1.05; }   // 5% per period

AccumulationTable table = AccumulationTable(1000, 8, compound, "Compound Interest (5\%)");

Image img = Image();

img.width(18);

img.height(9);
img.padding(0.5);
img.add(table);
```

| Method | Purpose |
|---|---|
| `AccumulationTable(seed=0, steps=10, func=identity, title="Accumulation Table")` | Build the table |
| `set_title(title)` | Set the top header |
| `set_step_header / set_accum_header / set_change_header / set_next_total_header(label)` | Rename a column |
| `set_debug_mode(bool)` | Draw bounds |

`func` has type `real_function_1` (`real(real)`) and maps the current total to the next total.

### Plot

A standard continuous function graph — the smooth curve you'd see in a high-school or calc 1/2 class, as opposed to `DiscretePlot`'s discrete bars below. `Plot` draws both **explicit** functions (`y = f(x)`, sampled along `x` and connected point-to-point) and **implicit** functions (a relation `f(x, y) = 0`, traced with Asymptote's `contour` module) — mix as many of either kind as you like on one `Plot`, in the order you add them, by passing the function straight to `add()`. Colors are assigned automatically once every function is in place: the seven-color rainbow (ROYGBIV) gradient is divided into as many zones as there are functions (explicit and implicit together), and each function takes its zone's middle color.

`Plot` is a `typedef` alias for the underlying `ContinuousPlot` struct — the two names are fully interchangeable everywhere (variables, parameters, `Plot(...)`/`ContinuousPlot(...)` construction). Use whichever reads better; this doc uses `Plot`.

Define an explicit or implicit function the same way as any other Asymptote function — with the plain `real` return type, not a `real_function_1`/`implicit_2` alias (those aliases are for *parameter and variable* types, not for sugar-typing a function definition's return type):

```asy
real cube(real x) { return x*x*x; }                    // explicit — one real input, real_function_1
real circle(real x, real y) { return x*x + y*y - 9; }  // implicit — two real inputs, implicit_2

Plot p = Plot(-4, 4);
p.add(cube);
p.add(circle, color=red, type=DASHED);

Image img = Image();

img.width(10);

img.height(8);
img.padding(0.5);
img.caption_title("Figure 4");
img.caption_text("$x^3$ and $x^2 + y^2 = 9$ on one Plot.");
img.add(p);
```

`add()` tells explicit from implicit apart by the function's own type — `cube` takes one `real`, so it's sampled along `x`; `circle` takes two, so its `f(x, y) = 0` curve is traced instead. Neither `add()` call above specifies a domain: by default a function is evaluated (or, for implicit, searched for) across the plot's own resolved window, since that already defines where you're looking in the xy-plane — no separate domain bookkeeping needed for the common case. See [Custom domains](#custom-domains) below for the rare case where a function genuinely needs a domain narrower or wider than the window.

| Method | Purpose |
|---|---|
| `Plot(x_min=-5, x_max=5)` | Build the plot; also the default window left/right (see below) |
| `add(f, color=AUTO_COLOR, type=SOLID, label="", left_marker=AUTO, right_marker=AUTO, samples=200, x_min, x_max)` | Add an explicit function (`real_function_1`) |
| `add(f, color=AUTO_COLOR, type=SOLID, label="", nx=100, ny=nx, x_min, x_max, y_min, y_max)` | Add an implicit function (`implicit_2`) |
| `legend(height=0)` | Build a standalone legend picture (see below) |
| `set_window_left / set_window_right / set_window_bottom / set_window_top(real)` | Override one viewport edge |
| `set_window(left, right, bottom, top)` | Set all four viewport edges at once |
| `set_grid_delta_x / set_grid_delta_y(real)` | Change one grid spacing |
| `set_grid(delta_x=1, delta_y=1)` | Set both grid spacings and turn the grid on |
| `set_grid_mode(bool)` | Turn the grid on/off without changing its spacing |
| `set_margin_left / set_margin_right / set_margin_top / set_margin_bottom(real)` | Override one margin (default `1`) |
| `set_margins(real)` | Set all four margins to the same value |
| `set_margins(left, right, top, bottom)` | Set all four margins independently in one call |
| `set_debug_mode(bool)` | Draw bounds |

Field applicability of `add()`'s parameters:

| Parameter | Explicit | Implicit | Purpose |
|---|---|---|---|
| `color` | Yes | Yes | Curve color, or `AUTO_COLOR` to auto-assign from the rainbow palette |
| `type` | Yes | Yes | Line/dash style |
| `left_marker`, `right_marker` | Yes | N/A (not a parameter on the implicit overload) | What to draw at the curve's true left/right ends |
| `samples` | Yes | N/A | Points sampled across the domain — higher is smoother, slower |
| `nx`, `ny` | N/A | Yes | `contour()`'s search grid resolution — higher resolves thin/complex loops more accurately, slower |

The **window** (`left`/`right`/`bottom`/`top`) is the viewport: left/right default to `Plot`'s own `x_min`/`x_max`, and bottom/top are always auto-computed from the sampled y-values of explicit functions only (with padding) unless you override them.

**Colors.** By default every added function is auto-colored from the rainbow palette (see [Styling and typography](#styling-and-typography)). Pass any ordinary Asymptote pen — a named color, `RGB(...)`, `rgb(...)`, etc. — as `add()`'s `color` argument to color-coordinate a specific function instead:

```asy
Plot p = Plot(-3, 3);
p.add(f, color=red);  // f keeps exactly this color
p.add(g);              // g and h are auto-colored, dividing the rainbow between just the two of them
p.add(h);
```

An explicitly colored function is excluded from the rainbow's zone count entirely — the remaining auto-colored functions still spread across the full gradient among themselves, rather than losing a slot to a color they don't use. This applies uniformly to explicit and implicit functions on the same `Plot`.

**Line types.** Pass `type` on `add()` to set the curve's dash pattern — one of the constants below, or any other Asymptote linetype pen. `type` is independent of `color`, so you can set a line type on an auto-colored function without also having to pin down its color:

| Constant | Pattern |
|---|---|
| `SOLID` | Solid (default) |
| `DOTTED` | Dotted |
| `DASHED` | Dashed |
| `LONG_DASHED` | Long dashes |
| `DASH_DOTTED` | Dash-dot |
| `LONG_DASH_DOTTED` | Long dash-dot |

```asy
p.add(f, type=DASHED);                 // auto color, dashed
p.add(g, color=red, type=DOTTED);      // explicit color and type
```

**Always pass `color` and `type` by name (`color=...`, `type=...`).** They're both plain `pen` values in the same `add(f, color=AUTO_COLOR, type=SOLID, ...)` signature, so Asymptote can only tell them apart by position or by name — `color` is the first `pen` slot, so a bare positional pen always fills `color`, never `type`. Writing `p.add(f, DASHED)` intending "set the line type" actually sets `color=DASHED`, which silently renders as a solid black curve (`DASHED` carries no color of its own) rather than the dashed line you meant — no compile error, just the wrong picture. Naming both arguments sidesteps this entirely, in any order:

```asy
p.add(f, type=DASHED);                  // fine: only type given, named
p.add(f, DASHED);                        // WRONG: silently sets color, not type
p.add(f, type=DASHED, color=red);       // fine: order doesn't matter once named
```

The line type applies only to the curve itself — an explicit function's endpoint markers (dots, interval brackets) are always drawn with a solid outline regardless.

**Legend.** Pass `label` on `add()` to name a function; `legend(height=0)` then builds a standalone legend picture — one row per added function, in `add()` order, each row a single left-aligned unit: a `2`cm line-style sample in that function's actual color and dash pattern, a small gap, then its label (not two independently aligned columns). A function left unlabeled falls back to `"Function N"`, numbered by its `add()` order. Colors are resolved the same way `render()` resolves them (via the same underlying method), so the legend always matches whatever the plot itself actually draws, even for auto-colored functions. Rows are top-aligned: the first added function's row is topmost, with each subsequent row extending downward.

```asy
Plot p = Plot(-10, 10);
p.add(sin, color=blue, label="$\sin(x)$");
p.add(cos, label="$\cos(x)$");   // auto-colored — legend() still shows its resolved color

Image img = Image();

img.width(10);

img.height(10);
img.add(p);

Gallery g = Gallery(1, 2);
g.width(20);
g.height(10);
g.add_visual(img.pic);
g.add_visual(p.legend(10));      // legend() returns a plain picture, addable like any other
```

**Pass the same height you gave the Gallery/Image to `legend()`.** `Gallery.add_visual()` centers a picture within its cell rather than stretching it, so a legend sized only to its own content by default (`height=0`) ends up smaller than a full-size `Plot` picture and centers instead of lining up with it. Passing `legend()`'s `height` argument to match places the top row at the same margin-inset height the plot's own square top sits at (`height - margin_top`), so the two align.

Row spacing, the line sample's length, and the gap before the label are all theme constants (`legend_row_height`, `legend_line_length`, `legend_label_gap`).

**Layout.** The actual graph — axes, grid, curves — is drawn inside a **square**, inset from `Plot`'s own render area by a margin on each side (`set_margin_left/right/top/bottom`, or `set_margins` for all four at once; `1` by default). The square is the largest one that fits after the margins are subtracted, so nothing a `Plot` draws can ever land outside the area `Image` gave it — the margins exist specifically to hold tick labels, which always live outside the square, in the margin. Widen a margin if your tick labels are unusually wide and start crowding the edge. The square's border is drawn last, after every function — so a curve that runs right up to the window's edge sits underneath the border rather than drawn on top of it.

**Axes.** Tick marks and their number labels always sit at the square's own four edges — y-values on the left edge, x-values on the bottom edge, pointing outward into the margin — regardless of where the data axis itself happens to fall. Every tick gets a label, including `0`. A data axis line (arrow-tipped) is drawn only when its value actually falls inside the window — an all-positive window like `[5, 10]` gets no y-axis line at all, just the ordinary edge ticks — and when it is drawn, it also gets small crossing-ticks along it (unlabeled, since the edge already has labels), so it reads the same as a normal graph's interior axis. When both axes are visible, their true intersection additionally gets a single `"0"` label of its own, tucked diagonally into whichever quadrant encloses the least area — in addition to, not instead of, the ordinary edge labels.

**Grid.** Off by default. `set_grid(delta_x, delta_y)` turns it on and sets the spacing in one call — both default to `1`. Grid lines extend across the window, spaced out from `0` (or the window's edge, if `0` isn't in view) every `delta_x`/`delta_y`; a visible axis's own position isn't redrawn as a grid line. Always bounded by the window, so grid lines stay inside the square. Drawn in the theme's `grid_color`/`grid_thickness`, underneath the axes and curves.

```asy
Plot p = Plot(-3, 3);
p.add(square);
p.set_grid();              // spacing 1, 1
p.set_grid(0.5, 2);        // override: spacing 0.5 in x, 2 in y
p.set_grid_mode(false);    // turn it back off without losing the spacing
```

**Endpoint markers (explicit functions only).** A function's true leftmost and rightmost *visible* points — wherever the curve actually starts and ends, whether that's the domain edge, a window boundary, or a gap where the function is undefined (e.g. `log`/`sqrt` of a negative number) — get a marker, by default (`AUTO`) an arrowhead. Every other cut in between — an interior window-boundary crossing, or resuming after a gap partway through the domain — always draws with no marker, regardless of `left_marker`/`right_marker`; only the two true outermost ends are ever eligible for one. Override `left_marker`/`right_marker` on `add()` when `ARROW` isn't right for a specific function — e.g. a closed dot for `sqrt(x)` at `x=0`, since it's actually defined and finite there rather than continuing further:

| Constant | Left end | Right end |
|---|---|---|
| `ARROW` (default) | Arrow pointing left | Arrow pointing right |
| `OPEN_DOT` | Hollow circle | Hollow circle |
| `CLOSED_DOT` | Filled circle | Filled circle |
| `OPEN_INTERVAL` | `(` | `)` |
| `CLOSED_INTERVAL` | `[` | `]` |
| `NONE` | Nothing | Nothing |

```asy
Plot p = Plot(-2, 10);
p.add(sqrt, left_marker=CLOSED_DOT);  // sqrt(0)=0 is defined, unlike AUTO's default arrow implies
```

These only apply to a function's overall first and last visible point. Any other cut in the middle of the curve — a window-boundary crossing, or resuming after an internal gap — always uses the ordinary `AUTO` behavior regardless of what you pass here. None of this applies to implicit functions; `left_marker`/`right_marker` aren't even parameters on the implicit `add()` overload.

An `ARROW`-marked end has its curve trimmed back by the theme's `plot_arrow_trim` (`0.1` by default) before drawing, so the arrowhead sits fully inside the window rather than its tip landing exactly on — or poking through — the viewing window's border. This applies regardless of which edge caused the cut (a window boundary, the domain edge, or a NaN gap); `OPEN_DOT`/`CLOSED_DOT`/interval markers are unaffected and stay exactly at the true endpoint.

**Implicit functions.** An implicit function is a relation `f(x, y) = 0` rather than a `y = f(x)` you can sample along `x` — a circle (`x^2 + y^2 - 9 = 0`), for instance, isn't a function of `x` at all in the usual sense. `Plot` traces the curve using Asymptote's `contour` module: it searches a box (the window by default) on a grid (`nx` columns by `ny` rows) for where `f` crosses zero, and connects the crossings into one or more paths — which may be closed loops (like a circle), open curves clipped by the box's edges, or several disconnected pieces, depending on the relation. Because of that, an implicit curve has no equivalent of an explicit function's "true left/right end," so it gets no endpoint markers; increase `nx`/`ny` (via `add()`) if a curve's finer features (thin loops, sharp turns) look faceted at the default resolution.

```asy
real circle(real x, real y) { return x*x + y*y - 9; }

Plot p = Plot(-4, 4);
p.set_window(-4, 4, -4, 4);
p.add(circle, color=red, nx=150, ny=150);  // finer grid for a smoother-looking circle
```

#### Custom domains

`add()` always defers to the plot's own window by default. When a function genuinely needs a domain narrower (or wider) than that — `sqrt` starting at `x = 0` even though the window extends further negative, say — pass `x_min`/`x_max` (and, for implicit, `y_min`/`y_max`) directly on that `add()` call:

```asy
Plot p = Plot(-2, 10);
p.add(sqrt, x_min=0, x_max=10, left_marker=CLOSED_DOT);   // evaluated over [0, 10], regardless of the window
```

```asy
real circle(real x, real y) { return x*x + y*y - 9; }

Plot p = Plot(-10, 10);
p.add(circle, x_min=-5, x_max=5, y_min=-5, y_max=5);   // searched only in [-5,5]x[-5,5], not the full window
```

Every bound is independent and optional — set only the ones you need; the rest keep deferring to the window. There's no separate object to build: the domain lives on the same `add()` call as everything else, on a per-function basis, independent of the window and independent of every other function on the same `Plot`.

Don't confuse this with `Plot`'s own `x_min`/`x_max` (set at construction, via `Plot(x_min, x_max)`): that's only the *default* for the window's left/right edge when you haven't called `set_window_left`/`set_window_right` — a per-`Plot` setting, not a per-function one.

#### Predefined function types

Rather than writing your own implicit relation for common shapes, `Utilities/Functions/` provides ready-made ones. `Line` is the first: a general line in standard form `a*x + b*y + c = 0`, which — unlike slope-intercept form — represents a vertical line just as naturally as a horizontal or slanted one, since it never divides by anything. `as_implicit()` exposes it as an `implicit_2`, which `add()` accepts directly like any other implicit function:

```asy
Line l = vertical_line(5);   // or horizontal_line(y0), line_from_slope_intercept(m, b), line_from_two_points(p1, p2)

Plot p = Plot(-10, 10);
p.add(l.as_implicit(), color=blue);
```

| Constructor | Builds |
|---|---|
| `Line(a, b, c)` | The line `a*x + b*y + c = 0` directly |
| `vertical_line(x0)` | The vertical line `x = x0` |
| `horizontal_line(y0)` | The horizontal line `y = y0` |
| `line_from_slope_intercept(slope, y_intercept)` | `y = slope*x + y_intercept` (cannot express a vertical line — use `vertical_line` for that) |
| `line_from_two_points(p1, p2)` | The line through two points, vertical or horizontal included |

| Method | Purpose |
|---|---|
| `evaluate(x, y)` | `a*x + b*y + c` — zero exactly on the line, nonzero (sign indicates which side) elsewhere |
| `as_implicit()` | This line as an `implicit_2` closure, addable to `Plot` directly |

`Conic` is the second: a general conic section in standard form `A*x^2 + B*y^2 + C*x*y + D*x + E*y + F = 0` — one form covering circles, ellipses, parabolas, and hyperbolas alike, depending on the coefficients:

```asy
Conic circle = Conic(1, 1, 0, 0, 0, -9);       // x^2 + y^2 - 9 = 0, a circle of radius 3
Conic hyperbola = Conic(1, -1, 0, 0, 0, -1);   // x^2 - y^2 - 1 = 0

Plot p = Plot(-10, 10);
p.add(circle.as_implicit(), color=blue);
```

| Constructor | Builds |
|---|---|
| `Conic(A, B, C, D, E, F)` | The conic `A*x^2 + B*y^2 + C*x*y + D*x + E*y + F = 0` directly |
| `conic_circle(center_x, center_y, radius)` | A circle |
| `conic_ellipse(center_x, center_y, radius_x, radius_y)` | An axis-aligned ellipse |
| `conic_hyperbola(center_x, center_y, radius_x, radius_y, orientation=HORIZONTAL)` | An axis-aligned hyperbola |
| `conic_parabola(center_x, center_y, scale, orientation=VERTICAL)` | A parabola, from its vertex |

These are named with a `conic_` prefix rather than plain `circle`/`ellipse`, since Asymptote's own plain library already defines `circle(pair, real)` and `ellipse(pair, real, real)` as path constructors — different signatures, but the same bare names would read as if they did the same thing.

`orientation` (for `conic_hyperbola`/`conic_parabola`) is `HORIZONTAL` or `VERTICAL`, describing which axis the conic is symmetric about — `HORIZONTAL` opens left-right, `VERTICAL` opens up-down (the familiar `y = x^2` shape, and `conic_parabola`'s default).

`conic_parabola` expresses the parabola in vertex form, with `h = center_x`, `k = center_y`, `a = scale`:

| `orientation` | Equation | Opens |
|---|---|---|
| `VERTICAL` (default) | `y = a(x - h)^2 + k` | Up if `a > 0`, down if `a < 0` |
| `HORIZONTAL` | `x = a(y - h)^2 + k` | Right if `a > 0`, left if `a < 0` |

`(center_x, center_y)` is the vertex `(h, k)`; `scale` (`a`) is that equation's leading coefficient — larger magnitude means a narrower parabola.

```asy
Conic c = conic_circle(0, 0, 3);                    // x^2 + y^2 = 9
Conic h = conic_hyperbola(0, 0, 2, 3, VERTICAL);    // opens up-down
Conic p = conic_parabola(0, 1, 0.5);                // vertex (0,1), y - 1 = 0.5*x^2, opens upward

Plot plot = Plot(-10, 10);
plot.add(p.as_implicit(), color=blue);
```

| Method | Purpose |
|---|---|
| `evaluate(x, y)` | `A*x^2 + B*y^2 + C*x*y + D*x + E*y + F` — zero exactly on the conic, nonzero elsewhere |
| `as_implicit()` | This conic as an `implicit_2` closure, addable to `Plot` directly |

### DiscretePlot

A discrete step/bar plot sampling a function at the left, middle, or right of each interval — useful for Riemann-sum and accumulation illustrations.

```asy
real value(real x) { return 1000 * exp(log(1.05) * x); }

DiscretePlot g = DiscretePlot(1, 0, "left", 8, value);
g.set_window(-0.5, 8.5, 0, 0);   // ymin == ymax => auto-compute the y-window

Image img = Image();

img.width(12);

img.height(6);
img.padding(0.5);
img.caption_title("Figure 3");
img.caption_text("Discrete accumulation, sampled per period.");
img.add(g);
```

| Method | Purpose |
|---|---|
| `DiscretePlot(dx=1, first_x=0, anchor="left", steps=10, func=identity, xmin=0, xmax=0, ymin=0, ymax=0)` | Build and sample |
| `set_dx / set_first_x / set_steps(...)` | Change sampling geometry |
| `set_anchor("left"\|"mid"\|"right")` | Where each interval is sampled |
| `set_function(func)` | Replace the function and re-sample |
| `set_window(xmin, xmax, ymin, ymax)` | Set the view (equal min==max leaves that axis auto) |
| `set_debug_mode(bool)` | Draw bounds |

### SwitchingNetwork

Draws a boolean expression as a switching (relay) network: a conjunction (`&`) becomes two sub-networks in **series** (current must pass through both), a disjunction (`|`) becomes two sub-networks in **parallel** (current can pass through either), and a variable — negated or not — becomes a single switch. Built from one expression string in a single-shot constructor:

```asy
SwitchingNetwork sn = SwitchingNetwork("(A & B) | (!A & C)");

Image img = Image();

img.width(10);

img.height(6);
img.padding(0.5);
img.caption_title("Figure");
img.caption_text("$(A \wedge B) \vee (\bar{A} \wedge C)$, a two-way multiplexer.");
img.add(sn);
```

| Method | Purpose |
|---|---|
| `SwitchingNetwork(expression)` | Parse the expression and build the network |
| `set_debug_mode(bool)` | Draw bounds |

**Expression syntax** is programmer-style, not LaTeX — variables are plain identifiers, and operators are ASCII symbols:

| Symbol | Meaning | Precedence |
|---|---|---|
| `!` | Negation | Tightest — binds before `&` and `|` |
| `&` | Conjunction (AND) | Binds before `|` |
| `\|` | Disjunction (OR) | Loosest |
| `( )` | Grouping | Overrides the above |

So `A & B | C` means `(A & B) | C`, and `!A & B` means `(!A) & B` — use parentheses whenever you mean something other than that. A negated variable is drawn with a bar over its label (e.g. `!A` renders as $\bar{A}$); the expression is converted to negation normal form internally (via De Morgan's laws) before layout, so `!(A & B)` draws identically to `!A | !B` — a real switching network can only negate a single variable's own switch, not an entire sub-network, so this conversion is what makes an expression like `!(A & B)` renderable at all.

The whole network is uniformly scaled (preserving its proportions, centered) to fit the given width/height, the same letterboxing approach `Plot` uses. A short lead wire extends from each side of the network out to a filled terminal dot, marking its two overall connection points. Row spacing, switch size, lead-wire length, and terminal dot size are theme constants (`switch_unit_width`, `switch_unit_height`, `switch_parallel_spacing`, `switch_tick_height`, `switch_lead_length`, `switch_terminal_radius`, `switch_thickness`).

### GraphDiagram

A graph-theory diagram — vertices and edges — where **you never supply a coordinate**. Give it a vertex set and an edge set, and the library computes every position:

```asy
Graph g = Graph();
g.add_edge("A", "B");
g.add_edge("B", "C");
g.add_edge("C", "A");

Image img = Image();

img.width(8);

img.height(8);
img.add(g);
```

That's a complete figure. `add_edge` creates either endpoint the first time it's named, so a graph can be specified purely as an edge list — `add_vertex` is only needed for an isolated vertex with no edges. `Graph` is a `typedef` alias for `GraphDiagram`, the same way `Plot` aliases `ContinuousPlot`.

| Method | Purpose |
|---|---|
| `Graph()` | Build an empty graph |
| `add_vertex(label)` | Add a vertex (only needed for isolated vertices) |
| `add_edge(from_label, to_label, label="")` | Add an edge, creating either endpoint if new; `label` is a weight/annotation |
| `set_directed(bool)` | Draw arrowheads on every edge |
| `set_layout(layout)` | Choose the placement algorithm (see below) |
| `set_root(label)` | `TREE` only — which vertex goes on top |
| `set_source(label)` | `LAYERED` only — which vertex goes in the leftmost layer |
| `set_grid_dimensions(rows, cols)` | `GRID` only — leave either `0` to derive it |
| `set_outer_face(labels)` | `PLANAR` only — the outer face, in cyclic order |
| `set_seed(int)` | `RANDOM` only — which scatter to produce |
| `get_seed()` | `RANDOM` only — the seed currently in effect |
| `set_seed_from_time()` | `RANDOM` only — seed from the system clock instead, for a different scatter each render |
| `set_uniform_vertex_size(bool)` | Draw every vertex at the same size instead of auto-widening each to fit its own label |
| `set_avoid_vertex_overlap(bool)` | Curve an edge around an unrelated vertex it would otherwise pass close to (on by default) |
| `set_debug_mode(bool)` | Draw bounds |

**Layouts.** `set_layout` takes one of eight constants. Most need nothing but the edges:

| Constant | Needs only V+E? | Best for |
|---|---|---|
| `FORCE` (default) | Yes | General graphs |
| `CIRCULAR` | Yes | Cycles/circuits, complete graphs, small graphs |
| `BIPARTITE` | Yes — the 2-coloring is computed for you | Bipartite graphs, matchings |
| `TREE` | Yes — root defaults to the first vertex | Trees, hierarchies |
| `LAYERED` | Yes — source defaults to the first vertex | Flow networks |
| `GRID` | Yes — dimensions derived from the vertex count | Lattices, meshes |
| `RANDOM` | Yes — ignores edges entirely | Showing that a drawing isn't unique |
| `PLANAR` | No — needs `set_outer_face` | Crossing-free planar drawings |

`FORCE` is Fruchterman–Reingold: vertices repel like charged particles, edges pull like springs, and the system cools to equilibrium. It's seeded from a circle rather than a random scatter, so **the same graph always renders identically** — a figure won't shift between builds of the same document.

`PLANAR` is Tutte's spring embedding, the one genuinely topological algorithm here: pin the outer face to a polygon, then repeatedly move every interior vertex to the average of its neighbors. For a 3-connected planar graph this provably produces a drawing with **no crossing edges**. It's also the only layout that can't run from the edge list alone, since the guarantee depends on knowing which face is outermost.

`RANDOM` is the odd one out: it ignores the edges entirely and scatters the vertices across an *n*×*n* lattice (*n* = the vertex count), sampling without replacement so no two ever collide. The first four vertices are pinned one to each side of the lattice, which is what makes the scatter fill its box — those four alone force the bounding box to span the whole lattice, so the result scales up to the full area instead of huddling wherever sampling happened to land. It's useful for showing a class that a graph's drawing is not unique.

Despite the name it is **not** unstable between renders: the scatter is seeded, so a given seed always reproduces the same picture. Pass `set_seed(n)` to pick a different arrangement — changing the seed is what changes the layout, not re-running the file. (`FORCE` gives the same guarantee for the same reason, seeding its relaxation from a circle rather than a random scatter, so a figure never shifts between builds of an unchanged document.)

If you actually want a different scatter on every render — e.g. browsing a few arrangements before picking one — call `set_seed_from_time()` instead of `set_seed(n)`. It seeds from the system clock, deliberately trading away the reproducibility guarantee above; call `get_seed()` afterward to read off whatever seed you land on, and pin it down with `set_seed(that_value)` once you've found one worth keeping.

```asy
Graph g = Graph();
g.add_edge("A", "B");
g.add_edge("B", "C");
g.set_layout(RANDOM);
g.set_seed(7);        // a different arrangement; still identical on every render
```

Two layouts can fail on a graph that doesn't support them, and both fail loudly rather than drawing something misleading: `BIPARTITE` on a graph with an odd cycle, and `PLANAR` without an outer face of at least 3 vertices.

**Edge features.** Directed edges, weights, self-loops, and parallel edges all work together:

```asy
Graph network = Graph();
network.set_directed(true);
network.set_layout(LAYERED);
network.set_source("s");

network.add_edge("s", "a", "16");   // labeled with a capacity
network.add_edge("s", "b", "13");
network.add_edge("a", "b", "4");
network.add_edge("a", "b", "9");    // parallel edge — bowed apart from its sibling
network.add_edge("b", "b", "loop"); // self-loop — drawn as a loop at the vertex
network.add_edge("b", "t", "20");
```

Parallel edges between the same pair are bowed symmetrically about the straight line between them so each stays visible; for an undirected graph `A→B` and `B→A` count as the same pair, while for a directed one they're opposite arcs and stay separate. Multiple self-loops at one vertex are rotated around it. Edges stop at each vertex's rim rather than its center, which is what puts a directed edge's arrowhead against the circle instead of hidden underneath it. Vertex circles auto-widen to fit their own labels, so a multi-character name doesn't overflow — call `set_uniform_vertex_size(true)` if you'd rather every circle be the same size (fit to the widest label) even when names vary in length, e.g. a tree mixing `"L"` with `"LA1"`.

A straight edge that would otherwise pass close enough to an unrelated vertex to read as if that vertex were connected too curves around it instead — on by default, and a no-op whenever nothing is actually in the way, so it never changes a diagram that didn't need it. Turn it off with `set_avoid_vertex_overlap(false)` if a particular curve looks worse than the straight line it's avoiding. This is a heuristic, not a general-purpose router: it only reroutes around one vertex at a time (the worst offender, if several are close), and it isn't aware of other edges, only vertices.

Styling lives in the theme: `graph_vertex_fill`, `graph_vertex_outline`, `graph_vertex_radius`, `graph_edge_color`, `graph_edge_thickness`, `graph_directed_arrow`, `graph_edge_label_offset`, `graph_multi_edge_bow`, `graph_edge_vertex_clearance`, `graph_self_loop_size`, `graph_self_loop_angle`, `graph_layout_margin`, `graph_force_iterations`, and `graph_random_seed`.

---

## Galleries

`Gallery` arranges several visualizations in a grid. `width`/`height` describe the grid's own area only — a gallery-wide caption, if you add one, is stacked below that area rather than being carved out of it, the same as `Image`. Visualizations are added one at a time with `add(visualization)`: the gallery places each one in row-major order — row 0 left to right, then row 1, and so on — starting at the top left. There's no way to target a specific cell; this keeps the API to one method with no parameters to get wrong. Like `Image`, the gallery **renders automatically** as you add to it, so you never call a render function yourself.

```asy
Gallery gallery = Gallery(1, 3);   // 1 row, 3 columns -- required, fixed for the gallery's life
gallery.width(15);
gallery.height(4);
gallery.padding(0.3);
gallery.margin(0.2);
gallery.label_scheme(LOWERCASE);

RelationDiagram a = RelationDiagram();
a.add_set(new string[] {"1", "2"}, "A");
a.add_set(new string[] {"x", "y"}, "B");
a.add_relation(0, 1, new pair[] {(0,0), (1,1)});
gallery.add(a);   // (a) -- top-left

// ... build diagrams b and c the same way ...
gallery.add(b);   // (b)
gallery.add(c);   // (c)

// Gallery-wide caption, set after the cells -- this re-renders automatically.
gallery.caption_title("Figure 1");
gallery.caption_text("Three kinds of relations between two sets.");
```

| Method | Purpose |
|---|---|
| `Gallery(rows, cols)` | Create the grid (required, fixed for the gallery's lifetime) |
| `width(w)`, `height(h)` | Size of the grid area only (default `20 x 8`) — see `Image`'s sizing model |
| `padding(...)`, `padding_horizontal/vertical/left/top/right/bottom(v)` | Space around the grid, same overloads as `Image`'s `padding` |
| `margin(v)` | Space **between** adjacent cells only — never at the grid's outer boundary, which `padding` governs |
| `background_color(pen)` | Overall background of the whole rendered picture |
| `caption_title / caption_text(text)` | Gallery-wide caption, below the grid |
| `color_scheme(scheme)` | Per-cell background tint — see below |
| `label_scheme(scheme)` | Per-cell `(a)`/`(A)`/`(1)`/`(i)` labels — see below |
| `debug()` | Draw grid/cell/caption boundaries |
| `add(visualization)` | Place the next visualization in row-major order |
| `add_visual(picture)` | Place a raw picture in row-major order |

`color_scheme` accepts `NONE` (default — just `background_color`), one of `RED`/`ORANGE`/`YELLOW`/`GREEN`/`BLUE`/`INDIGO`/`VIOLET`/`BROWN` for a single tinted background across every cell, one of `CHECKERBOARD_RED`/`..._ORANGE`/`..._YELLOW`/`..._GREEN`/`..._BLUE`/`..._INDIGO`/`..._VIOLET`/`..._BROWN`/`..._GRAY` for two shades of that hue alternating by cell, or plain `CHECKERBOARD` for an alternating pair of the theme's own brand colors.

`label_scheme` accepts `NONE` (default — no labels), `LOWERCASE`/`UPPERCASE` (`(a)`.../`(A)`...), `NUMERIC` (`(1)`...), or `ROMAN` (`(i)`...) — each numbered by row-major `add()` order, reserving a strip at the bottom of every cell sized to fit the label.

`Gallery` accepts a `RelationDiagram` directly (and several other visualization types — see each visualization's own page for its `Gallery.add(...)` overload). To place any other visualization in a cell, render it to a picture first and add that picture:

```asy
TruthTable table = TruthTable();
table.add("p & q");
gallery.add_visual(table.render(4, 3, 1cm));
```

---

## Standalone rendering

If you want a visualization on its own, without an enclosing `Image`, call its `render(width, height, unit=diagram_unit)` and add the picture yourself. This is the one place you render explicitly.

```asy
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2"}, "A");
diagram.add_set(new string[] {"a", "b"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1)});

picture p = diagram.render(8, 6);   // width, height (cm) — unit defaults to the theme's diagram_unit
add(currentpicture, p);
```

Every visualization implements the same `render(width, height, unit=diagram_unit)` contract and lays itself out to fill the given `width` x `height`. `unit` is only there to override the scale for this one call — pass it explicitly (e.g. `render(8, 6, 2cm)`) if you need a picture at a different scale than the rest of your figures; otherwise there's nothing to specify.

---

## Output and viewing

The library does not override your output format. Choose one the standard Asymptote way:

```asy
settings.outformat = "svg";   // or "pdf", "eps", "png"
```

```bash
asy mydiagram.asy            # uses your configured format
asy -f svg mydiagram.asy     # force SVG
```

**Tip:** if you rasterize the SVG output to PNG to preview it, use a WebKit-based tool (e.g. `qlmanage` on macOS) or a browser. ImageMagick does not resolve the glyph references in Asymptote's SVG and will drop characters, making a correct figure look broken.

---

## Styling and typography

Global pens, colors, and typography are defined in `Theme/MaximumMathematicsTheme.asy` and shared by every visualization. `MaximumMathematics.asy` itself is just an aggregator — it includes the theme and every module, with no styling of its own. Swap in an alternate theme file to restyle the whole library without touching visualization code.

- **Brand colors:** `brand_color_1` (blue), `brand_color_2` (orange)
- **Table colors:** `table_variable_header_color`, `table_expression_header_color`, `table_variable_value_color`, `table_expression_value_color`, plus `table_expression_header_highlight_color`, `table_variable_value_highlight_color`, `table_highlight_color`, and the grid pens `outline_pen`/`table_minor_pen`
- **Graph colors:** `axis_color`, `grid_color`, `function_color_1`, `function_color_2` — `Plot` colors its functions via `plot_function_colors(n)`, which sweeps hue from red to violet in HSV space
- **Typography:** `header_1`, `header_2`, `header_3`, `text_large`, `text_normal`, `text_small` — plain `pen`s, usable anywhere a pen is expected (e.g. `header_2 + bold`)

Full Asymptote color and pen support is available for anything you pass to a setter (for example `img.background_color(rgb(0.98, 0.98, 1.0))`).

---

## Project structure

```
Maximum-Asymptote/
├── MaximumMathematics.asy        # Entry point: includes the theme and every module
│
├── Theme/
│   └── MaximumMathematicsTheme.asy  # Colors, pens, layout constants, typography
│
├── Utilities/
│   ├── TextWrapping.asy          # Caption/text wrapping
│   ├── TextMeasurement.asy       # True (LaTeX) text size measurement
│   ├── TextSetWidth.asy          # Set-width helpers
│   ├── FunctionTypes.asy         # Function type aliases (real_function_1, ...)
│   ├── Functions/
│   │   ├── Line.asy               # Line: predefined general line (a*x + b*y + c = 0), implicit_2-ready
│   │   └── Conic.asy              # Conic: predefined general conic section, implicit_2-ready
│   ├── DefaultFunctions.asy      # identity, square
│   ├── AxisTicks.asy             # Shared tick computation (Plot, DiscretePlot)
│   ├── BooleanExpression.asy     # Boolean expression parser + NNF normalizer, used by SwitchingNetwork
│   ├── GraphLayout.asy           # Vertex-placement algorithms, used by GraphDiagram
│   ├── Image.asy                 # Image: canvas, zones, captions, auto-render
│   └── Gallery.asy               # Gallery: grid layout
│
├── Visualizations/
│   ├── RelationDiagram.asy
│   ├── TruthTable.asy
│   ├── AccumulationTable.asy
│   ├── ContinuousPlot.asy        # Plot is a typedef alias for ContinuousPlot
│   ├── DiscretePlot.asy
│   ├── SwitchingNetwork.asy
│   └── GraphDiagram.asy          # Graph is a typedef alias for GraphDiagram
│
└── Examples/                     # Runnable examples, grouped by visualization
```

`import MaximumMathematics;` pulls in everything.

---

## Credits

Maximum Mathematics — created by Jacob Hiance.
