# Maximum Mathematics

A comprehensive Asymptote library for creating professional mathematical diagrams and visualizations.

> Development is active. Documentation is gradually moving to the Maximum Mathematics website, which is being reworked; this README is the current source of truth for the API.

---

## Design philosophy

Every figure follows the same path:

1. **Create a visualization** and configure its data (constructor + fluent methods).
2. **Create an `Image`** and configure it with setter methods (size, margins, padding, caption, background).
3. **Add the visualization to the image** with `image.add(visualization)`.

That last step **renders automatically** — you never call a render, draw, or output function yourself. The only exception is the escape hatch: if you want the bare visualization *without* an enclosing image, you call the visualization's own `render(width, height, unit)` directly (see [Standalone rendering](#standalone-rendering)).

```asy
import MaximumMathematics;

// 1. Create + configure a visualization
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});

// 2. Create + configure an image
Image img = Image();
img.set_diagram_padding(0.5);
img.caption_title("Figure 1:");
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

`Image` is the canvas your visualization is drawn into. Create it with a size (in centimeters) and configure it with setters.

```asy
Image img = Image();          // default 10 x 8
Image img = Image(14, 10);    // explicit width x height
```

Size can also be set after construction with `set_width(w)` / `set_height(h)`.

A visualization is laid out to **fill the image's content area** (the image size minus its padding). If the area is too small for the content, the visualization will be cramped — increase the width/height until it looks right. `set_debug_mode(true)` draws the zones and bounds to help you tune sizes.

### Configuration methods

| Concern | Methods |
|---|---|
| **Dimensions** | `set_width(w)`, `set_height(h)` (or pass to the constructor) |
| **Margins** (outside the canvas) | `set_margin(m)`, `set_margin_horizontal(m)`, `set_margin_vertical(m)`, `set_margin_left/right/top/bottom(m)` |
| **Diagram padding** (inside the canvas, around the visualization) | `set_diagram_padding(p)`, `set_diagram_padding_horizontal/vertical(p)`, `set_diagram_padding_left/right/top/bottom(p)` |
| **Caption padding** (inside the caption zone) | `set_caption_padding(p)`, `set_caption_padding_horizontal/vertical(p)`, `set_caption_padding_left/right/top/bottom(p)` |
| **Caption** | `caption_title(text)`, `caption_text(text)`, `set_caption_title_width_factor(f)` — the caption zone's height is auto-sized to fit its content |
| **Background** | `set_background_color(pen)` |
| **Debug** | `set_debug_mode(bool)` |
| **Add + render** | `add(visualization)` |

The more specific a setter, the higher its priority (CSS-like): `set_margin` sets all four sides, `set_margin_horizontal` overrides left+right, `set_margin_left` overrides just the left.

### Captions

A caption has two optional parts laid out side by side: a right-aligned **title** in a narrow left column and a left-aligned, word-wrapped **text** filling the rest.

```asy
Image img = Image(12, 8);
img.caption_title("Figure 2:");
img.caption_text("The distribution of outcomes across the sample space.");
img.add(diagram);
```

Provide only `caption_title`, only `caption_text`, or both. Provide neither and no caption zone is created. Both parts support LaTeX math.

The caption zone's height is **auto-sized** to exactly fit the current caption content — measured from the actual rendered title and text (including how many lines the text wraps into at the image's width), plus caption padding. The diagram zone always gets the remainder of the image height. There's no manual height to set or tune: change the caption text, the image width (which changes how the text wraps), or `set_caption_padding(p)` for breathing room, and the zone resizes itself accordingly.

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
img.set_diagram_padding(0.5);
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

Truth tables for boolean expressions. You give the variable names, the column labels, and one evaluator function per column. An evaluator receives a `bool[]` of the current row's variable values and returns the column's boolean result; the table generates all 2ⁿ rows for you.

```asy
string[] variables = {"p", "q"};
string[] column_labels = {"$\neg p$", "$p \land q$", "$\neg(p \land q)$"};

bool not_p(bool[] v)      { return !v[0]; }
bool p_and_q(bool[] v)    { return v[0] && v[1]; }
bool nand(bool[] v)       { return !(v[0] && v[1]); }

bool_array_function[] evaluators = {not_p, p_and_q, nand};

TruthTable table = TruthTable(variables, column_labels, evaluators);

Image img = Image(12, 6);
img.set_diagram_padding(0.5);
img.add(table);
```

| Method | Purpose |
|---|---|
| `TruthTable(variable_labels, column_labels, evaluators, title="Truth Table")` | Build the table |
| `set_title(title)` | Set the title |
| `set_debug_mode(bool)` | Draw bounds |

`bool_array_function` is the alias `bool(bool[])`.

### AccumulationTable

An iterative accumulation: starting from a seed, each row applies your function to the previous total. Columns are Step, Current Total, Change, and Next Total.

```asy
real compound(real x) { return x * 1.05; }   // 5% per period

AccumulationTable table = AccumulationTable(1000, 8, compound, "Compound Interest (5\%)");

Image img = Image(18, 9);
img.set_diagram_padding(0.5);
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

Image img = Image(10, 8);
img.set_diagram_padding(0.5);
img.caption_title("Figure 4:");
img.caption_text("$x^3$ and $x^2 + y^2 = 9$ on one Plot.");
img.add(p);
```

`add()` tells explicit from implicit apart by the function's own type — `cube` takes one `real`, so it's sampled along `x`; `circle` takes two, so its `f(x, y) = 0` curve is traced instead. Neither `add()` call above specifies a domain: by default a function is evaluated (or, for implicit, searched for) across the plot's own resolved window, since that already defines where you're looking in the xy-plane — no separate domain bookkeeping needed for the common case. See [Custom domains](#custom-domains) below for the rare case where a function genuinely needs a domain narrower or wider than the window.

| Method | Purpose |
|---|---|
| `Plot(x_min=-5, x_max=5)` | Build the plot; also the default window left/right (see below) |
| `add(f, color=AUTO_COLOR, type=SOLID, left_marker=AUTO, right_marker=AUTO, samples=200, x_min, x_max)` | Add an explicit function (`real_function_1`) |
| `add(f, color=AUTO_COLOR, type=SOLID, nx=100, ny=nx, x_min, x_max, y_min, y_max)` | Add an implicit function (`implicit_2`) |
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

Image img = Image(12, 6);
img.set_diagram_padding(0.5);
img.caption_title("Figure 3:");
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

---

## Galleries

`Gallery` arranges several visualizations in a grid. Each cell has the same visual size and an optional per-cell caption. Configure it with setters and add cells by `(row, col)` — like `Image`, the gallery **renders automatically** as you add to it, so you never call a render function yourself. Set gallery-wide options such as the caption last; they re-render the gallery to pick up the change.

The **visual width** and **visual height** describe the size of a single visual within the grid, not the size of the whole gallery. Every cell in the grid reserves the same box: `visual_width` is how wide each individual visual is, and `visual_height` is how tall each individual visual is. The overall gallery grows from these — its total size is the visuals laid out across `rows × cols`, plus the padding, margins, cell captions, and the gallery caption zone. You can set them in the constructor (`visual_width` / `visual_height`) or afterwards with `set_visual_width` / `set_visual_height`. Set them **before** adding visuals, since each visual is rendered to its stored size at the moment you call `add()`.

```asy
Gallery gallery = Gallery(1, 3, visual_width=4, visual_height=3);
gallery.set_margin(0.5);
gallery.set_padding(0.3);
gallery.set_caption_height(0.8);

RelationDiagram a = RelationDiagram();
a.add_set(new string[] {"1", "2"}, "A");
a.add_set(new string[] {"x", "y"}, "B");
a.add_relation(0, 1, new pair[] {(0,0), (1,1)});
gallery.add(a, 0, 0, "Figure 1: Injective");

// ... build diagrams b and c the same way ...
gallery.add(b, 0, 1, "Figure 2: Surjective");
gallery.add(c, 0, 2, "Figure 3: Bijective");

// Gallery-wide caption, set after the cells — this re-renders automatically.
gallery.caption_title("Figure 1:");
gallery.caption_text("Three kinds of relations between two sets.");
```

| Method | Purpose |
|---|---|
| `Gallery(rows, cols, visual_width=5, visual_height=4)` | Create the grid |
| `add(RelationDiagram, row, col, caption="")` | Place a relation diagram in a cell |
| `add(picture, row, col, caption="")` | Place any pre-rendered picture in a cell |
| `set_margin / set_padding(v)` | Grid spacing |
| `set_visual_width / set_visual_height(v)` | Size of each visual in a cell (set before `add`) |
| `set_caption_height / set_cell_caption_height(h)` | Caption zone heights |
| `caption_title / caption_text(text)` | Gallery-wide caption |
| `set_background_color(pen)`, `set_debug_mode(bool)` | Styling / debug |

`Gallery` accepts a `RelationDiagram` directly. To place any other visualization in a cell, render it to a picture first and add that picture:

```asy
TruthTable table = TruthTable(variables, column_labels, evaluators);
gallery.add(table.render(4, 3, 1cm), 0, 1, "Truth table");
```

---

## Standalone rendering

If you want a visualization on its own, without an enclosing `Image`, call its `render(width, height, unit)` and add the picture yourself. This is the one place you render explicitly.

```asy
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2"}, "A");
diagram.add_set(new string[] {"a", "b"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1)});

picture p = diagram.render(8, 6, 1cm);   // width, height (cm), unit
add(currentpicture, p);
```

Every visualization implements the same `render(width, height, unit)` contract and lays itself out to fill the given `width` x `height`.

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
- **Table colors:** `table_header`, `table_sub_header`
- **Graph colors:** `axis_color`, `grid_color`, `function_color_1`, `function_color_2` — `Plot` colors its functions via `plot_function_colors(n)`, which sweeps hue from red to violet in HSV space
- **Typography:** `header_1`, `header_2`, `header_3`, `text_large`, `text_normal`, `text_small` — plain `pen`s, usable anywhere a pen is expected (e.g. `header_2 + bold`)

Full Asymptote color and pen support is available for anything you pass to a setter (for example `img.set_background_color(rgb(0.98, 0.98, 1.0))`).

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
│   ├── Image.asy                 # Image: canvas, zones, captions, auto-render
│   └── Gallery.asy               # Gallery: grid layout
│
├── Visualizations/
│   ├── RelationDiagram.asy
│   ├── TruthTable.asy
│   ├── AccumulationTable.asy
│   ├── ContinuousPlot.asy        # Plot is a typedef alias for ContinuousPlot
│   └── DiscretePlot.asy
│
└── Examples/                     # Runnable examples, grouped by visualization
```

`import MaximumMathematics;` pulls in everything.

---

## Credits

Maximum Mathematics — created by Jacob Hiance.
