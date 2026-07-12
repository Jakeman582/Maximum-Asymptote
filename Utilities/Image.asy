///////////////////////////////////////////////////////////////////////////////////////////////////
// Image - Main container for visualizations
// 
// Note: This file expects the following to be defined in the including scope:
//   - text_normal (typography pen)
//   - wrap_text() function (from Utilities/TextWrapping.asy)
//   - RelationDiagram struct (from Visualizations/RelationDiagram.asy)
//   - diagram_unit (real, unit size for diagrams)
///////////////////////////////////////////////////////////////////////////////////////////////////

struct Image {
    // Dimensions
    real width;
    real height;
    
    // Margins (outside edge) - only 4 values needed
    real margin_left;
    real margin_right;
    real margin_top;
    real margin_bottom;
    
    // Diagram padding (inside diagram zone) - only 4 values needed
    real diagram_padding_left;
    real diagram_padding_right;
    real diagram_padding_top;
    real diagram_padding_bottom;
    
    // Caption padding (inside caption zone) - only 4 values needed
    real caption_padding_left;
    real caption_padding_right;
    real caption_padding_top;
    real caption_padding_bottom;
    
    // Styling
    pen background_color;
    
    // Caption configuration
    string caption_title_text;
    string caption_text_text;
    real caption_title_width_factor;
    
    // Internal state
    picture pic;
    bool has_visual;
    bool rendered;
    bool debug_mode;
    
    // Constructor
    void operator init(real width = 10, real height = 8) {
        this.width = width;
        this.height = height;
        
        // Initialize all properties to 0
        this.margin_left = 0;
        this.margin_right = 0;
        this.margin_top = 0;
        this.margin_bottom = 0;
        
        this.diagram_padding_left = 0;
        this.diagram_padding_right = 0;
        this.diagram_padding_top = 0;
        this.diagram_padding_bottom = 0;
        
        this.caption_padding_left = 0;
        this.caption_padding_right = 0;
        this.caption_padding_top = 0;
        this.caption_padding_bottom = 0;
        
        // Defaults
        this.background_color = white;
        this.caption_title_text = "";
        this.caption_text_text = "";
        this.caption_title_width_factor = 0.2;  // 20% for title, 80% for text

        // Internal state
        this.pic = new picture;
        unitsize(this.pic, 1cm);
        this.has_visual = false;
        this.rendered = false;
        this.debug_mode = false;
    }

    // Dimension setters
    void set_width(real w) {
        this.width = w;
    }

    void set_height(real h) {
        this.height = h;
    }

    // Margin setters
    void set_margin(real m) {
        this.margin_left = m;
        this.margin_right = m;
        this.margin_top = m;
        this.margin_bottom = m;
    }
    
    void set_margin_horizontal(real m) {
        this.margin_left = m;
        this.margin_right = m;
    }
    
    void set_margin_vertical(real m) {
        this.margin_top = m;
        this.margin_bottom = m;
    }
    
    void set_margin_left(real m) {
        this.margin_left = m;
    }
    
    void set_margin_right(real m) {
        this.margin_right = m;
    }
    
    void set_margin_top(real m) {
        this.margin_top = m;
    }
    
    void set_margin_bottom(real m) {
        this.margin_bottom = m;
    }
    
    // Diagram padding setters
    void set_diagram_padding(real p) {
        this.diagram_padding_left = p;
        this.diagram_padding_right = p;
        this.diagram_padding_top = p;
        this.diagram_padding_bottom = p;
    }
    
    void set_diagram_padding_horizontal(real p) {
        this.diagram_padding_left = p;
        this.diagram_padding_right = p;
    }
    
    void set_diagram_padding_vertical(real p) {
        this.diagram_padding_top = p;
        this.diagram_padding_bottom = p;
    }
    
    void set_diagram_padding_left(real p) {
        this.diagram_padding_left = p;
    }
    
    void set_diagram_padding_right(real p) {
        this.diagram_padding_right = p;
    }
    
    void set_diagram_padding_top(real p) {
        this.diagram_padding_top = p;
    }
    
    void set_diagram_padding_bottom(real p) {
        this.diagram_padding_bottom = p;
    }
    
    // Caption padding setters
    void set_caption_padding(real p) {
        this.caption_padding_left = p;
        this.caption_padding_right = p;
        this.caption_padding_top = p;
        this.caption_padding_bottom = p;
    }
    
    void set_caption_padding_horizontal(real p) {
        this.caption_padding_left = p;
        this.caption_padding_right = p;
    }
    
    void set_caption_padding_vertical(real p) {
        this.caption_padding_top = p;
        this.caption_padding_bottom = p;
    }
    
    void set_caption_padding_left(real p) {
        this.caption_padding_left = p;
    }
    
    void set_caption_padding_right(real p) {
        this.caption_padding_right = p;
    }
    
    void set_caption_padding_top(real p) {
        this.caption_padding_top = p;
    }
    
    void set_caption_padding_bottom(real p) {
        this.caption_padding_bottom = p;
    }
    
    // Other setters
    void set_background_color(pen color) {
        this.background_color = color;
    }
    
    void set_caption_title_width_factor(real factor) {
        this.caption_title_width_factor = factor;
    }

    void set_debug_mode(bool enable) {
        this.debug_mode = enable;
    }
    
    bool get_debug_mode() {
        return this.debug_mode;
    }
    
    // Caption methods
    void caption_title(string title) {
        this.caption_title_text = title;
    }
    
    void caption_text(string text) {
        this.caption_text_text = text;
    }
    
    // Helper: Get effective margin
    real get_margin_left() {
        return this.margin_left;
    }
    
    real get_margin_right() {
        return this.margin_right;
    }
    
    real get_margin_top() {
        return this.margin_top;
    }
    
    real get_margin_bottom() {
        return this.margin_bottom;
    }
    
    // Helper: Get effective diagram padding
    real get_diagram_padding_left() {
        return this.diagram_padding_left;
    }
    
    real get_diagram_padding_right() {
        return this.diagram_padding_right;
    }
    
    real get_diagram_padding_top() {
        return this.diagram_padding_top;
    }
    
    real get_diagram_padding_bottom() {
        return this.diagram_padding_bottom;
    }
    
    // Helper: Get effective caption padding
    real get_caption_padding_left() {
        return this.caption_padding_left;
    }
    
    real get_caption_padding_right() {
        return this.caption_padding_right;
    }
    
    real get_caption_padding_top() {
        return this.caption_padding_top;
    }
    
    real get_caption_padding_bottom() {
        return this.caption_padding_bottom;
    }
    
    // Helper: Check if caption zone is needed
    bool has_caption() {
        return length(this.caption_title_text) > 0 || length(this.caption_text_text) > 0;
    }

    // Helper: Get diagram zone dimensions
    real get_diagram_zone_width() {
        return this.width;
    }

    // Wrap the caption text to fit the current width and caption padding. Pure function of
    // current state, safe to call more than once per render (e.g. once to size the caption
    // zone, once to lay it out).
    string[] get_wrapped_caption_lines() {
        if (length(this.caption_text_text) == 0) return new string[];
        real content_width = get_diagram_zone_width() - get_caption_padding_left() - get_caption_padding_right();
        real text_width = content_width * (1.0 - this.caption_title_width_factor);
        return wrap_text(this.caption_text_text, text_width, text_normal);
    }

    // Vertical space actually needed for the current caption content (title + wrapped text),
    // not including caption padding.
    real get_caption_content_height() {
        if (!has_caption()) return 0;

        real title_height = length(this.caption_title_text) > 0 ?
            measure_text_height(this.caption_title_text, text_normal) : 0;

        string[] text_lines = get_wrapped_caption_lines();
        real first_line_height = text_lines.length > 0 ?
            measure_text_height(text_lines[0], text_normal) : 0;

        real row_height = max(title_height, first_line_height);
        real line_height = 0.5;  // Matches the per-line spacing used when rendering wrapped lines
        real extra_lines_height = text_lines.length > 1 ? (text_lines.length - 1) * line_height : 0;

        return row_height + extra_lines_height;
    }

    // Helper: Get caption zone height (0 if no caption). Auto-sized to exactly fit the current
    // caption content plus its padding, so the zone can't overflow or leave dead space regardless
    // of image width, font size, or how many lines the text wraps to.
    real get_caption_zone_height() {
        if (!has_caption()) return 0;
        return get_caption_content_height() + get_caption_padding_top() + get_caption_padding_bottom();
    }

    real get_diagram_zone_height() {
        return this.height - get_caption_zone_height();
    }
    
    // Helper: Get actual diagram drawing area (diagram zone minus padding)
    real get_diagram_width() {
        return get_diagram_zone_width() - get_diagram_padding_left() - get_diagram_padding_right();
    }
    
    real get_diagram_height() {
        return get_diagram_zone_height() - get_diagram_padding_top() - get_diagram_padding_bottom();
    }
    
    // Helper: Get diagram origin position (bottom-left of diagram drawing area)
    pair get_diagram_origin() {
        real x = get_diagram_padding_left();
        real y = get_caption_zone_height() + get_diagram_padding_bottom();
        return (x, y);
    }
    
    // Helper: Get caption zone origin (bottom-left of caption zone)
    pair get_caption_zone_origin() {
        real x = 0;
        real y = 0;
        return (x, y);
    }
    
    // Render caption
    void render_caption() {
        if (!has_caption()) return;
        
        // Caption zone dimensions
        real caption_zone_width = get_diagram_zone_width();
        pair caption_origin = get_caption_zone_origin();
        
        // Available space for caption content (after padding)
        real content_left = caption_origin.x + get_caption_padding_left();
        real content_bottom = caption_origin.y + get_caption_padding_bottom();
        real content_width = caption_zone_width - get_caption_padding_left() - get_caption_padding_right();
        real content_height = get_caption_zone_height() - get_caption_padding_top() - get_caption_padding_bottom();

        // Split content width
        real title_width = content_width * this.caption_title_width_factor;

        // Add small spacing before separator
        real separator_spacing = 0.03;

        // Wrap the caption text up front so its first line's height can be measured below —
        // title and the first text line share one row. Reuses the same wrapping the zone was
        // auto-sized from, so the content matches exactly what get_caption_zone_height() planned for.
        string[] text_lines = get_wrapped_caption_lines();

        // Position at top of content area. label() centers vertically on the point given, so the
        // anchor is offset up by half the row's actual measured height — not a fixed guess — which
        // is what guarantees the row stays within the content area regardless of font size or
        // content (a fixed offset only happens to fit whichever font size it was tuned against).
        real title_height = length(this.caption_title_text) > 0 ?
            measure_text_height(this.caption_title_text, text_normal) : 0;
        real first_line_height = text_lines.length > 0 ?
            measure_text_height(text_lines[0], text_normal) : 0;
        real row_height = max(title_height, first_line_height);
        real content_top_y = content_bottom + content_height - row_height / 2;

        // Render title: right-aligned, ending slightly left of separator, just below top border
        real title_y = content_top_y;  // Position just below top border
        if (length(this.caption_title_text) > 0) {
            real title_x = content_left + title_width - separator_spacing;
            label(this.pic, this.caption_title_text,
                  (title_x, title_y),
                  align=W, p=text_normal);
        }

        // Render text: left-aligned, starting at separator (with wrapping)
        if (text_lines.length > 0) {
            // Calculate line spacing
            // Use line height of ~0.5cm (about 0.91x font size) for readable spacing without overlap
            real line_height = 0.5;

            // Position first line at top (same y as title), subsequent lines below
            real text_top_y = content_top_y;

            // Render each line (first line at top, subsequent lines below)
            for (int i = 0; i < text_lines.length; ++i) {
                real line_y = text_top_y - i * line_height;
                label(this.pic, text_lines[i],
                      (content_left + title_width, line_y),
                      align=E, p=text_normal);
            }
        }
    }
    
    // Add visual and auto-render
    void add_visual(picture diagram) {
        if (this.has_visual) return;  // Only allow one visual per image
        
        if (this.debug_mode) {
            // DEBUG: Draw entire margin area (light red) - extends outside the image bounds
            pen light_red = rgb(1.0, 0.8, 0.8);
            real outer_left = -get_margin_left();
            real outer_right = this.width + get_margin_right();
            real outer_bottom = -get_margin_bottom();
            real outer_top = this.height + get_margin_top();
            fill(this.pic, box((outer_left, outer_bottom), (outer_right, outer_top)), light_red);
        }
        
        // Draw actual image area (using background color)
        fill(this.pic, box((0, 0), (this.width, this.height)), this.background_color);
        
        if (this.debug_mode) {
            // DEBUG: Draw diagram zone (light green)
            pen light_green = rgb(0.8, 1.0, 0.8);
            real diagram_zone_x = 0;
            real diagram_zone_y = get_caption_zone_height();
            real diagram_zone_width = get_diagram_zone_width();
            real diagram_zone_height = get_diagram_zone_height();
            fill(this.pic, box((diagram_zone_x, diagram_zone_y), 
                              (diagram_zone_x + diagram_zone_width, diagram_zone_y + diagram_zone_height)), 
                 light_green);
            
            // DEBUG: Draw actual diagram area border (dark green)
            pen dark_green = rgb(0.0, 0.5, 0.0) + linewidth(2);
            pair diagram_origin = get_diagram_origin();
            real diagram_width = get_diagram_width();
            real diagram_height = get_diagram_height();
            draw(this.pic, box(diagram_origin, 
                              (diagram_origin.x + diagram_width, diagram_origin.y + diagram_height)), 
                 p=dark_green);
            
            // DEBUG: Draw caption zone (light blue) if it exists
            if (has_caption()) {
                pen light_blue = rgb(0.8, 0.8, 1.0);
                pair caption_origin = get_caption_zone_origin();
                real caption_zone_width = get_diagram_zone_width();
                real caption_zone_height = get_caption_zone_height();
                fill(this.pic, box(caption_origin, 
                                  (caption_origin.x + caption_zone_width, caption_origin.y + caption_zone_height)), 
                     light_blue);
                
                // DEBUG: Draw caption content area border (dark blue)
                pen dark_blue = rgb(0.0, 0.0, 0.5) + linewidth(2);
                real content_left = caption_origin.x + get_caption_padding_left();
                real content_bottom = caption_origin.y + get_caption_padding_bottom();
                real content_width = caption_zone_width - get_caption_padding_left() - get_caption_padding_right();
                real content_height = caption_zone_height - get_caption_padding_top() - get_caption_padding_bottom();
                draw(this.pic, box((content_left, content_bottom), 
                                  (content_left + content_width, content_bottom + content_height)), 
                     p=dark_blue);
                
                // DEBUG: Draw separator between caption title and text (dark blue)
                real title_width = content_width * this.caption_title_width_factor;
                real separator_x = content_left + title_width;
                draw(this.pic, (separator_x, content_bottom)--(separator_x, content_bottom + content_height), 
                     p=dark_blue);
            }
            
            // DEBUG: Draw black border around overall image
            draw(this.pic, box((0, 0), (this.width, this.height)), p=black + linewidth(3));
        }
        
        // Add diagram at calculated position
        pair diagram_pos = get_diagram_origin();
        add(this.pic, diagram, diagram_pos);
        
        // Render caption
        render_caption();
        
        // Mark as having visual
        this.has_visual = true;
        
        // Auto-render to currentpicture
        if (!this.rendered) {
            add(currentpicture, this.pic);
            this.rendered = true;
        }
    }
    
    // Add RelationDiagram directly
    void add(RelationDiagram diagram) {
        picture diagram_pic = diagram.render(
            get_diagram_width(),
            get_diagram_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }
    
    // Add DiscretePlot directly
    void add(DiscretePlot diagram) {
        picture diagram_pic = diagram.render(
            get_diagram_width(),
            get_diagram_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add Plot directly
    void add(Plot diagram) {
        picture diagram_pic = diagram.render(
            get_diagram_width(),
            get_diagram_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add AccumulationTable directly
    void add(AccumulationTable table) {
        picture diagram_pic = table.render(
            get_diagram_width(),
            get_diagram_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }

    // Add TruthTable directly
    void add(TruthTable table) {
        picture diagram_pic = table.render(
            get_diagram_width(),
            get_diagram_height(),
            diagram_unit
        );
        add_visual(diagram_pic);
    }
};

