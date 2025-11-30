///////////////////////////////////////////////////////////////////////////////////////////////////
// RelationDiagram - Visual representation of relations between sets
// 
// Note: This file expects the following variables to be defined in the including scope:
//   - header_2, text_normal (TypographyPen structs)
//   - function_thickness, ray_arrow, ray_beginning (arrow styling)
//   - set_boundary_margin (margin from set boundaries for lines)
//   - diagram_unit (unit size for diagrams, passed via render() method)
//   - set_text_width() function (from Utilities/TextSetWidth.asy)
//   - estimate_text_width() function (from Utilities/TextSetWidth.asy)
///////////////////////////////////////////////////////////////////////////////////////////////////

struct RelationDiagram {
    // Internal state
    string[][] sets;
    string[] set_names;
    real[] set_widths;  // User-specified widths for each set
    int num_sets;
    pair[][][] relations;  // relations[from][to] = array of pairs
    
    // Debug mode
    bool debug_mode;
    
    // Layout state (calculated during render)
    pair[][] set_positions;
    pair[][] element_positions;
    real[] set_left_edges;  // Left edge of each set
    real[] set_right_edges;  // Right edge of each set
    real label_zone_bottom;  // Bottom of label zone
    real label_zone_top;  // Top of label zone
    real element_zone_bottom;  // Bottom of element zone
    real element_zone_top;  // Top of element zone
    
    // Constructor - empty diagram
    void operator init() {
        this.sets = new string[][];
        this.set_names = new string[];
        this.set_widths = new real[];
        this.num_sets = 0;
        this.relations = new pair[][][];
        this.set_positions = new pair[][];
        this.element_positions = new pair[][];
        this.set_left_edges = new real[];
        this.set_right_edges = new real[];
        this.debug_mode = false;
    }
    
    // Constructor - initialize with sets
    void operator init(string[][] sets, string[] names = new string[] {}) {
        // Count sets manually (Asymptote doesn't have length() for 2D arrays)
        this.num_sets = 0;
        for (string[] s : sets) {
            this.num_sets = this.num_sets + 1;
        }
        
        this.sets = sets;
        
        // Initialize set names
        this.set_names = new string[this.num_sets];
        int name_count = 0;
        for (string n : names) {
            name_count = name_count + 1;
        }
        
        for (int i = 0; i < this.num_sets; ++i) {
            if (i < name_count) {
                this.set_names[i] = names[i];
            } else {
                this.set_names[i] = "";
            }
        }
        
        // Initialize relations array
        this.relations = new pair[][][];
        for (int i = 0; i < this.num_sets; ++i) {
            this.relations[i] = new pair[][];
            for (int j = 0; j < this.num_sets; ++j) {
                this.relations[i][j] = new pair[];
            }
        }
        
        this.set_positions = new pair[][];
        this.element_positions = new pair[][];
        this.set_left_edges = new real[];
        this.set_right_edges = new real[];
        this.debug_mode = false;
        
        // Initialize set widths (default: auto-calculate)
        this.set_widths = new real[this.num_sets];
        for (int i = 0; i < this.num_sets; ++i) {
            this.set_widths[i] = 0;  // 0 means auto-calculate
        }
    }
    
    // Add a set with elements (and optional name and width)
    void add_set(string[] elements, string name = "", real width = 0) {
        this.sets.push(elements);
        this.set_names.push(name);
        this.set_widths.push(width);  // 0 means auto-calculate
        this.num_sets = this.num_sets + 1;
        
        // Expand relations array
        pair[][][] new_relations = new pair[][][];
        for (int i = 0; i < this.num_sets; ++i) {
            new_relations[i] = new pair[][];
            for (int j = 0; j < this.num_sets; ++j) {
                if (i < this.num_sets - 1 && j < this.num_sets - 1) {
                    new_relations[i][j] = this.relations[i][j];
                } else {
                    new_relations[i][j] = new pair[];
                }
            }
        }
        this.relations = new_relations;
    }
    
    // Add multiple sets at once
    void add_sets(string[][] sets, string[] names = new string[] {}, real[] widths = new real[] {}) {
        int set_count = 0;
        for (string[] s : sets) {
            set_count = set_count + 1;
        }
        
        int name_count = 0;
        for (string n : names) {
            name_count = name_count + 1;
        }
        
        int width_count = 0;
        for (real w : widths) {
            width_count = width_count + 1;
        }
        
        int i = 0;
        for (string[] s : sets) {
            string name = "";
            if (i < name_count) {
                name = names[i];
            }
            real width = 0;
            if (i < width_count) {
                width = widths[i];
            }
            add_set(s, name, width);
            i = i + 1;
        }
    }
    
    // Set width for a specific set (by index)
    void set_width(int set_index, real width) {
        if (set_index < 0 || set_index >= this.num_sets) {
            abort("RelationDiagram.set_width: Invalid set index " + (string)set_index);
        }
        this.set_widths[set_index] = width;
    }
    
    // Enable or disable debug mode
    void set_debug_mode(bool enabled) {
        this.debug_mode = enabled;
    }
    
    // Helper: Count elements in a string array
    int count_elements(string[] arr) {
        int count = 0;
        for (string s : arr) {
            count = count + 1;
        }
        return count;
    }
    
    // Helper: Count pairs in a pair array
    int count_pairs(pair[] arr) {
        int count = 0;
        for (pair p : arr) {
            count = count + 1;
        }
        return count;
    }
    
    // Add relation from set at index from_set to set at index to_set
    void add_relation(int from_set, int to_set, pair[] pairs) {
        // Validate indices
        if (from_set < 0 || from_set >= this.num_sets) {
            abort("RelationDiagram.add_relation: Invalid from_set index " + (string)from_set);
        }
        if (to_set < 0 || to_set >= this.num_sets) {
            abort("RelationDiagram.add_relation: Invalid to_set index " + (string)to_set);
        }
        
        // Count elements in source and target sets
        int src_count = count_elements(this.sets[from_set]);
        int tgt_count = count_elements(this.sets[to_set]);
        
        // Validate pair indices
        int pair_count = count_pairs(pairs);
        for (int i = 0; i < pair_count; ++i) {
            int src_idx = (int)pairs[i].x;
            int tgt_idx = (int)pairs[i].y;
            if (src_idx < 0 || src_idx >= src_count) {
                abort("RelationDiagram.add_relation: Invalid source element index " + (string)src_idx + " for set " + (string)from_set);
            }
            if (tgt_idx < 0 || tgt_idx >= tgt_count) {
                abort("RelationDiagram.add_relation: Invalid target element index " + (string)tgt_idx + " for set " + (string)to_set);
            }
        }
        
        // Store relation
        this.relations[from_set][to_set] = pairs;
    }
    
    // Calculate layout (set positions, element positions)
    void calculate_layout(real width, real height, real unit) {
        if (this.num_sets == 0) return;
        
        // Zone definitions
        // In Asymptote, y=0 is at bottom, y=height is at top
        real label_zone_height = 2.0;  // Fixed height of 2.0 for labels
        real element_zone_height = height - label_zone_height;  // Remaining height for elements
        this.label_zone_bottom = element_zone_height;  // Bottom of label zone (top of element zone)
        this.label_zone_top = height;  // Top of label zone (top of diagram)
        real element_zone_top = this.label_zone_bottom;  // Top of element zone
        real element_zone_bottom = 0;  // Bottom of element zone (bottom of diagram)
        
        // Store element zone boundaries for debug visualization
        this.element_zone_top = element_zone_top;
        this.element_zone_bottom = element_zone_bottom;
        
        // Calculate set widths (auto-calculate if not specified)
        real[] effective_widths = new real[this.num_sets];
        for (int i = 0; i < this.num_sets; ++i) {
            if (this.set_widths[i] > 0) {
                effective_widths[i] = this.set_widths[i];
            } else {
                // Auto-calculate based on widest element only
                // Set names are in a different zone (label zone), so they don't affect element zone width
                // Use set_text_width function to calculate width needed for element labels
                real element_width = set_text_width(this.sets[i], text_normal);
                
                // Use calculated width directly, no padding
                effective_widths[i] = element_width;
            }
        }
        
        // Calculate total width of all sets
        real total_sets_width = 0;
        for (int i = 0; i < this.num_sets; ++i) {
            total_sets_width = total_sets_width + effective_widths[i];
        }
        
        // Calculate spacing between sets (evenly distribute remaining space)
        real spacing = 0;
        if (this.num_sets > 1) {
            spacing = (width - total_sets_width) / (this.num_sets - 1);
        }
        
        // Calculate set positions (evenly distributed, first at left, last at right)
        this.set_left_edges = new real[this.num_sets];
        this.set_right_edges = new real[this.num_sets];
        real[] set_center_x = new real[this.num_sets];
        real current_x = 0;  // Start at left edge
        
        for (int i = 0; i < this.num_sets; ++i) {
            this.set_left_edges[i] = current_x;
            this.set_right_edges[i] = current_x + effective_widths[i];
            set_center_x[i] = current_x + effective_widths[i] / 2.0;
            current_x = current_x + effective_widths[i] + spacing;
        }
        
        // Calculate set and element positions
        this.set_positions = new pair[][];
        this.element_positions = new pair[][];
        
        for (int i = 0; i < this.num_sets; ++i) {
            int num_elements = count_elements(this.sets[i]);
            
            // Set position (center x, vertically centered in label zone)
            real label_zone_center = label_zone_bottom + label_zone_height / 2.0;
            pair set_pos = (set_center_x[i], label_zone_center);
            this.set_positions[i] = new pair[] {set_pos};
            
            // Element positions (evenly distributed in element zone)
            // Element zone is from 0 to height*0.80
            pair[] elem_positions = new pair[];
            if (num_elements > 0) {
                if (num_elements == 1) {
                    // Single element: center of element zone
                    elem_positions.push((set_center_x[i], element_zone_bottom + element_zone_height / 2.0));
                } else {
                    // Multiple elements: evenly distributed from top to bottom
                    // First element at top of element zone, last at bottom
                    real element_spacing = element_zone_height / (num_elements - 1);
                    for (int j = 0; j < num_elements; ++j) {
                        real y_pos = element_zone_top - (j * element_spacing);
                        elem_positions.push((set_center_x[i], y_pos));
                    }
                }
            }
            this.element_positions[i] = elem_positions;
        }
    }
    
    // Calculate arrow offsets for overlapping targets
    pair[] calculate_arrow_offsets(int from_set, int to_set, pair[] pairs) {
        int pair_count = count_pairs(pairs);
        if (pair_count == 0) return new pair[];
        
        int tgt_count = count_elements(this.sets[to_set]);
        
        // Group pairs by target element
        int[] target_counts = new int[tgt_count];
        for (int i = 0; i < tgt_count; ++i) {
            target_counts[i] = 0;
        }
        
        for (int i = 0; i < pair_count; ++i) {
            int tgt_idx = (int)pairs[i].y;
            if (tgt_idx < tgt_count) {
                target_counts[tgt_idx] = target_counts[tgt_idx] + 1;
            }
        }
        
        // Calculate offsets for each target
        real offset_amount = 0.15;  // Base offset amount
        pair[] offsets = new pair[pair_count];
        int[] target_indices = new int[tgt_count];
        for (int i = 0; i < tgt_count; ++i) {
            target_indices[i] = 0;
        }
        
        for (int i = 0; i < pair_count; ++i) {
            int tgt_idx = (int)pairs[i].y;
            if (tgt_idx >= tgt_count) {
                offsets[i] = (0, 0);
                continue;
            }
            int count = target_counts[tgt_idx];
            int index = target_indices[tgt_idx];
            
            // Calculate symmetric offset
            real offset = 0;
            if (count > 1) {
                real spacing = offset_amount * 2.0 / (count + 1);
                offset = -offset_amount + spacing * (index + 1);
            }
            
            offsets[i] = (offset, 0);
            target_indices[tgt_idx] = target_indices[tgt_idx] + 1;
        }
        
        return offsets;
    }
    
    // Draw sets (labels and elements)
    void draw_sets(picture pic, real unit) {
        for (int i = 0; i < this.num_sets; ++i) {
            pair set_pos = this.set_positions[i][0];
            
            // Draw set name if provided (in label zone, centered)
            if (this.set_names[i] != "") {
                label(pic, this.set_names[i], set_pos, 
                      align=Center, p=header_2.p);
            }
            
            // Draw element labels (in element zone, positioned just inside left border of debug box)
            int j = 0;
            for (pair elem_pos : this.element_positions[i]) {
                // Estimate label width and push right by half (since center-aligned)
                // This positions the left edge of the label at the border
                real estimated_label_width = length(this.sets[i][j]) * text_normal.char_width_estimate;
                real offset = estimated_label_width / 2.0;  // Half width for center alignment
                pair label_pos = (this.set_left_edges[i] + offset, elem_pos.y);
                label(pic, this.sets[i][j], label_pos, align=Center, p=text_normal.p);
                j = j + 1;
            }
        }
    }
    
    // Draw arrows with offset support
    // Style: dot at source, small horizontal line, diagonal connection, small horizontal line, arrow at target
    void draw_arrows(picture pic, real unit, real width) {
        real element_margin = 0.35;  // Margin from element labels for horizontal segments
        // Horizontal line length is 5% of diagram width, capped at 0.5 units
        real horizontal_length = min(0.5, width * 0.05);
        
        for (int i = 0; i < this.num_sets; ++i) {
            for (int j = 0; j < this.num_sets; ++j) {
                pair[] pairs = this.relations[i][j];
                int pair_count = count_pairs(pairs);
                if (pair_count == 0) continue;
                
                // Calculate offsets for overlapping targets
                pair[] offsets = calculate_arrow_offsets(i, j, pairs);
                
                int src_count = count_elements(this.sets[i]);
                int tgt_count = count_elements(this.sets[j]);
                
                // Determine direction (left to right or right to left)
                bool left_to_right = (i < j);
                
                // Draw each arrow
                int k = 0;
                for (pair p : pairs) {
                    int src_idx = (int)p.x;
                    int tgt_idx = (int)p.y;
                    
                    if (src_idx >= src_count || tgt_idx >= tgt_count) {
                        k = k + 1;
                        continue;
                    }
                    
                    if (src_idx >= count_pairs(this.element_positions[i]) || 
                        tgt_idx >= count_pairs(this.element_positions[j])) {
                        k = k + 1;
                        continue;
                    }
                    
                    pair src_elem_pos = this.element_positions[i][src_idx];
                    pair tgt_elem_pos = this.element_positions[j][tgt_idx];
                    
                    // Apply offset
                    pair offset = offsets[k];
                    pair adjusted_src_elem = src_elem_pos + offset;
                    pair adjusted_tgt_elem = tgt_elem_pos + offset;
                    
                    // Calculate points for the connection style:
                    // 1. Dot at source (pushed away from label)
                    // 2. Small horizontal line from dot (protruding from element)
                    // 3. Diagonal line connecting the two horizontal segments
                    // 4. Small horizontal line to target element
                    // 5. Arrow at the end
                    pair dot_pos, src_horiz_start, src_horiz_end, tgt_horiz_start, tgt_horiz_end;
                    
                    if (left_to_right) {
                        // From left set to right set
                        // Dot is pushed to the right of the element label
                        dot_pos = (adjusted_src_elem.x + element_margin, adjusted_src_elem.y);
                        src_horiz_start = dot_pos;
                        src_horiz_end = (adjusted_src_elem.x + element_margin + horizontal_length, adjusted_src_elem.y);
                        // Target horizontal line is pushed to the left of the element label
                        tgt_horiz_start = (adjusted_tgt_elem.x - element_margin - horizontal_length, adjusted_tgt_elem.y);
                        tgt_horiz_end = (adjusted_tgt_elem.x - element_margin, adjusted_tgt_elem.y);
                    } else {
                        // From right set to left set
                        // Dot is pushed to the left of the element label
                        dot_pos = (adjusted_src_elem.x - element_margin, adjusted_src_elem.y);
                        src_horiz_start = dot_pos;
                        src_horiz_end = (adjusted_src_elem.x - element_margin - horizontal_length, adjusted_src_elem.y);
                        // Target horizontal line is pushed to the right of the element label
                        tgt_horiz_start = (adjusted_tgt_elem.x + element_margin + horizontal_length, adjusted_tgt_elem.y);
                        tgt_horiz_end = (adjusted_tgt_elem.x + element_margin, adjusted_tgt_elem.y);
                    }
                    
                    // Draw dot at source (away from label)
                    dot(pic, dot_pos, p=ray_beginning);
                    
                    // Draw small horizontal line from dot (no arrow)
                    draw(pic, src_horiz_start--src_horiz_end, p=function_thickness);
                    
                    // Draw diagonal line connecting the two horizontal segments (no arrow)
                    draw(pic, src_horiz_end--tgt_horiz_start, p=function_thickness);
                    
                    // Draw small horizontal line to target with arrow at end
                    draw(pic, tgt_horiz_start--tgt_horiz_end, 
                         p=function_thickness, arrow=ray_arrow);
                    
                    k = k + 1;
                }
            }
        }
    }
    
    // Draw debug visualization (boxes and lines)
    void draw_debug(picture pic, real unit, real width, real height) {
        if (!this.debug_mode) return;
        
        // Use a light gray pen for debug lines
        pen debug_pen = gray + linewidth(0.5);
        
        // Draw horizontal line separating label zone from element zone
        // Clamp to actual diagram width
        real diagram_width = min(width, this.set_right_edges[this.num_sets - 1]);
        draw(pic, (0, this.label_zone_bottom)--(diagram_width, this.label_zone_bottom), p=debug_pen);
        
        // Draw boxes around each set's element zone and vertical dividers
        for (int i = 0; i < this.num_sets; ++i) {
            real left_edge = this.set_left_edges[i];
            real right_edge = min(this.set_right_edges[i], width);  // Clamp to diagram width
            real bottom = this.element_zone_bottom;
            real top = this.element_zone_top;
            
            // Only draw if within diagram bounds
            if (left_edge <= width) {
                // Draw box around element zone
                path element_box = (left_edge, bottom)--(right_edge, bottom)--
                                  (right_edge, top)--(left_edge, top)--cycle;
                draw(pic, element_box, p=debug_pen);
                
                // Draw vertical divider at right edge of set (except for last set)
                if (i < this.num_sets - 1 && right_edge <= width) {
                    draw(pic, (right_edge, 0)--(right_edge, height), p=debug_pen);
                }
            }
        }
    }
    
    // Render the diagram to a picture
    picture render(real width, real height, real unit) {
        picture pic = new picture;
        unitsize(pic, unit);
        
        if (this.num_sets == 0) {
            return pic;
        }
        
        // Calculate layout
        calculate_layout(width, height, unit);
        
        // Draw sets
        draw_sets(pic, unit);
        
        // Draw arrows
        draw_arrows(pic, unit, width);
        
        // Draw debug visualization if enabled
        draw_debug(pic, unit, width, height);
        
        return pic;
    }
};

