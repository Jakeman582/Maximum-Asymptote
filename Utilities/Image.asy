///////////////////////////////////////////////////////////////////////////////////////////////////
// Image - Main container for visualizations
//
// An Image is a container used to house and display a visualization along with an optional
// caption. `width`/`height` describe the visualization's own area only -- when a caption is
// present, it's stacked below that area and adds its own (auto-sized) height on top, rather than
// being carved out of the height you set. See get_total_width()/get_total_height() for the actual
// rendered picture's dimensions.
//
// Note: This file expects the following to be defined in the including scope:
//   - text_normal (typography pen)
//   - wrap_text() function (from Utilities/TextWrapping.asy)
//   - measure_text_size() / measure_text_height() (from Utilities/TextMeasurement.asy)
//   - RelationDiagram/DiscretePlot/Plot/AccumulationTable/TruthTable/SwitchingNetwork/GraphDiagram
//     structs (from Visualizations/*.asy)
//   - diagram_unit, caption_line_leading, image_caption_padding, debug_primary_pen
//     (from Theme/MaximumMathematicsTheme.asy)
///////////////////////////////////////////////////////////////////////////////////////////////////

struct Image {
    // Dimensions of the visualization area only (see the file header for why).
    real _width;
    real _height;

    // Padding around the visualization, inside its own width x height box.
    real _padding_left;
    real _padding_top;
    real _padding_right;
    real _padding_bottom;

    // Styling
    pen _background_color;

    // Caption configuration
    string _caption_title_text;
    string _caption_text_text;

    // Internal state
    picture pic;
    bool has_visual;
    bool rendered;

    // Constructor. Takes no size -- set width/height with the methods below.
    void operator init() {
        this._width = 10;
        this._height = 8;

        this._padding_left = 0;
        this._padding_top = 0;
        this._padding_right = 0;
        this._padding_bottom = 0;

        this._background_color = white;
        this._caption_title_text = "";
        this._caption_text_text = "";

        this.pic = new picture;
        unitsize(this.pic, diagram_unit);
        this.has_visual = false;
        this.rendered = false;
    }

    // Dimensions (of the visualization area -- see the file header)
    void width(real w) { this._width = w; }
    void height(real h) { this._height = h; }

    // Visualization padding. Overloaded by argument count rather than one call per combination:
    // padding(p) sets all four sides, padding(h, v) sets horizontal then vertical, and
    // padding(l, t, r, b) sets each side independently.
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

    // Caption content
    void caption_title(string title) { this._caption_title_text = title; }
    void caption_text(string text) { this._caption_text_text = text; }

    // Helper: whether a caption zone exists at all.
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
        real content_width = this._width - 2 * image_caption_padding;
        real first_line_width = max(0.5, content_width - get_caption_title_width());
        return wrap_text(this._caption_text_text, first_line_width, text_normal);
    }

    // Vertical distance between consecutive wrapped caption lines. Derived from the font's actual
    // rendered height rather than a fixed constant, so lines can never overlap no matter the font
    // size. Measured from one reference string carrying both an ascender and a descender, so every
    // line is spaced identically instead of the gap shifting with whichever characters a given
    // line happens to contain.
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
    // plus its padding, so the zone can't overflow or leave dead space regardless of image width,
    // font size, or how many lines the text wraps to -- there's no direct setter for this.
    real get_caption_zone_height() {
        if (!has_caption()) return 0;
        return get_caption_content_height() + 2 * image_caption_padding;
    }

    // Total rendered picture dimensions. Width always matches the visualization's own width (the
    // caption zone spans the same width). Height is the visualization's own height plus the
    // caption zone's height stacked below it (0 if there's no caption) -- unlike the
    // visualization's height, this isn't something you set directly.
    real get_total_width() {
        return this._width;
    }

    real get_total_height() {
        return this._height + get_caption_zone_height();
    }

    // The visualization's own actual rendering area: its declared width/height minus padding.
    real get_visual_width() {
        return this._width - this._padding_left - this._padding_right;
    }

    real get_visual_height() {
        return this._height - this._padding_top - this._padding_bottom;
    }

    // Bottom-left corner of the visualization's padded rendering area, in the overall image's
    // coordinate system (y=0 is the bottom of the whole rendered picture -- the caption zone, if
    // present, or the visualization itself if not).
    pair get_visual_origin() {
        real x = this._padding_left;
        real y = get_caption_zone_height() + this._padding_bottom;
        return (x, y);
    }

    // Render caption
    void render_caption() {
        if (!has_caption()) return;

        real zone_height = get_caption_zone_height();
        real content_left = image_caption_padding;

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
        real top_row_y = zone_height - image_caption_padding - row_height / 2;

        // Title: left-aligned at the content area's left edge (not right-aligned toward a fixed
        // column boundary -- the "boundary" here is however wide the title actually is, not a
        // preset fraction of the width).
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

    // Draws debug boundaries directly onto the already-rendered image: a border around the
    // entire rendered picture, the padded visualization area's own border, and, when a caption
    // is present, the zone/title separators. Must be called after add()/add_visual() -- there's
    // nothing to outline until the image has actually been rendered. Whether debug information
    // appears depends entirely on calling this method, not on any stored flag: call it and the
    // boundaries are drawn immediately; never call it and they never exist. Calling it more than
    // once simply redraws the same lines on top of themselves.
    void debug() {
        if (!this.has_visual) {
            abort("Image.debug: call add()/add_visual() before debug()");
        }

        real total_width = get_total_width();
        real total_height = get_total_height();
        real caption_zone_height = get_caption_zone_height();

        // Drawn into a standalone overlay, rather than directly, so the same content can be
        // merged into both this.pic (so it stays part of the image if reused later, e.g. via
        // Gallery.add_visual(image.pic)) and currentpicture (so it's visible right away)
        // without disturbing anything currentpicture already holds -- unlike a full re-render,
        // this never wipes out unrelated content added there in the meantime.
        picture overlay = new picture;
        unitsize(overlay, diagram_unit);

        // Border around the entire rendered picture (visualization area plus caption zone, if
        // any).
        draw(overlay, box((0, 0), (total_width, total_height)), p=debug_primary_pen);

        // Border around the padded visualization content area -- where the diagram is actually
        // centered and drawn, inset from the declared width x height box by padding on each
        // side (not the declared box itself).
        pair debug_visual_origin = get_visual_origin();
        draw(overlay, box(debug_visual_origin,
                         debug_visual_origin + (get_visual_width(), get_visual_height())),
             p=debug_primary_pen);

        if (has_caption()) {
            // Separator between the visualization area and the caption area, spanning the full
            // width.
            draw(overlay, (0, caption_zone_height)--(total_width, caption_zone_height), p=debug_primary_pen);

            // Boundary between title and text -- only meaningful when both are present.
            if (length(this._caption_title_text) > 0 && length(this._caption_text_text) > 0) {
                real separator_x = image_caption_padding + get_caption_title_width();
                draw(overlay, (separator_x, 0)--(separator_x, caption_zone_height), p=debug_primary_pen);
            }
        }

        add(this.pic, overlay, (0, 0));
        add(currentpicture, overlay, (0, 0));
    }

    // Add visual and auto-render
    void add_visual(picture diagram) {
        if (this.has_visual) return;  // Only allow one visual per image

        real total_width = get_total_width();
        real total_height = get_total_height();

        // Draw actual image area (using background color) -- spans the full rendered picture,
        // visualization plus caption zone (if any).
        fill(this.pic, box((0, 0), (total_width, total_height)), this._background_color);

        // Add diagram, centered within the visualization's padded rendering area. Every
        // visualization's render() is documented to fill the given width x height exactly, so for
        // them this centering is a no-op (zero slack to center within); it matters for a picture
        // smaller than the area -- e.g. a raw picture passed to add_visual() directly -- which
        // would otherwise sit anchored to the area's bottom-left corner instead of centered in the
        // space actually given to it.
        pair zone_origin = get_visual_origin();
        real zone_width = get_visual_width();
        real zone_height = get_visual_height();
        pair content_min = min(diagram, true);
        pair content_max = max(diagram, true);
        pair diagram_pos = zone_origin + (
            (zone_width - (content_max.x - content_min.x)) / 2 - content_min.x,
            (zone_height - (content_max.y - content_min.y)) / 2 - content_min.y
        );
        add(this.pic, diagram, diagram_pos);

        // Render caption
        render_caption();

        // Mark as having visual
        this.has_visual = true;

        // Auto-render to currentpicture. Merged via the position-based add() (which internally
        // calls this.pic.fit() before attaching it) rather than the plain picture-to-picture add()
        // -- the plain form defers fitting this.pic until currentpicture itself is shipped out, and
        // scales this.pic's user-coordinate content (the background fill, every label's anchor
        // position) by CURRENTPICTURE's own resolved transform rather than this.pic's own
        // unitsize(diagram_unit). Since nothing in this library ever calls unitsize()/size() on
        // currentpicture itself (by design -- see the theme file's header comment), that transform
        // resolves to the identity, collapsing every such position to a fraction of a point.
        // Forcing this.pic to fit() itself first -- using its own, explicitly-set scale --
        // sidesteps the whole ambiguity, the same way the diagram add() above already does.
        if (!this.rendered) {
            add(currentpicture, this.pic, (0, 0));
            this.rendered = true;
        }
    }

    // Add RelationDiagram directly
    void add(RelationDiagram diagram) {
        picture diagram_pic = diagram.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add DiscretePlot directly
    void add(DiscretePlot diagram) {
        picture diagram_pic = diagram.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add Plot directly
    void add(Plot diagram) {
        picture diagram_pic = diagram.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add AccumulationTable directly
    void add(AccumulationTable table) {
        picture diagram_pic = table.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add TruthTable directly
    void add(TruthTable table) {
        picture diagram_pic = table.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add SwitchingNetwork directly
    void add(SwitchingNetwork network) {
        picture diagram_pic = network.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add GraphDiagram directly
    void add(GraphDiagram graph) {
        picture diagram_pic = graph.render(
            get_visual_width(),
            get_visual_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }
};
