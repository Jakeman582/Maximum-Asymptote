////////////////////////////////////////////////////////////////////////////////////////////////////
// File: SwitchingNetwork.asy
//
// Description:
// Draws a boolean expression as a switching (relay) network: a conjunction (&) becomes two
// sub-networks in series (current must pass through both), a disjunction (|) becomes two
// sub-networks in parallel (current can pass through either), and a variable — negated or not —
// becomes a single switch. Built from a single expression string via SwitchingNetwork's
// constructor; see Utilities/BooleanExpression.asy for the parser and negation-normal-form
// conversion this relies on (only LEAF/AND/OR nodes ever reach the layout code below — a NOT never
// wraps anything but a variable once normalized).
//
// Every switch renders open by default. close("p")/open("p") set a specific atomic proposition's
// state explicitly (last call wins if called more than once for the same variable) -- this affects
// every switch for that variable AND every switch for its negation, drawn as the opposite state,
// since physically the two are wired to the same mechanism (p closed means p is true, which means
// !p is false, so every !p switch in the network is open at the same time).
//
// Layout (measure_node) and drawing (draw_node) are deliberately kept as two separate passes onto
// one shared picture, rather than each node building its own sub-picture that gets merged into its
// parent's via add(dest, src, position): add() resolves src via src.fit(), which sizes labels using
// src's own (never-set) unitsize/xsize/ysize — independently of whatever the final composited
// picture's actual scale is — so a leaf's label ends up positioned inconsistently with its own
// wires once merged into a larger picture (confirmed directly: wires composed correctly under
// nested add() calls, but labels from different leaves collapsed toward the same spot). Every
// draw()/label() call below instead targets the same top-level picture directly, in absolute
// coordinates threaded down through the recursion (x0, y0) — the same approach ContinuousPlot.asy
// uses for its own drawing, which has no such issue since it never nests pictures either.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Pure geometry for a sub-network — no picture. width/height are this subtree's footprint at the
// given scale; center_y is the y-coordinate, relative to this subtree's own local origin, where it
// connects to whatever comes before/after it on both its left (local x=0) and right (local
// x=width) edges. Every leaf, and every series/parallel composition of leaves, has exactly one such
// connection point on each side; that's what makes the series/parallel recursion well-defined at
// every level.
struct NetworkLayout {
    real width;
    real height;
    real center_y;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: measure_node
//
// Description:
// Recursively compute a normalized (LEAF/AND/OR only) ExprNode tree's layout at the given scale,
// without drawing anything.
//
// Inputs:
//    node  - The subtree to measure.
//    scale - Uniform scale factor applied to every size constant, at every level.
//
// Outputs:
//    layout - width/height/center_y for this subtree (see NetworkLayout above).
////////////////////////////////////////////////////////////////////////////////////////////////////
NetworkLayout measure_node(ExprNode node, real scale) {
    NetworkLayout layout;
    if (node.kind == EXPR_LEAF) {
        layout.width = switch_unit_width * scale;
        layout.height = switch_unit_height * scale;
        layout.center_y = layout.height / 2;
    } else if (node.kind == EXPR_AND) {
        NetworkLayout a = measure_node(node.children[0], scale);
        NetworkLayout b = measure_node(node.children[1], scale);
        real max_cy = max(a.center_y, b.center_y);
        layout.width = a.width + b.width;
        layout.height = max(max_cy - a.center_y + a.height, max_cy - b.center_y + b.height);
        layout.center_y = max_cy;
    } else {
        NetworkLayout a = measure_node(node.children[0], scale);
        NetworkLayout b = measure_node(node.children[1], scale);
        real spacing = switch_parallel_spacing * scale;
        layout.width = max(a.width, b.width);
        layout.height = a.height + spacing + b.height;
        layout.center_y = layout.height / 2;
    }
    return layout;
}

// Whether variable `variable`'s switch was explicitly set closed by close()/open() -- looked up in
// the parallel switch_variables/switch_closed arrays SwitchingNetwork.render() passes down through
// draw_node()'s recursion. Not present (no close()/open() call ever named this variable) means open,
// matching the "everything defaults to open" rule.
bool is_variable_closed(string variable, string[] switch_variables, bool[] switch_closed) {
    for (int i = 0; i < switch_variables.length; ++i) {
        if (switch_variables[i] == variable) return switch_closed[i];
    }
    return false;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: draw_node
//
// Description:
// Recursively draw a normalized (LEAF/AND/OR only) ExprNode tree directly onto pic, in absolute
// coordinates — (x0, y0) is where this subtree's own local origin (0, 0) sits in pic.
//
// A leaf draws a horizontal wire with a gap in the middle, the variable's label above it (barred if
// negated), and either a diagonal tick across the gap (open -- the switch doesn't conduct) or a flat
// segment filling the gap (closed -- conducts, reading as an unbroken wire). Which one depends on
// the variable's own state from close()/open() (see is_variable_closed() above) and whether this
// particular leaf is the negated form: a bare "p" leaf is closed exactly when p's state is closed,
// but a "!p" leaf is closed exactly when p's state is open -- the two are wired to the same
// mechanism, so they're always opposite. An AND draws its two children side by side, each vertically
// offset so their connection points land on the same line — the higher of the two center_y values,
// so no offset is ever negative. An OR draws its two children stacked (the first on top) with a gap
// between them, padding whichever is narrower with a plain wire extension (split evenly on both
// ends) so both span the same width, then connects their two connection points with a vertical rail
// on each side.
//
// Inputs:
//    pic              - Picture to draw onto.
//    node             - The subtree to draw.
//    scale            - Uniform scale factor applied to every size constant, at every level.
//    x0               - Absolute x-coordinate of this subtree's own local origin.
//    y0               - Absolute y-coordinate of this subtree's own local origin.
//    switch_variables - Variable names passed to close()/open(), parallel to switch_closed.
//    switch_closed    - Each name's explicitly-set state (true = closed), parallel to switch_variables.
//
// Outputs: None
////////////////////////////////////////////////////////////////////////////////////////////////////
void draw_node(picture pic, ExprNode node, real scale, real x0, real y0,
               string[] switch_variables, bool[] switch_closed) {
    if (node.kind == EXPR_LEAF) {
        real w = switch_unit_width * scale;
        real h = switch_unit_height * scale;
        real cy = y0 + h / 2;
        real tick_h = switch_tick_height * scale;
        real gap = w * 0.25;
        real mid = x0 + w / 2;

        draw(pic, (x0, cy)--(mid - gap / 2, cy), p=switch_thickness);
        draw(pic, (mid + gap / 2, cy)--(x0 + w, cy), p=switch_thickness);

        bool own_state_closed = is_variable_closed(node.variable, switch_variables, switch_closed);
        bool closed = node.negated ? !own_state_closed : own_state_closed;
        if (closed) {
            draw(pic, (mid - gap / 2, cy)--(mid + gap / 2, cy), p=switch_thickness);
        } else {
            draw(pic, (mid - gap / 2, cy)--(mid + gap / 2, cy + tick_h), p=switch_thickness);
        }

        string label_text = node.negated ? ("$\overline{" + node.variable + "}$") : ("$" + node.variable + "$");
        label(pic, label_text, (mid, cy + h * 0.35), p=text_normal);
    } else if (node.kind == EXPR_AND) {
        NetworkLayout a = measure_node(node.children[0], scale);
        NetworkLayout b = measure_node(node.children[1], scale);
        real max_cy = max(a.center_y, b.center_y);
        draw_node(pic, node.children[0], scale, x0, y0 + (max_cy - a.center_y), switch_variables, switch_closed);
        draw_node(pic, node.children[1], scale, x0 + a.width, y0 + (max_cy - b.center_y), switch_variables, switch_closed);
    } else {
        NetworkLayout a = measure_node(node.children[0], scale);
        NetworkLayout b = measure_node(node.children[1], scale);
        real max_width = max(a.width, b.width);
        real spacing = switch_parallel_spacing * scale;

        real a_y0 = y0 + b.height + spacing;   // a on top
        real b_y0 = y0;
        real a_pad = (max_width - a.width) / 2;
        real b_pad = (max_width - b.width) / 2;
        real a_term_y = a_y0 + a.center_y;
        real b_term_y = b_y0 + b.center_y;

        if (a_pad > 0) {
            draw(pic, (x0, a_term_y)--(x0 + a_pad, a_term_y), p=switch_thickness);
            draw(pic, (x0 + a_pad + a.width, a_term_y)--(x0 + max_width, a_term_y), p=switch_thickness);
        }
        if (b_pad > 0) {
            draw(pic, (x0, b_term_y)--(x0 + b_pad, b_term_y), p=switch_thickness);
            draw(pic, (x0 + b_pad + b.width, b_term_y)--(x0 + max_width, b_term_y), p=switch_thickness);
        }
        draw_node(pic, node.children[0], scale, x0 + a_pad, a_y0, switch_variables, switch_closed);
        draw_node(pic, node.children[1], scale, x0 + b_pad, b_y0, switch_variables, switch_closed);

        draw(pic, (x0, a_term_y)--(x0, b_term_y), p=switch_thickness);
        draw(pic, (x0 + max_width, a_term_y)--(x0 + max_width, b_term_y), p=switch_thickness);
    }
}

struct SwitchingNetwork {
    ExprNode _root;   // Normalized (NNF) tree — only LEAF/AND/OR nodes ever appear here
    bool _debug_mode;

    string[] _switch_variables;   // Variables named in a close()/open() call, parallel to _switch_closed.
    bool[] _switch_closed;        // Each one's explicitly-set state (true = closed); last call wins.

    // expression is a programmer-style boolean expression: identifiers, ! (negation, tightest
    // binding), & (conjunction), | (disjunction, loosest binding), and parentheses to override
    // precedence — e.g. "A & (B | !C)". Parsed and converted to negation normal form immediately,
    // so a malformed expression aborts here rather than at render() time.
    void operator init(string expression) {
        this._root = normalize(parse_boolean_expression(expression), false);
        this._debug_mode = false;
        this._switch_variables = new string[];
        this._switch_closed = new bool[];
    }

    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }
    bool get_debug_mode() { return this._debug_mode; }

    // Set atomic proposition `variable`'s switch state -- close(variable) draws every switch for it
    // as closed (and every switch for its negation as open); open(variable) does the reverse. Calling
    // either again for the same variable overrides its previous state. variable must actually appear
    // in the expression this network was built from.
    void set_switch_state(string variable, bool closed) {
        string[] known_variables = collect_variables(this._root);
        bool found = false;
        for (int i = 0; i < known_variables.length; ++i) {
            if (known_variables[i] == variable) { found = true; break; }
        }
        if (!found) {
            abort("SwitchingNetwork.close/open: '" + variable + "' is not an atomic proposition in this network");
        }

        for (int i = 0; i < this._switch_variables.length; ++i) {
            if (this._switch_variables[i] == variable) {
                this._switch_closed[i] = closed;
                return;
            }
        }
        this._switch_variables.push(variable);
        this._switch_closed.push(closed);
    }

    void close(string variable) { this.set_switch_state(variable, true); }
    void open(string variable) { this.set_switch_state(variable, false); }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Measure the network once at natural size (scale=1) to compute the uniform scale that fits it
    // (plus its input/output leads) into the given width/height, then draw it once at that scale —
    // the same two-pass approach ContinuousPlot uses for its own letterboxing.
    //
    // Inputs:
    //    width  - Available width in the given unit.
    //    height - Available height in the given unit.
    //    unit   - Unit size for the returned picture.
    //
    // Outputs:
    //    pic - The rendered picture containing the network, centered in width x height.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    picture render(real width, real height, real unit = diagram_unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        NetworkLayout natural = measure_node(this._root, 1);
        real natural_total_width = natural.width + 2 * switch_lead_length;

        real net_scale = 1;
        if (natural_total_width > 0 && natural.height > 0) {
            net_scale = min(width / natural_total_width, height / natural.height);
        }
        NetworkLayout net = measure_node(this._root, net_scale);

        real lead = switch_lead_length * net_scale;
        real total_width = net.width + 2 * lead;
        real offset_x = (width - total_width) / 2;
        real offset_y = (height - net.height) / 2;
        real term_y = offset_y + net.center_y;

        // Input/output leads: short straight stubs before and after the network itself, so it
        // doesn't look like it starts and ends mid-switch — each capped with a filled terminal dot
        // marking the network's two overall connection points.
        real terminal_r = switch_terminal_radius * net_scale;
        draw(pic, (offset_x, term_y)--(offset_x + lead, term_y), p=switch_thickness);
        draw_node(pic, this._root, net_scale, offset_x + lead, offset_y, this._switch_variables, this._switch_closed);
        draw(pic, (offset_x + lead + net.width, term_y)--(offset_x + total_width, term_y),
             p=switch_thickness);
        filldraw(pic, circle((offset_x, term_y), terminal_r), black, switch_thickness);
        filldraw(pic, circle((offset_x + total_width, term_y), terminal_r), black, switch_thickness);

        if (this._debug_mode) {
            draw(pic, box((0, 0), (width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};
