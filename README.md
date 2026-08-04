# Maximum Mathematics

A comprehensive Asymptote library for creating professional mathematical diagrams and visualizations.

> This README is a short overview and install guide only. Full documentation — every visualization, every method, and plenty of examples — lives at the **[Maximum Mathematics website](https://jakeman582.github.io/Maximum-Asymptote/)**.

---

## Design philosophy

Every figure follows the same path:

1. **Create a visualization** and configure its data (constructor + fluent methods).
2. **Create an `Image`** and configure it with setter methods (size, padding, caption, background).
3. **Add the visualization to the image** with `image.add(visualization)`.

That last step **renders automatically** — you never call a render, draw, or output function yourself. There are no configuration structs and no wrapper types: you configure everything through setter methods on the object itself.

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

---

## Installation

This repository ships **only the Maximum Mathematics library files** — it does not install Asymptote, LaTeX, or anything else for you. You need a fully working Asymptote installation (2.70+) and a LaTeX distribution (used for mathematical notation) already set up on your system before this library does anything.

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

---

## Credits

Maximum Mathematics — created by Jacob Hiance.
