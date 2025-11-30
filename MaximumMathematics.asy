import graph;
import three;

unitsize(1cm);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Maximum Mathematics color palette
///////////////////////////////////////////////////////////////////////////////////////////////////

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

// Tree Diagram colors
pen pruned_branch_color = RGB(255, 36, 0);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Maximum Mathematics figure design
///////////////////////////////////////////////////////////////////////////////////////////////////

// Graphing/axis styling
pen axis_thickness = linewidth(1.5);
pen grid_thickness = linewidth(0.2);
arrowbar axis_arrow = ArcArrows(size = 4);
pen function_thickness = linewidth(1.2);
arrowbar function_arrow = ArcArrows(SimpleHead, size = 3);

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

///////////////////////////////////////////////////////////////////////////////////////////////////
// Maximum Mathematics typography
///////////////////////////////////////////////////////////////////////////////////////////////////

// Struct to tie typography pens with their character width estimates
struct TypographyPen {
    pen p;
    real char_width_estimate;
    
    void operator init(pen pen_value, real char_width) {
        this.p = pen_value;
        this.char_width_estimate = char_width;
    }
}

// Header sizes (larger than text for visual distinction)
TypographyPen header_1 = TypographyPen(fontsize(1.2cm), 0.669222);  // Determined from visual testing
TypographyPen header_2 = TypographyPen(fontsize(1.0cm), 0.629856);  // Determined from visual testing
TypographyPen header_3 = TypographyPen(fontsize(0.8cm), 0.52488);  // Determined from visual testing

// Text sizes
TypographyPen text_large = TypographyPen(fontsize(0.65cm), 0.4374);  // Determined from visual testing
TypographyPen text_normal = TypographyPen(fontsize(0.55cm), 0.354294);  // Determined from visual testing
TypographyPen text_small = TypographyPen(fontsize(0.45cm), 0.314928);  // Determined from visual testing

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include utilities
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Utilities/TextWrapping.asy";
include "Utilities/TextMeasurement.asy";
include "Utilities/TextSetWidth.asy";

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include RelationDiagram
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Visualizations/RelationDiagram.asy";

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include utilities
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Utilities/Image.asy";
include "Utilities/Gallery.asy";
