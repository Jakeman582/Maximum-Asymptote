---
title: Styling and typography
nav_order: 8
---

# Styling and typography

Global pens, colors, and typography are defined in `Theme/MaximumMathematicsTheme.asy` and shared by every visualization. `MaximumMathematics.asy` itself is just an aggregator — it includes the theme and every module, with no styling of its own. Swap in an alternate theme file to restyle the whole library without touching visualization code.

- **Brand colors:** `brand_color_1` (blue), `brand_color_2` (orange)
- **Table colors:** `table_variable_header_color`, `table_expression_header_color`, `table_variable_value_color`, `table_expression_value_color`, plus `table_expression_header_highlight_color`, `table_variable_value_highlight_color`, `table_highlight_color`, and the grid pens `outline_pen`/`table_minor_pen`
- **Graph colors:** `axis_color`, `grid_color`, `function_color_1`, `function_color_2` — `Plot` colors its functions via `plot_function_colors(n)`, which sweeps hue from red to violet in HSV space
- **Typography:** `header_1`, `header_2`, `header_3`, `text_large`, `text_normal`, `text_small` — plain `pen`s, usable anywhere a pen is expected (e.g. `header_2 + bold`)

Full Asymptote color and pen support is available for anything you pass to a setter (for example `img.background_color(rgb(0.98, 0.98, 1.0))`).

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
