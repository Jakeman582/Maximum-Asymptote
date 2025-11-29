///////////////////////////////////////////////////////////////////////////////////////////////////
// RelationDiagram - Visual representation of relations between sets
// 
// Note: This file expects the following variables to be defined in the including scope:
//   - header_2, text_normal (typography pens)
//   - function_thickness, ray_arrow, ray_beginning (arrow styling)
//   - set_boundary_margin (margin from set boundaries for lines)
//   - diagram_unit (unit size for diagrams, passed via render() method)
///////////////////////////////////////////////////////////////////////////////////////////////////

struct RelationDiagram {
    // Internal state
    string[][] sets;
    string[] set_names;
    real[] set_widths;  // User-specified widths for each set
    int num_sets;
    pair[][][] relations;  // relations[from][to] = array of pairs
    
    // Layout state (calculated during render)
    pair[][] set_positions;
    pair[][] element_positions;
    real[] set_left_edges;  // Left edge of each set
    real[] set_right_edges;  // Right edge of each set
    real label_zone_bottom;  // Bottom of label zone
    real label_zone_top;  // Top of label zone
    
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
        
        // Calculate set widths (auto-calculate if not specified)
        real[] effective_widths = new real[this.num_sets];
        for (int i = 0; i < this.num_sets; ++i) {
            if (this.set_widths[i] > 0) {
                effective_widths[i] = this.set_widths[i];
            } else {
                // Auto-calculate based on widest element or set name
                real max_width = 0.5;  // Minimum width
                for (string elem : this.sets[i]) {
                    real label_width = length(elem) * 0.3;
                    max_width = max(max_width, label_width);
                }
                if (this.set_names[i] != "") {
                    real name_width = length(this.set_names[i]) * 0.3;
                    max_width = max(max_width, name_width);
                }
                effective_widths[i] = max_width;
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
                      align=Center, p=header_2);
            }
            
            // Draw element labels (in element zone)
            int j = 0;
            for (pair elem_pos : this.element_positions[i]) {
                label(pic, this.sets[i][j], elem_pos, align=Center, p=text_normal);
                j = j + 1;
            }
        }
    }
    
    // Draw arrows with offset support
    void draw_arrows(picture pic, real unit) {
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
                    
                    // Calculate line start/end points with margin from set boundaries
                    // Always: left end = dot, right end = arrow (regardless of direction)
                    pair left_point, right_point;
                    if (left_to_right) {
                        // From left set to right set
                        left_point = (this.set_right_edges[i] + set_boundary_margin, adjusted_src_elem.y);
                        right_point = (this.set_left_edges[j] - set_boundary_margin, adjusted_tgt_elem.y);
                    } else {
                        // From right set to left set (but we want dot on left, arrow on right)
                        left_point = (this.set_left_edges[j] + set_boundary_margin, adjusted_tgt_elem.y);
                        right_point = (this.set_right_edges[i] - set_boundary_margin, adjusted_src_elem.y);
                    }
                    
                    // Draw dot at left end (use ray_beginning for size)
                    dot(pic, left_point, p=ray_beginning);
                    // Draw line with arrow only at right end (use ray_arrow)
                    draw(pic, left_point--right_point, 
                         p=function_thickness, arrow=ray_arrow);
                    k = k + 1;
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
        draw_arrows(pic, unit);
        
        return pic;
    }
};

