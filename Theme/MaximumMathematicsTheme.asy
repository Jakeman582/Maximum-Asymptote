////////////////////////////////////////////////////////////////////////////////////////////////////
// File: MaximumMathematicsTheme.asy
//
// Description:
// Central aesthetic configuration for Maximum Mathematics: colors, pens, arrow styles, layout
// constants, and typography shared by every visualization. Swap in an alternate theme file to
// restyle the whole library without touching visualization code.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// Canvas
////////////////////////////////////////////////////////////////////////////////////////////////////

unitsize(1cm);  // Default picture unit for bare coordinates

////////////////////////////////////////////////////////////////////////////////////////////////////
// Color palette
////////////////////////////////////////////////////////////////////////////////////////////////////

// Main brand colors
pen brand_color_1 = RGB(0, 0, 255);    // Blue
pen brand_color_2 = RGB(255, 165, 0);  // Orange

// Figure colors
pen figure_background_color = white;

// Table colors
pen table_header = gray;
pen table_sub_header = mediumgray;

// Graphing colors
pen axis_color = black;
pen grid_color = mediumgray;
pen function_color_1 = brand_color_1;
pen function_color_2 = brand_color_2;
pen slope_color_1 = gray;
pen slope_color_2 = mediumgray;
pen fill_pen = opacity(0.18);
pen outline_pen = linewidth(0.6);

// Tree diagram colors
pen pruned_branch_color = RGB(255, 36, 0);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Plot color assignment
////////////////////////////////////////////////////////////////////////////////////////////////////

// The rainbow gradient sweeps hue from red (0 degrees) to violet (270 degrees) in HSV color space,
// at full saturation and brightness, so it naturally passes through orange, yellow, green, blue,
// and indigo along the way, giving the full ROYGBIV look.
real rainbow_hue_start = 0;    // Red
real rainbow_hue_end = 270;    // Violet

// HSV hue isn't perceptually uniform: human vision is far less sensitive to hue changes in the
// yellow-green-cyan region than near the spectrum's red or violet ends, so a plain linear sweep
// makes colors that land near green look almost identical even though they're evenly spaced in
// hue-degrees. Compensate by giving the green band a narrower slice of t than a linear mapping
// would (t in [green_t_start, green_t_end] still covers the full green_hue_start-green_hue_end
// span), and handing the freed-up t-budget to the two end bands — so evenly spaced t samples land
// on visually distinct colors even when several fall near the middle of the spectrum. The two
// endpoints (t=0 -> red, t=1 -> violet) are unchanged.
real green_hue_start = 90;
real green_hue_end = 150;
real green_t_start = 0.42;
real green_t_end = 0.58;

// Sample a color along the rainbow hue sweep at position t in [0, 1].
pen rainbow_color(real t) {
    real hue;
    if (t < green_t_start) {
        hue = rainbow_hue_start + (t / green_t_start) * (green_hue_start - rainbow_hue_start);
    } else if (t > green_t_end) {
        hue = green_hue_end + ((t - green_t_end) / (1 - green_t_end)) * (rainbow_hue_end - green_hue_end);
    } else {
        hue = green_hue_start + ((t - green_t_start) / (green_t_end - green_t_start)) * (green_hue_end - green_hue_start);
    }
    return hsv(hue, 1, 1);
}

// Colors for n functions on one Plot: divide the rainbow gradient into n zones and take each
// function's color from its zone's middle value.
pen[] plot_function_colors(int n) {
    pen[] colors;
    for (int k = 0; k < n; ++k) {
        real t = (k + 0.5) / n;
        colors.push(rainbow_color(t));
    }
    return colors;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Figure design
////////////////////////////////////////////////////////////////////////////////////////////////////

// Graphing/axis styling
pen axis_thickness = linewidth(1.5);
pen grid_thickness = linewidth(0.2);
arrowbar axis_arrow = ArcArrows(size = 4);
pen function_thickness = linewidth(1.2);
arrowbar function_arrow = ArcArrows(SimpleHead, size = 3);        // both ends (interior segments)
arrowbar function_begin_arrow = BeginArrow(SimpleHead, size = 3); // left end only
arrowbar function_end_arrow = EndArrow(SimpleHead, size = 3);     // right end only
real plot_endpoint_dot_radius = 0.08;  // Radius for OPEN_DOT/CLOSED_DOT curve endpoint markers

// Arrow/ray styling (used by RelationDiagram and other diagram types)
arrowbar ray_arrow = ArcArrow(size = 4);
pen ray_beginning = linewidth(4);

// General styling
pen label_size = fontsize(0.45cm);

// Diagram layout constants (used by RelationDiagram and other diagram types)
real set_boundary_margin = 0.5;  // Line margin from set boundaries
real diagram_unit = 1cm;  // Unit size for diagrams

// Zone layout constants (used by RelationDiagram and other diagram types)
real label_zone_height = 2.0;  // Fixed height for label zones
real element_zone_bottom_padding = 0.4;  // Padding at bottom to prevent label cutoff
real element_zone_top_padding = 0.55;  // Padding below horizontal line (one font height for text_normal)

// Arrow/relation drawing constants (used by RelationDiagram and other diagram types)
real arrow_offset_amount = 0.15;  // Base offset amount for overlapping arrow targets
real arrow_element_margin = 0.35;  // Margin from element labels for horizontal arrow segments
real arrow_horizontal_length_max = 0.5;  // Maximum horizontal line length for arrows
real arrow_horizontal_length_factor = 0.05;  // Horizontal line length as fraction of diagram width

////////////////////////////////////////////////////////////////////////////////////////////////////
// Typography
////////////////////////////////////////////////////////////////////////////////////////////////////

// Header sizes (larger than text for visual distinction) - using Helvetica Bold
pen header_1 = fontsize(1.2cm) + Helvetica("b");
pen header_2 = fontsize(1.0cm) + Helvetica("b");
pen header_3 = fontsize(0.8cm) + Helvetica("b");

// Text sizes - using Helvetica
pen text_large = fontsize(0.65cm) + Helvetica();
pen text_normal = fontsize(0.55cm) + Helvetica();
pen text_small = fontsize(0.45cm) + Helvetica();

////////////////////////////////////////////////////////////////////////////////////////////////////
// Math typography
////////////////////////////////////////////////////////////////////////////////////////////////////

// Math font is a document-wide LaTeX preamble setting, not a per-pen attribute, so it applies to
// every $...$ label regardless of which pen renders it. eulervm gives math a classic calligraphic
// look that contrasts with the sans-serif Helvetica body text above, and (unlike mathpazo/mathptmx)
// it leaves the default text roman font alone, so it can't clash with the Helvetica pens.
usepackage("eulervm");
