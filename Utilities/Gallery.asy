///////////////////////////////////////////////////////////////////////////////////////////////////
// Gallery - Grid layout for multiple visuals with captions
// 
// Note: This file expects the following to be defined in the including scope:
//   - text_normal, text_small (typography pens)
//   - wrap_text() function (from Utilities/TextWrapping.asy)
//   - RelationDiagram struct (from Visualizations/RelationDiagram.asy)
//   - diagram_unit (real, unit size for diagrams)
///////////////////////////////////////////////////////////////////////////////////////////////////

struct GalleryCell {
    picture visual;
    string caption_label;
    bool has_visual;
    
    void operator init() {
        this.visual = new picture;
        this.caption_label = "";
        this.has_visual = false;
    }
}

struct Gallery {
    // Grid dimensions
    int rows;
    int cols;
    
    // Visual dimensions (same for all cells)
    real visual_width;
    real visual_height;
    
    // Gallery-wide spacing
    real margin;
    real padding;
    
    // Caption configuration
    real caption_height;  // Height for gallery caption zone
    real cell_caption_height;  // Height for individual cell captions
    real caption_title_width_factor;
    string caption_title_text;
    string caption_text_text;
    
    // Styling
    pen background_color;
    
    // Internal state
    GalleryCell[][] cells;
    picture pic;
    bool rendered;
    bool debug_mode;
    
    // Constructor
    void operator init(int rows, int cols, real visual_width = 5, real visual_height = 4) {
        this.rows = rows;
        this.cols = cols;
        this.visual_width = visual_width;
        this.visual_height = visual_height;
        
        // Defaults
        this.margin = 0.5;
        this.padding = 0.3;
        this.caption_height = 0.8;  // Gallery caption zone height
        this.cell_caption_height = 0.8;  // Individual cell caption height
        this.caption_title_width_factor = 0.2;
        this.caption_title_text = "";
        this.caption_text_text = "";
        this.background_color = white;
        this.debug_mode = false;
        
        // Initialize cell grid
        this.cells = new GalleryCell[rows][cols];
        for (int i = 0; i < rows; ++i) {
            for (int j = 0; j < cols; ++j) {
                this.cells[i][j] = GalleryCell();
            }
        }
        
        // Internal state
        this.pic = new picture;
        unitsize(this.pic, 1cm);
        this.rendered = false;
        
        settings.outformat = "svg";
    }
    
    // Setters
    void set_margin(real m) {
        this.margin = m;
    }
    
    void set_padding(real p) {
        this.padding = p;
    }
    
    void set_caption_height(real h) {
        this.caption_height = h;
    }
    
    void set_cell_caption_height(real h) {
        this.cell_caption_height = h;
    }
    
    void set_caption_title_width_factor(real f) {
        this.caption_title_width_factor = f;
    }
    
    void set_background_color(pen color) {
        this.background_color = color;
    }
    
    // Debug mode
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
    
    // Helper: Check if gallery has caption
    bool has_caption() {
        return length(this.caption_title_text) > 0 || length(this.caption_text_text) > 0;
    }
    
    // Helper: Calculate cell dimensions
    real get_cell_width() {
        // Total gallery width = sum of cell widths + (cols-1) * spacing + 2*margin
        // We need to calculate spacing between cells
        // For now, assume even distribution - we'll calculate this in render
        return this.visual_width + 2 * this.padding;
    }
    
    real get_cell_height() {
        // Cell height = visual height + cell caption height + 2 * padding
        return this.visual_height + this.cell_caption_height + 2 * this.padding;
    }
    
    // Helper: Calculate total gallery dimensions
    real get_total_width() {
        // Total width = cols * cell_width + (cols-1) * spacing + 2*margin
        // For even distribution, spacing = (available_width - cols*cell_width) / (cols-1)
        // But we need to know available width first... 
        // Actually, we'll calculate this during render based on cell positions
        real cell_width = get_cell_width();
        real total_cells_width = this.cols * cell_width;
        // Estimate spacing (will be recalculated in render)
        real estimated_spacing = 0.5;
        return total_cells_width + (this.cols - 1) * estimated_spacing + 2 * this.margin;
    }
    
    real get_total_height() {
        real cell_height = get_cell_height();
        real total_cells_height = this.rows * cell_height;
        // Estimate spacing (will be recalculated in render)
        real estimated_spacing = 0.5;
        return total_cells_height + (this.rows - 1) * estimated_spacing + 2 * this.margin;
    }
    
    // Render gallery caption (below the entire gallery)
    void render_gallery_caption(real total_width, real gallery_content_height, real caption_zone_height) {
        if (!has_caption()) return;
        
        // Caption zone is below the gallery content (at y=0 to y=caption_zone_height)
        real caption_zone_bottom = 0;
        real caption_zone_top = caption_zone_bottom + caption_zone_height;
        real caption_zone_width = total_width;
        
        // Caption content area (after padding)
        real content_left = this.margin;
        real content_bottom = caption_zone_bottom + this.padding;
        real content_width = caption_zone_width - 2 * this.margin;
        real content_height = caption_zone_height - 2 * this.padding;
        
        // Position at top of content area, but push down slightly to avoid border cutting text
        // In Asymptote, y increases upward, so we subtract a small offset from the top
        real text_baseline_offset = 0.2;  // Offset to push text down from top border
        real content_top_y = content_bottom + content_height - text_baseline_offset;
        
        // Split content width
        real title_width = content_width * this.caption_title_width_factor;
        real text_width = content_width * (1.0 - this.caption_title_width_factor);
        
        // Add small spacing before separator
        real separator_spacing = 0.03;
        
        // Render title: right-aligned, ending slightly left of separator, just below top border
        real title_y = content_top_y;  // Position just below top border
        if (length(this.caption_title_text) > 0) {
            real title_x = content_left + title_width - separator_spacing;
            label(this.pic, this.caption_title_text, 
                  (title_x, title_y), 
                  align=W, p=text_normal.p);
        }
        
        // Render text: left-aligned, starting at separator (with wrapping)
        if (length(this.caption_text_text) > 0) {
            // Wrap text to fit within available width
            string[] text_lines = wrap_text(this.caption_text_text, text_width, text_normal);
            
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
                      align=E, p=text_normal.p);
            }
        }
    }
    
    // Render caption for a cell
    void render_cell_caption(picture pic, real cell_x, real cell_y, real cell_width, int row, int col) {
        // Access cell directly to avoid copying struct
        string caption_label = this.cells[row][col].caption_label;
        
        if (length(caption_label) == 0) {
            return;
        }
        
        // Caption zone is at bottom of cell
        real caption_zone_bottom = cell_y;
        real caption_zone_top = cell_y + this.cell_caption_height;
        real caption_zone_width = cell_width;
        
        // Caption content area (after padding)
        real content_left = cell_x + this.padding;
        real content_bottom = caption_zone_bottom + this.padding;
        real content_width = caption_zone_width - 2 * this.padding;
        real content_height = this.cell_caption_height - 2 * this.padding;
        
        // Center vertically in content area
        // text_small font size is 0.45cm, but actual rendered height is typically ~0.5cm
        // Text extends above and below the baseline, so we adjust slightly to keep it within bounds
        // Position slightly above center to account for text extending above baseline
        real estimated_text_height = 0.5;  // Estimated actual rendered height for 0.45cm font
        real content_y = content_bottom + content_height / 2.0 + estimated_text_height / 4.0;
        
        // Center horizontally in content area
        real content_center_x = content_left + content_width / 2.0;
        
        // Render label: centered both horizontally and vertically
        if (length(caption_label) > 0) {
            label(pic, caption_label, 
                  (content_center_x, content_y), 
                  align=Center, p=text_small.p);
        }
    }
    
    // Add visual to a cell (from RelationDiagram)
    void add(RelationDiagram diagram, int row, int col, string caption_label = "") {
        if (row < 0 || row >= this.rows) {
            abort("Gallery.add: Invalid row index " + (string)row);
        }
        if (col < 0 || col >= this.cols) {
            abort("Gallery.add: Invalid column index " + (string)col);
        }
        
        // Render diagram to picture
        picture diagram_pic = diagram.render(
            this.visual_width,
            this.visual_height,
            diagram_unit
        );
        
        // Store in cell
        this.cells[row][col].visual = diagram_pic;
        this.cells[row][col].caption_label = caption_label;
        this.cells[row][col].has_visual = true;
        
        // Re-render gallery (will update currentpicture)
        render();
    }
    
    // Add visual to a cell (from picture directly)
    void add(picture pic, int row, int col, string caption_label = "") {
        if (row < 0 || row >= this.rows) {
            abort("Gallery.add: Invalid row index " + (string)row);
        }
        if (col < 0 || col >= this.cols) {
            abort("Gallery.add: Invalid column index " + (string)col);
        }
        
        // Make a copy of the picture when storing it to avoid reference issues
        picture pic_copy = new picture;
        unitsize(pic_copy, 1cm);
        add(pic_copy, pic);
        
        // Store picture copy in cell
        this.cells[row][col].visual = pic_copy;
        this.cells[row][col].caption_label = caption_label;
        this.cells[row][col].has_visual = true;
        
        // Re-render gallery (will update currentpicture)
        // Note: render() must be called explicitly after all add() calls
        // The render() method doesn't complete when called from within add()
        // This is a known Asymptote limitation with method calls
        // For now, we'll rely on explicit render() calls after all add() operations
        // render();
    }
    
    // Render the entire gallery
    void render() {
        // Clear previous render
        this.pic = new picture;
        unitsize(this.pic, 1cm);
        
        // Calculate cell dimensions
        real cell_width = get_cell_width();
        real cell_height = get_cell_height();
        
        // Calculate total space needed for cells
        real total_cells_width = this.cols * cell_width;
        real total_cells_height = this.rows * cell_height;
        
        // Calculate spacing between cells (evenly distribute)
        // For even distribution, we need to determine how much space to allocate
        // We'll use a reasonable total size and calculate spacing to evenly distribute
        // Total width = cols * cell_width + (cols-1) * spacing + 2*margin
        // Solving for spacing: spacing = (total_width - 2*margin - cols*cell_width) / (cols-1)
        // For even distribution, we want spacing to be reasonable (e.g., 0.5-1.0)
        // Let's calculate based on a target spacing
        real target_horizontal_spacing = 0.5;
        real target_vertical_spacing = 0.5;
        
        real horizontal_spacing = 0;
        real vertical_spacing = 0;
        if (this.cols > 1) {
            horizontal_spacing = target_horizontal_spacing;
        }
        if (this.rows > 1) {
            vertical_spacing = target_vertical_spacing;
        }
        
        // Calculate total gallery dimensions
        real total_width = total_cells_width + (this.cols - 1) * horizontal_spacing + 2 * this.margin;
        real gallery_content_height = total_cells_height + (this.rows - 1) * vertical_spacing + 2 * this.margin;
        
        // Add space for caption if present
        real caption_zone_height = has_caption() ? this.caption_height : 0;
        real total_height = gallery_content_height + caption_zone_height;
        
        // Ensure we have valid dimensions
        if (total_width <= 0 || gallery_content_height <= 0) {
            abort("Gallery has invalid dimensions");
        }
        
        // Draw background (full height including caption area)
        fill(this.pic, box((0, 0), (total_width, total_height)), this.background_color);
        
        // Draw border (full height including caption area)
        draw(this.pic, box((0, 0), (total_width, total_height)), black + linewidth(1));
        
        // Gallery content is shifted up by caption height (if caption exists)
        real gallery_y_offset = caption_zone_height;
        
        // DEBUG: Draw margin area (light red)
        if (this.debug_mode) {
            pen light_red = rgb(1.0, 0.8, 0.8);
            // Margin extends outside the gallery content area
            real margin_left_x = 0;
            real margin_right_x = total_width;
            real margin_bottom_y = 0;
            real margin_top_y = total_height;
            // Draw margin rectangles on all sides
            // Left margin
            fill(this.pic, box((margin_left_x, margin_bottom_y), 
                              (this.margin, margin_top_y)), light_red);
            // Right margin
            fill(this.pic, box((total_width - this.margin, margin_bottom_y), 
                              (margin_right_x, margin_top_y)), light_red);
            // Bottom margin (below gallery content, above caption if exists)
            fill(this.pic, box((this.margin, margin_bottom_y), 
                              (total_width - this.margin, gallery_y_offset)), light_red);
            // Top margin
            fill(this.pic, box((this.margin, gallery_content_height + gallery_y_offset), 
                              (total_width - this.margin, margin_top_y)), light_red);
        }
        
        // Calculate cell positions (evenly distributed)
        // Start from top-left, going down and right
        // Row 0 is at top, row (rows-1) is at bottom
        for (int i = 0; i < this.rows; ++i) {
            for (int j = 0; j < this.cols; ++j) {
                // Calculate cell position
                // Row i: from top, row 0 is at top
                // Col j: from left, col 0 is at left
                real cell_x = this.margin + j * (cell_width + horizontal_spacing);
                // Reverse row calculation: row 0 at top, row (rows-1) at bottom
                // Top row (i=0) should be at: gallery_content_height - margin - cell_height + gallery_y_offset
                // Row i should be at: gallery_content_height - margin - (rows - i) * cell_height - (rows - 1 - i) * vertical_spacing + gallery_y_offset
                real cell_y = gallery_content_height - this.margin - (this.rows - i) * cell_height - (this.rows - 1 - i) * vertical_spacing + gallery_y_offset;
                
                // Reverse row index when accessing cells: cells array is indexed with row 0 at bottom,
                // but we want row 0 to be at top, so access cells[rows-1-i][j]
                int cell_row = this.rows - 1 - i;
                int cell_col = j;
                
                // DEBUG: Draw cell padding area (light green)
                if (this.debug_mode) {
                    pen light_green = rgb(0.8, 1.0, 0.8);
                    real cell_padding_left = cell_x + this.padding;
                    real cell_padding_right = cell_x + cell_width - this.padding;
                    real cell_padding_bottom = cell_y + this.padding;
                    real cell_padding_top = cell_y + cell_height - this.padding;
                    fill(this.pic, box((cell_padding_left, cell_padding_bottom), 
                                      (cell_padding_right, cell_padding_top)), light_green);
                }
                
                // Access cell directly (don't copy - Asymptote structs are copied by value)
                if (this.cells[cell_row][cell_col].has_visual) {
                    // Calculate visual position (in visual zone, which is above caption)
                    // Cell layout: [caption at bottom] [visual at top]
                    // Visual zone starts above caption
                    real visual_zone_bottom = cell_y + this.cell_caption_height;
                    real visual_zone_top = cell_y + cell_height;
                    real visual_x = cell_x + this.padding;
                    real visual_y = visual_zone_bottom + this.padding;
                    
                    // Add visual (already a copy stored in cell, so safe to use directly)
                    add(this.pic, this.cells[cell_row][cell_col].visual, (visual_x, visual_y));
                    
                    // Render caption (at bottom of cell) - pass cell_row/cell_col to access correct cell
                    render_cell_caption(this.pic, cell_x, cell_y, cell_width, cell_row, cell_col);
                }
            }
        }
        
        // DEBUG: Draw gallery caption zone and areas
        if (this.debug_mode && has_caption()) {
            // Draw caption zone (light blue)
            pen light_blue = rgb(0.8, 0.8, 1.0);
            real caption_zone_bottom = 0;
            real caption_zone_top = caption_zone_height;
            fill(this.pic, box((0, caption_zone_bottom), 
                              (total_width, caption_zone_top)), light_blue);
            
            // Draw caption content area border (dark blue)
            pen dark_blue = rgb(0.0, 0.0, 0.5) + linewidth(2);
            real content_left = this.margin;
            real content_bottom = caption_zone_bottom + this.padding;
            real content_width = total_width - 2 * this.margin;
            real content_height = caption_zone_height - 2 * this.padding;
            draw(this.pic, box((content_left, content_bottom), 
                              (content_left + content_width, content_bottom + content_height)), 
                 p=dark_blue);
            
            // Draw separator between caption title and text (dark blue)
            real title_width = content_width * this.caption_title_width_factor;
            real separator_x = content_left + title_width;
            draw(this.pic, (separator_x, content_bottom)--(separator_x, content_bottom + content_height), 
                 p=dark_blue);
            
            // Draw caption title area (light yellow)
            pen light_yellow = rgb(1.0, 1.0, 0.8);
            fill(this.pic, box((content_left, content_bottom), 
                              (separator_x, content_bottom + content_height)), light_yellow);
            
            // Draw caption content area (light cyan)
            pen light_cyan = rgb(0.8, 1.0, 1.0);
            fill(this.pic, box((separator_x, content_bottom), 
                              (content_left + content_width, content_bottom + content_height)), light_cyan);
        }
        
        // Render gallery caption (below the gallery content)
        if (has_caption()) {
            render_gallery_caption(total_width, gallery_content_height, caption_zone_height);
        }
        
        // Auto-render to currentpicture
        // Always replace currentpicture with fresh gallery render
        // This ensures we don't have duplicates when re-rendering
        currentpicture = new picture;
        unitsize(currentpicture, 1cm);
        
        // Add gallery picture to currentpicture
        // Note: Even if this.pic appears empty, add it anyway - Asymptote will handle it
        add(currentpicture, this.pic);
        this.rendered = true;
    }
};

