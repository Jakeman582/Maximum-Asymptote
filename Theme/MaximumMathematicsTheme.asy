////////////////////////////////////////////////////////////////////////////////////////////////////
// File: MaximumMathematicsTheme.asy
//
// Description:
// Central aesthetic configuration for Maximum Mathematics: colors, pens, arrow styles, layout
// constants, and typography shared by every visualization. Swap in an alternate theme file to
// restyle the whole library without touching visualization code.
//
// Organized top to bottom: general settings that apply across every visualization come first
// (color palette, typography), followed by one section per visualization (or family of closely
// related visualizations) for settings specific to it.
//
// This file only declares configuration — it never mutates currentpicture or any other global
// drawing state (e.g. no bare unitsize() call). Every picture this library actually draws into
// (Image's and Gallery's own pictures) sets its own unit explicitly, from diagram_unit below.
////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////
// General
////////////////////////////////////////////////////////////////////////////////////////////////////

// Brand colors
pen brand_color_1 = RGB(0, 0, 255);    // Blue
pen brand_color_2 = RGB(255, 165, 0);  // Orange

// Core palette — shared across multiple visualizations, or reserved for future use
pen figure_background_color = white;
pen function_color_1 = brand_color_1;
pen function_color_2 = brand_color_2;
pen slope_color_1 = gray;
pen slope_color_2 = mediumgray;
pen fill_pen = opacity(0.18);
pen outline_pen = linewidth(0.6);
pen pruned_branch_color = RGB(255, 36, 0);

// Header sizes (larger than text for visual distinction) - using Helvetica Bold
pen header_1 = fontsize(1.2cm) + Helvetica("b");
pen header_2 = fontsize(1.0cm) + Helvetica("b");
pen header_3 = fontsize(0.8cm) + Helvetica("b");

// Text sizes - using Helvetica
pen text_large = fontsize(0.65cm) + Helvetica();
pen text_normal = fontsize(0.55cm) + Helvetica();
pen text_small = fontsize(0.45cm) + Helvetica();

pen label_size = fontsize(0.45cm);

real caption_line_leading = 1.15;  // Multiplier on a caption line's rendered height to get the spacing between wrapped lines; above 1 leaves visible leading, below 1 would overlap

// Math font is a document-wide LaTeX preamble setting, not a per-pen attribute, so it applies to
// every $...$ label regardless of which pen renders it. eulervm gives math a classic calligraphic
// look that contrasts with the sans-serif Helvetica body text above, and (unlike mathpazo/mathptmx)
// it leaves the default text roman font alone, so it can't clash with the Helvetica pens.
usepackage("eulervm");

real diagram_unit = 1cm;  // Unit size for rendering any diagram

////////////////////////////////////////////////////////////////////////////////////////////////////
// Graphing (Plot, DiscretePlot)
////////////////////////////////////////////////////////////////////////////////////////////////////

// Axis styling shared by both graphing visualizations
pen axis_color = black;
pen axis_thickness = linewidth(1.5);
arrowbar axis_arrow = ArcArrows(size = 4);

////////////////////////////////////////////////////////////////////////////////////////////////////
// Plot
////////////////////////////////////////////////////////////////////////////////////////////////////

// Grid and function line styling
pen grid_color = mediumgray;
pen grid_thickness = linewidth(0.2);
pen function_thickness = linewidth(1.2);
arrowbar function_arrow = ArcArrows(SimpleHead, size = 3);         // Both ends (interior segments)
arrowbar function_begin_arrow = BeginArrow(SimpleHead, size = 3);  // Left end only
arrowbar function_end_arrow = EndArrow(SimpleHead, size = 3);      // Right end only

// Endpoint markers, arrow trimming, and tick layout
real plot_endpoint_dot_radius = 0.08;  // Radius for OPEN_DOT/CLOSED_DOT curve endpoint markers
real plot_arrow_trim = 0.1;            // Distance a curve is trimmed back from an ARROW-marked end, so the arrowhead doesn't visually overlap the viewing window's border
real plot_tick_length = 0.15;          // Full length of a tick mark: edge ticks extend this far outward into the margin; interior axis-crossing ticks extend half this far on each side of the axis line
real plot_tick_label_gap = 0.1;        // Gap between a tick mark's outer end and its label

// The rainbow gradient sweeps hue from red (0 degrees) to violet (270 degrees) in HSV color space,
// at full saturation and brightness, so it naturally passes through orange, yellow, green, blue,
// and indigo along the way, giving the full ROYGBIV look.
real rainbow_hue_start = 0;  // Red
real rainbow_hue_end = 270;  // Violet

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

// Legend layout (Plot.legend())
real legend_line_length = 2;   // Length of each row's line-style sample
real legend_row_height = 0.5;  // Vertical spacing between legend rows
real legend_label_gap = 0.3;   // Gap between a row's line sample and its label

////////////////////////////////////////////////////////////////////////////////////////////////////
// SwitchingNetwork
////////////////////////////////////////////////////////////////////////////////////////////////////

pen switch_thickness = linewidth(1.2);
real switch_unit_width = 1.5;         // Width of a single leaf switch cell
real switch_unit_height = 1.2;        // Height of a single leaf switch cell
real switch_parallel_spacing = 0.4;   // Vertical gap between stacked OR branches
real switch_tick_height = 0.35;       // Height of the diagonal open-switch tick mark
real switch_lead_length = 0.4;        // Length of the input/output lead stubs on the whole network
real switch_terminal_radius = 0.06;   // Radius of the filled terminal dot at each end of the network

////////////////////////////////////////////////////////////////////////////////////////////////////
// RelationDiagram
////////////////////////////////////////////////////////////////////////////////////////////////////

// Arrow/ray styling
arrowbar ray_arrow = ArcArrow(size = 4);
pen ray_beginning = linewidth(4);

// Zone layout
real set_boundary_margin = 0.5;          // Line margin from set boundaries
real label_zone_height = 2.0;            // Fixed height for label zones
real element_zone_bottom_padding = 0.4;  // Padding at bottom to prevent label cutoff
real element_zone_top_padding = 0.55;    // Padding below horizontal line (one font height for text_normal)

// Arrow/relation drawing
real arrow_offset_amount = 0.15;             // Base offset amount for overlapping arrow targets
real arrow_element_margin = 0.35;            // Margin from element labels for horizontal arrow segments
real arrow_horizontal_length_max = 0.5;      // Maximum horizontal line length for arrows
real arrow_horizontal_length_factor = 0.05;  // Horizontal line length as fraction of diagram width

////////////////////////////////////////////////////////////////////////////////////////////////////
// GraphDiagram
////////////////////////////////////////////////////////////////////////////////////////////////////

// Vertex styling
pen graph_vertex_fill = white;
pen graph_vertex_outline = black;
pen graph_vertex_thickness = linewidth(1.0);
real graph_vertex_radius = 0.3;   // Also how far an edge stops short of a vertex center, so an arrowhead lands on the rim rather than under the circle

// Edge styling
pen graph_edge_color = black;
pen graph_edge_thickness = linewidth(0.9);
arrowbar graph_directed_arrow = EndArrow(SimpleHead, size = 5);
real graph_edge_label_offset = 0.25;   // Perpendicular offset of an edge's label from the edge itself
real graph_multi_edge_bow = 0.5;       // Perpendicular spacing between parallel edges joining the same pair of vertices
real graph_edge_vertex_clearance = 0.15;  // Minimum gap an edge keeps from an unrelated vertex's rim when curving around it
real graph_self_loop_size = 1.1;       // Control-point reach of a self-loop; larger makes a bigger loop
real graph_self_loop_angle = 60;       // Angular half-width of a self-loop's attachment points at the vertex rim

// Layout
real graph_layout_margin = 0.5;    // Blank border reserved around the laid-out graph, so vertex circles and labels aren't clipped
int graph_force_iterations = 300;  // Fruchterman-Reingold relaxation steps; higher settles more but costs render time
int graph_random_seed = 1;         // Default seed for the RANDOM layout; the same seed always reproduces the same scatter

////////////////////////////////////////////////////////////////////////////////////////////////////
// TruthTable
////////////////////////////////////////////////////////////////////////////////////////////////////

pen table_header = gray;
pen table_sub_header = mediumgray;
