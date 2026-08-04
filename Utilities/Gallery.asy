///////////////////////////////////////////////////////////////////////////////////////////////////
// Gallery - Grid layout for multiple visuals with captions and labels
//
// A Gallery is a container that holds a grid of visualizations, along with an optional gallery-wide
// caption and optional per-cell labels. `width`/`height` describe the grid's own area only -- when a
// caption is present, it's stacked below that area and adds its own (auto-sized) height on top,
// rather than being carved out of the height you set. See get_total_width()/get_total_height() for
// the actual rendered picture's dimensions.
//
// Visualizations are added one at a time with add(visualization): the gallery places each one in
// row-major order (row 0 left-to-right, then row 1 left-to-right, and so on) starting at the top
// left. There's no way to target a specific cell -- this keeps the API to a single method with no
// parameters to get wrong.
//
// Note: This file expects the following to be defined in the including scope:
//   - text_normal, text_small (typography pens)
//   - wrap_text() function (from Utilities/TextWrapping.asy)
//   - measure_text_size() / measure_text_height() (from Utilities/TextMeasurement.asy)
//   - RelationDiagram/DiscretePlot/Plot/AccumulationTable/TruthTable/SwitchingNetwork/GraphDiagram
//     structs (from Visualizations/*.asy)
//   - NONE (from Visualizations/ContinuousPlot.asy -- reused here as the "off" state for both
//     color_scheme and label_scheme rather than redeclared)
//   - diagram_unit, caption_line_leading, debug_primary_pen, debug_secondary_pen,
//     gallery_caption_padding, gallery_label_padding,
//     gallery_*_light/gallery_*_dark, gallery_brand_1_tint, gallery_brand_2_tint
//     (from Theme/MaximumMathematicsTheme.asy)
///////////////////////////////////////////////////////////////////////////////////////////////////

// Color scheme constants for color_scheme(). NONE (shared with Plot's endpoint-marker scheme) means
// no additional coloring -- just the gallery's own background_color showing through every cell.
string RED = "red";
string ORANGE = "orange";
string YELLOW = "yellow";
string GREEN = "green";
string BLUE = "blue";
string INDIGO = "indigo";
string VIOLET = "violet";
string BROWN = "brown";
string CHECKERBOARD_RED = "checkerboard_red";
string CHECKERBOARD_ORANGE = "checkerboard_orange";
string CHECKERBOARD_YELLOW = "checkerboard_yellow";
string CHECKERBOARD_GREEN = "checkerboard_green";
string CHECKERBOARD_BLUE = "checkerboard_blue";
string CHECKERBOARD_INDIGO = "checkerboard_indigo";
string CHECKERBOARD_VIOLET = "checkerboard_violet";
string CHECKERBOARD_BROWN = "checkerboard_brown";
string CHECKERBOARD_GRAY = "checkerboard_gray";
string CHECKERBOARD = "checkerboard";

// Label scheme constants for label_scheme(). NONE means no labels are generated.
string LOWERCASE = "lowercase";
string UPPERCASE = "uppercase";
string NUMERIC = "numeric";
string ROMAN = "roman";

// Helpers backing the label schemes above -- kept as free functions since they don't need any
// Gallery state.
string gallery_alphabet_lower = "abcdefghijklmnopqrstuvwxyz";
string gallery_alphabet_upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";

string gallery_lowercase_letter(int index) {
    if (index < 0 || index >= length(gallery_alphabet_lower)) {
        abort("Gallery: LOWERCASE label scheme supports at most 26 cells");
    }
    return substr(gallery_alphabet_lower, index, 1);
}

string gallery_uppercase_letter(int index) {
    if (index < 0 || index >= length(gallery_alphabet_upper)) {
        abort("Gallery: UPPERCASE label scheme supports at most 26 cells");
    }
    return substr(gallery_alphabet_upper, index, 1);
}

string gallery_roman_numeral(int n) {
    if (n <= 0) abort("Gallery: ROMAN label scheme requires a positive cell number");
    int[] values = {1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1};
    string[] symbols = {"m", "cm", "d", "cd", "c", "xc", "l", "xl", "x", "ix", "v", "iv", "i"};
    string result = "";
    int remaining = n;
    for (int i = 0; i < values.length; ++i) {
        while (remaining >= values[i]) {
            result += symbols[i];
            remaining -= values[i];
        }
    }
    return result;
}

struct Gallery {
    // Grid shape -- fixed at construction.
    int _rows;
    int _cols;

    // Dimensions of the grid's own area only (see the file header for why).
    real _width;
    real _height;

    // Padding around the grid, inside its own width x height box.
    real _padding_left;
    real _padding_top;
    real _padding_right;
    real _padding_bottom;

    // Styling
    pen _background_color;

    // Caption configuration
    string _caption_title_text;
    string _caption_text_text;

    // Spacing between adjacent cells only -- never applied at the grid's outer boundary, which is
    // instead governed by padding above (a CSS grid-gap, not a per-cell inset).
    real _margin;

    // Per-cell background coloring and labeling schemes.
    string _color_scheme;
    string _label_scheme;

    // Internal state: cells are filled in row-major order by add(), starting at the top left.
    picture[] _cell_pictures;
    bool[] _cell_has_visual;
    int _next_index;

    picture pic;
    bool rendered;
    bool _debug_mode;

    // Constructor -- rows/cols are required (there's no sensible default grid shape) and fixed for
    // the gallery's lifetime.
    void operator init(int rows, int cols) {
        if (rows <= 0) abort("Gallery: rows must be positive, got " + (string)rows);
        if (cols <= 0) abort("Gallery: cols must be positive, got " + (string)cols);

        this._rows = rows;
        this._cols = cols;

        this._width = 20;
        this._height = 8;

        this._padding_left = 0;
        this._padding_top = 0;
        this._padding_right = 0;
        this._padding_bottom = 0;

        this._background_color = white;
        this._caption_title_text = "";
        this._caption_text_text = "";

        this._margin = 0;
        this._color_scheme = NONE;
        this._label_scheme = NONE;

        int total_cells = rows * cols;
        this._cell_pictures = new picture[total_cells];
        this._cell_has_visual = new bool[total_cells];
        for (int i = 0; i < total_cells; ++i) {
            this._cell_pictures[i] = new picture;
            this._cell_has_visual[i] = false;
        }
        this._next_index = 0;

        this.pic = new picture;
        unitsize(this.pic, diagram_unit);
        this.rendered = false;
        this._debug_mode = false;
    }

    // Dimensions (of the grid area -- see the file header)
    void width(real w) { this._width = w; }
    void height(real h) { this._height = h; }

    // Grid padding. Overloaded by argument count rather than one call per combination: padding(p)
    // sets all four sides, padding(h, v) sets horizontal then vertical, and padding(l, t, r, b) sets
    // each side independently.
    void padding(real p) {
        this._padding_left = p;
        this._padding_right = p;
        this._padding_top = p;
        this._padding_bottom = p;
    }

    void padding(real horizontal, real vertical) {
        this._padding_left = horizontal;
        this._padding_right = horizontal;
        this._padding_top = vertical;
        this._padding_bottom = vertical;
    }

    void padding(real left, real top, real right, real bottom) {
        this._padding_left = left;
        this._padding_top = top;
        this._padding_right = right;
        this._padding_bottom = bottom;
    }

    void padding_horizontal(real p) {
        this._padding_left = p;
        this._padding_right = p;
    }

    void padding_vertical(real p) {
        this._padding_top = p;
        this._padding_bottom = p;
    }

    void padding_left(real p) { this._padding_left = p; }
    void padding_top(real p) { this._padding_top = p; }
    void padding_right(real p) { this._padding_right = p; }
    void padding_bottom(real p) { this._padding_bottom = p; }

    // Styling
    void background_color(pen p) { this._background_color = p; }

    // Spacing between adjacent cells only -- see the _margin field comment above.
    void margin(real m) { this._margin = m; }

    void color_scheme(string scheme) {
        if (scheme != NONE && scheme != RED && scheme != ORANGE && scheme != YELLOW &&
            scheme != GREEN && scheme != BLUE && scheme != INDIGO && scheme != VIOLET &&
            scheme != BROWN && scheme != CHECKERBOARD_RED && scheme != CHECKERBOARD_ORANGE &&
            scheme != CHECKERBOARD_YELLOW && scheme != CHECKERBOARD_GREEN &&
            scheme != CHECKERBOARD_BLUE && scheme != CHECKERBOARD_INDIGO &&
            scheme != CHECKERBOARD_VIOLET && scheme != CHECKERBOARD_BROWN &&
            scheme != CHECKERBOARD_GRAY && scheme != CHECKERBOARD) {
            abort("Gallery.color_scheme: unrecognized scheme '" + scheme + "'");
        }
        this._color_scheme = scheme;
    }

    void label_scheme(string scheme) {
        if (scheme != NONE && scheme != LOWERCASE && scheme != UPPERCASE &&
            scheme != NUMERIC && scheme != ROMAN) {
            abort("Gallery.label_scheme: unrecognized scheme '" + scheme + "'");
        }
        this._label_scheme = scheme;
    }

    // Turns on debug drawing -- see render() for exactly what's drawn. No parameter to pass and no
    // way to turn it back off -- just remove the call once you're done tuning.
    void debug() { this._debug_mode = true; }

    // Caption content -- defined further below (after render()) so they can trigger a re-render.

    // Helper: whether a gallery-wide caption zone exists at all.
    bool has_caption() {
        return length(this._caption_title_text) > 0 || length(this._caption_text_text) > 0;
    }

    // The literal string drawn for the title, including the auto-inserted ": " when text follows
    // it -- caption_title("Figure 1") + caption_text("A curve.") renders as "Figure 1: A curve.",
    // not "Figure 1A curve.". A lone title (no text to introduce) gets no colon.
    string get_caption_title_display() {
        if (length(this._caption_title_text) == 0) return "";
        if (length(this._caption_text_text) == 0) return this._caption_title_text;
        return this._caption_title_text + ": ";
    }

    // Width of get_caption_title_display() -- how far the first line of caption text needs to
    // start from the content's left edge to leave room for the title (and its auto-colon).
    real get_caption_title_width() {
        string display = get_caption_title_display();
        if (length(display) == 0) return 0;
        return measure_text_size(display, text_normal).x;
    }

    // Wrap the caption text to fit next to the title on the first line. Every line (including
    // continuations) wraps to this same width -- a hanging indent under the title, rather than
    // continuation lines restarting at the content's left edge under the title itself.
    string[] get_wrapped_caption_lines() {
        if (length(this._caption_text_text) == 0) return new string[];
        real content_width = this._width - 2 * gallery_caption_padding;
        real first_line_width = max(0.5, content_width - get_caption_title_width());
        return wrap_text(this._caption_text_text, first_line_width, text_normal);
    }

    // Vertical distance between consecutive wrapped caption lines. Derived from the font's actual
    // rendered height rather than a fixed constant, so lines can never overlap no matter the font
    // size. Measured from one reference string carrying both an ascender and a descender, so every
    // line is spaced identically instead of the gap shifting with whichever characters a given line
    // happens to contain.
    real get_caption_line_height() {
        return measure_text_height("Ag", text_normal) * caption_line_leading;
    }

    // Vertical space actually needed for the current caption content (title + wrapped text), not
    // including caption padding.
    real get_caption_content_height() {
        if (!has_caption()) return 0;

        real title_height = length(this._caption_title_text) > 0 ?
            measure_text_height(get_caption_title_display(), text_normal) : 0;

        string[] text_lines = get_wrapped_caption_lines();
        real first_line_height = text_lines.length > 0 ?
            measure_text_height(text_lines[0], text_normal) : 0;

        real row_height = max(title_height, first_line_height);
        real line_height = get_caption_line_height();
        real extra_lines_height = text_lines.length > 1 ? (text_lines.length - 1) * line_height : 0;

        return row_height + extra_lines_height;
    }

    // Caption zone height (0 if no caption). Auto-sized to exactly fit the current caption content
    // plus its fixed padding, so the zone can't overflow or leave dead space regardless of gallery
    // width, font size, or how many lines the text wraps to -- there's no setter for this.
    real get_caption_zone_height() {
        if (!has_caption()) return 0;
        return get_caption_content_height() + 2 * gallery_caption_padding;
    }

    // Total rendered picture dimensions. Width always matches the grid's own width (the caption
    // zone spans the same width). Height is the grid's own height plus the caption zone's height
    // stacked below it (0 if there's no caption) -- unlike the grid's height, this isn't something
    // you set directly.
    real get_total_width() {
        return this._width;
    }

    real get_total_height() {
        return this._height + get_caption_zone_height();
    }

    // The grid's own actual rendering area: its declared width/height minus padding.
    real get_visual_width() {
        return this._width - this._padding_left - this._padding_right;
    }

    real get_visual_height() {
        return this._height - this._padding_top - this._padding_bottom;
    }

    // Bottom-left corner of the grid's padded rendering area, in the overall gallery's coordinate
    // system (y=0 is the bottom of the whole rendered picture -- the caption zone, if present, or
    // the grid itself if not).
    pair get_visual_origin() {
        real x = this._padding_left;
        real y = get_caption_zone_height() + this._padding_bottom;
        return (x, y);
    }

    // Full size of one grid cell (including its label zone, if any) -- the padded grid area evenly
    // divided into rows/cols, with (cols-1)/(rows-1) internal margin gaps subtracted first. margin
    // never applies at the grid's outer boundary -- see the _margin field comment.
    real get_cell_width() {
        return (get_visual_width() - (this._cols - 1) * this._margin) / this._cols;
    }

    real get_cell_height() {
        return (get_visual_height() - (this._rows - 1) * this._margin) / this._rows;
    }

    // Height reserved at the bottom of every cell for its label (0 if label_scheme is NONE).
    // Measured against a reference string carrying an ascender, descender, and the parentheses
    // every label is wrapped in, so it's always tall enough regardless of which scheme is active.
    real get_label_zone_height() {
        if (this._label_scheme == NONE) return 0;
        return measure_text_height("(Ag)", text_small) + 2 * gallery_label_padding;
    }

    // The sub-area of a cell actually available for its visualization, once the label zone (if any)
    // is excluded from the bottom.
    real get_cell_visual_width() {
        return get_cell_width();
    }

    real get_cell_visual_height() {
        return get_cell_height() - get_label_zone_height();
    }

    // The label text for a given row-major cell index, wrapped in parentheses -- (a), (A), (1), (i).
    // Returns "" when label_scheme is NONE.
    string get_cell_label(int index) {
        if (this._label_scheme == LOWERCASE) return "(" + gallery_lowercase_letter(index) + ")";
        if (this._label_scheme == UPPERCASE) return "(" + gallery_uppercase_letter(index) + ")";
        if (this._label_scheme == NUMERIC) return "(" + (string)(index + 1) + ")";
        if (this._label_scheme == ROMAN) return "(" + gallery_roman_numeral(index + 1) + ")";
        return "";
    }

    // The background fill for a given grid cell, per color_scheme. Solid hue schemes (RED, ...) use
    // one shade uniformly; checkerboard schemes (CHECKERBOARD_RED, ..., and the brand-color
    // CHECKERBOARD) alternate between two shades based on the cell's row/col parity. NONE (and
    // anything unrecognized) falls back to the gallery's own background_color, i.e. no additional
    // coloring.
    pen get_cell_fill_pen(int row, int col) {
        bool alternate = ((row + col) % 2 == 0);
        if (this._color_scheme == RED) return gallery_red_light;
        if (this._color_scheme == ORANGE) return gallery_orange_light;
        if (this._color_scheme == YELLOW) return gallery_yellow_light;
        if (this._color_scheme == GREEN) return gallery_green_light;
        if (this._color_scheme == BLUE) return gallery_blue_light;
        if (this._color_scheme == INDIGO) return gallery_indigo_light;
        if (this._color_scheme == VIOLET) return gallery_violet_light;
        if (this._color_scheme == BROWN) return gallery_brown_light;
        if (this._color_scheme == CHECKERBOARD_RED) return alternate ? gallery_red_light : gallery_red_dark;
        if (this._color_scheme == CHECKERBOARD_ORANGE) return alternate ? gallery_orange_light : gallery_orange_dark;
        if (this._color_scheme == CHECKERBOARD_YELLOW) return alternate ? gallery_yellow_light : gallery_yellow_dark;
        if (this._color_scheme == CHECKERBOARD_GREEN) return alternate ? gallery_green_light : gallery_green_dark;
        if (this._color_scheme == CHECKERBOARD_BLUE) return alternate ? gallery_blue_light : gallery_blue_dark;
        if (this._color_scheme == CHECKERBOARD_INDIGO) return alternate ? gallery_indigo_light : gallery_indigo_dark;
        if (this._color_scheme == CHECKERBOARD_VIOLET) return alternate ? gallery_violet_light : gallery_violet_dark;
        if (this._color_scheme == CHECKERBOARD_BROWN) return alternate ? gallery_brown_light : gallery_brown_dark;
        if (this._color_scheme == CHECKERBOARD_GRAY) return alternate ? gallery_gray_light : gallery_gray_dark;
        if (this._color_scheme == CHECKERBOARD) return alternate ? gallery_brand_1_tint : gallery_brand_2_tint;
        return this._background_color;
    }

    // Render the gallery-wide caption, below the entire grid.
    void render_caption() {
        if (!has_caption()) return;

        real zone_height = get_caption_zone_height();
        real content_left = gallery_caption_padding;

        string title_display = get_caption_title_display();
        real title_width = get_caption_title_width();
        string[] text_lines = get_wrapped_caption_lines();

        // Position at top of content area. label() centers vertically on the point given, so the
        // anchor is offset up by half the row's actual measured height -- not a fixed guess --
        // which is what guarantees the row stays within the content area regardless of font size.
        real title_height = length(this._caption_title_text) > 0 ?
            measure_text_height(title_display, text_normal) : 0;
        real first_line_height = text_lines.length > 0 ?
            measure_text_height(text_lines[0], text_normal) : 0;
        real row_height = max(title_height, first_line_height);
        real top_row_y = zone_height - gallery_caption_padding - row_height / 2;

        // Title: left-aligned at the content area's left edge (not right-aligned toward a fixed
        // column boundary -- the "boundary" here is however wide the title actually is).
        if (length(title_display) > 0) {
            label(this.pic, title_display, (content_left, top_row_y), align=E, p=text_normal);
        }

        // Text: left-aligned starting right after the title (and its auto-colon), wrapping below
        // at the same indent.
        if (text_lines.length > 0) {
            real line_height = get_caption_line_height();
            real text_x = content_left + title_width;
            for (int i = 0; i < text_lines.length; ++i) {
                real line_y = top_row_y - i * line_height;
                label(this.pic, text_lines[i], (text_x, line_y), align=E, p=text_normal);
            }
        }
    }

    // Render the entire gallery: background, every grid cell (fill, visual, label), the gallery-wide
    // caption, and (if debug() was called) all debug borders/separators. Rebuilds this.pic from
    // scratch and replaces currentpicture wholesale, so it's safe to call repeatedly as cells fill
    // in -- there's never more than one gallery's worth of content in currentpicture at a time.
    void render() {
        this.pic = new picture;
        unitsize(this.pic, diagram_unit);

        real total_width = get_total_width();
        real total_height = get_total_height();
        real caption_zone_height = get_caption_zone_height();

        // Draw actual gallery area (using background color) -- spans the full rendered picture,
        // grid plus caption zone (if any).
        fill(this.pic, box((0, 0), (total_width, total_height)), this._background_color);

        pair visual_origin = get_visual_origin();
        real visual_width = get_visual_width();
        real visual_height = get_visual_height();

        real cell_width = get_cell_width();
        real cell_height = get_cell_height();
        real label_zone_height = get_label_zone_height();

        for (int row = 0; row < this._rows; ++row) {
            for (int col = 0; col < this._cols; ++col) {
                int index = row * this._cols + col;

                real cell_left = visual_origin.x + col * (cell_width + this._margin);
                real cell_top = visual_origin.y + visual_height - row * (cell_height + this._margin);
                real cell_bottom = cell_top - cell_height;
                real cell_right = cell_left + cell_width;
                real visual_zone_bottom = cell_bottom + label_zone_height;

                fill(this.pic, box((cell_left, cell_bottom), (cell_right, cell_top)),
                     get_cell_fill_pen(row, col));

                if (this._cell_has_visual[index]) {
                    // Center the stored visual within the cell's visual sub-area (above the label
                    // zone, if any) -- every visualization's render() is documented to fill the
                    // given width x height exactly, so this centering is a no-op for them; it
                    // matters for a raw picture passed to add_visual() directly.
                    picture diagram = this._cell_pictures[index];
                    pair content_min = min(diagram, true);
                    pair content_max = max(diagram, true);
                    real available_width = cell_right - cell_left;
                    real available_height = cell_top - visual_zone_bottom;
                    pair diagram_pos = (cell_left, visual_zone_bottom) + (
                        (available_width - (content_max.x - content_min.x)) / 2 - content_min.x,
                        (available_height - (content_max.y - content_min.y)) / 2 - content_min.y
                    );
                    add(this.pic, diagram, diagram_pos);

                    if (this._label_scheme != NONE) {
                        string label_text = get_cell_label(index);
                        pair label_pos = (cell_left + available_width / 2, cell_bottom + label_zone_height / 2);
                        label(this.pic, label_text, label_pos, align=Center, p=text_small);
                    }
                }

                if (this._debug_mode) {
                    // Border around this cell (the full cell, including its label zone).
                    draw(this.pic, box((cell_left, cell_bottom), (cell_right, cell_top)), p=debug_primary_pen);

                    // Separator between the label zone and the visual sub-area -- the one debug
                    // line in the whole library drawn with debug_secondary_pen (dotted); every
                    // other debug line uses debug_primary_pen.
                    if (label_zone_height > 0) {
                        draw(this.pic, (cell_left, visual_zone_bottom)--(cell_right, visual_zone_bottom),
                             p=debug_secondary_pen);
                    }
                }
            }
        }

        if (this._debug_mode) {
            // Border around the entire rendered picture.
            draw(this.pic, box((0, 0), (total_width, total_height)), p=debug_primary_pen);

            // Border around the grid's own visualization area.
            draw(this.pic, box(visual_origin, visual_origin + (visual_width, visual_height)), p=debug_primary_pen);

            if (has_caption()) {
                // Separator between the grid and the caption area, spanning the full width.
                draw(this.pic, (0, caption_zone_height)--(total_width, caption_zone_height), p=debug_primary_pen);

                // Boundary between title and text -- only meaningful when both are present.
                if (length(this._caption_title_text) > 0 && length(this._caption_text_text) > 0) {
                    real separator_x = gallery_caption_padding + get_caption_title_width();
                    draw(this.pic, (separator_x, 0)--(separator_x, caption_zone_height), p=debug_primary_pen);
                }
            }
        }

        render_caption();

        // Always replace currentpicture with a fresh gallery render -- render() runs once per
        // add() call as cells fill in, and each run should fully supersede the last rather than
        // stack on top of it.
        currentpicture = new picture;
        unitsize(currentpicture, diagram_unit);
        add(currentpicture, this.pic, (0, 0));
        this.rendered = true;
    }

    // Caption methods. Defined after render() so they can re-render: captions are typically set
    // after the add() calls, i.e. after the gallery has already auto-rendered once, so we must
    // render again to pick up the new text.
    void caption_title(string title) {
        this._caption_title_text = title;
        if (this.rendered) render();
    }

    void caption_text(string text) {
        this._caption_text_text = text;
        if (this.rendered) render();
    }

    // Add a raw picture to the next cell, in row-major order. Defined after render() so this.render()
    // resolves: Asymptote binds struct member names top-to-bottom, so a method may only call sibling
    // methods declared above it.
    void add_visual(picture diagram) {
        int total_cells = this._rows * this._cols;
        if (this._next_index >= total_cells) {
            abort("Gallery.add: grid is full (" + (string)total_cells + " cells)");
        }

        this._cell_pictures[this._next_index] = diagram;
        this._cell_has_visual[this._next_index] = true;
        this._next_index += 1;

        render();
    }

    // Add RelationDiagram directly
    void add(RelationDiagram diagram) {
        picture diagram_pic = diagram.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add DiscretePlot directly
    void add(DiscretePlot diagram) {
        picture diagram_pic = diagram.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add Plot directly
    void add(Plot diagram) {
        picture diagram_pic = diagram.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add AccumulationTable directly
    void add(AccumulationTable table) {
        picture diagram_pic = table.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add TruthTable directly
    void add(TruthTable table) {
        picture diagram_pic = table.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add SwitchingNetwork directly
    void add(SwitchingNetwork network) {
        picture diagram_pic = network.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add GraphDiagram directly
    void add(GraphDiagram graph) {
        picture diagram_pic = graph.render(
            get_cell_visual_width(),
            get_cell_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }
};
