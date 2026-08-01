////////////////////////////////////////////////////////////////////////////////////////////////////
// File: GraphDiagram.asy
//
// Description:
// Graph-theory diagram: vertices and edges, drawn without the caller ever supplying a coordinate.
// Add vertices by name and edges by vertex name, pick a layout (or accept the default), and
// Utilities/GraphLayout.asy computes every position — see that file for the algorithms and for the
// FORCE/CIRCULAR/TREE/BIPARTITE/LAYERED/GRID/PLANAR constants.
//
// Supports directed edges (arrowheads), edge labels (weights), self-loops, and parallel edges
// between the same pair of vertices, which are bowed apart so they stay individually visible.
//
// "Graph" is a type alias for this struct (see the bottom of this file) — most callers should just
// use Graph; GraphDiagram is the canonical name.
////////////////////////////////////////////////////////////////////////////////////////////////////

struct GraphDiagram {
    // One edge. Parallel edges (same endpoints) and self-loops (from == to) are both allowed; the
    // renderer separates them visually rather than the data model forbidding them.
    struct GraphEdge {
        int from_vertex;
        int to_vertex;
        string label;   // Weight or annotation drawn beside the edge; "" draws nothing
    }

    string[] _vertex_labels;
    GraphEdge[] _edges;

    bool _directed;
    string _layout;

    // Layout-specific inputs, each only consulted by the layout that needs it. Stored as vertex
    // labels rather than indices so they stay meaningful if set before the vertices are added.
    string _root;          // TREE
    string _source;        // LAYERED
    int _grid_rows;        // GRID
    int _grid_cols;        // GRID
    string[] _outer_face;  // PLANAR
    int _seed;             // RANDOM

    bool _debug_mode;
    bool _uniform_vertex_size;
    bool _avoid_vertex_overlap;

    void operator init() {
        this._vertex_labels = new string[0];
        this._edges = new GraphEdge[0];
        this._directed = false;
        this._layout = FORCE;
        this._root = "";
        this._source = "";
        this._grid_rows = 0;
        this._grid_cols = 0;
        this._outer_face = new string[0];
        this._seed = graph_random_seed;
        this._debug_mode = false;
        this._uniform_vertex_size = false;
        this._avoid_vertex_overlap = true;
    }

    // Index of a vertex by label, or -1 if there is no such vertex. Linear search: graphs in a
    // course setting are small, and this keeps vertices addressable by name with no extra bookkeeping
    // for the caller.
    int index_of(string label) {
        for (int i = 0; i < this._vertex_labels.length; ++i) {
            if (this._vertex_labels[i] == label) return i;
        }
        return -1;
    }

    // Add a vertex. Re-adding an existing label is a no-op, so add_edge() below can safely
    // auto-create endpoints without the caller tracking which names already exist.
    void add_vertex(string label) {
        if (index_of(label) != -1) return;
        this._vertex_labels.push(label);
    }

    // Add an edge between two vertices, creating either endpoint if it doesn't exist yet — so a
    // graph can be specified purely as an edge list, with no separate add_vertex() calls at all.
    //
    // label is drawn beside the edge (a weight, a capacity, a name); omit it for an unlabeled edge.
    // A self-loop (from == to) is drawn as a loop at that vertex. Repeating the same pair adds a
    // parallel edge, drawn bowed away from its siblings.
    void add_edge(string from_label, string to_label, string label = "") {
        add_vertex(from_label);
        add_vertex(to_label);
        GraphEdge edge;
        edge.from_vertex = index_of(from_label);
        edge.to_vertex = index_of(to_label);
        edge.label = label;
        this._edges.push(edge);
    }

    // Getters
    int get_vertex_count() { return this._vertex_labels.length; }
    int get_edge_count() { return this._edges.length; }
    bool get_directed() { return this._directed; }
    string get_layout() { return this._layout; }
    bool get_debug_mode() { return this._debug_mode; }

    // Draw every edge with an arrowhead at its target end. Graph-wide rather than per-edge, matching
    // the usual convention that a graph is either directed or undirected.
    void set_directed(bool directed) { this._directed = directed; }

    // Choose the placement algorithm: one of FORCE (the default), CIRCULAR, TREE, BIPARTITE,
    // LAYERED, GRID, PLANAR, or RANDOM. Validated here so a typo fails immediately, with the valid
    // names listed, rather than silently drawing the default layout.
    void set_layout(string layout) {
        if (layout != FORCE && layout != CIRCULAR && layout != TREE && layout != BIPARTITE
            && layout != LAYERED && layout != GRID && layout != PLANAR && layout != RANDOM) {
            abort("GraphDiagram.set_layout: unknown layout '" + layout
                  + "'. Expected one of FORCE, CIRCULAR, TREE, BIPARTITE, LAYERED, GRID, PLANAR, RANDOM.");
        }
        this._layout = layout;
    }

    // TREE only: which vertex goes at the top. Defaults to the first vertex added.
    void set_root(string label) { this._root = label; }

    // LAYERED only: which vertex goes in the leftmost layer. Defaults to the first vertex added.
    void set_source(string label) { this._source = label; }

    // GRID only: lattice dimensions. Leave either at 0 to derive it from the vertex count.
    void set_grid_dimensions(int rows, int cols) {
        this._grid_rows = rows;
        this._grid_cols = cols;
    }

    // PLANAR only: the outer face's vertices, in cyclic order around it. Required for that layout —
    // Tutte's embedding pins this face to a polygon and relaxes everything else inside it.
    void set_outer_face(string[] labels) { this._outer_face = labels; }

    // RANDOM only: the seed for the scatter. The same seed always reproduces the same arrangement,
    // so change it to try a different one rather than to make the figure unstable between renders.
    void set_seed(int seed) { this._seed = seed; }
    int get_seed() { return this._seed; }

    // RANDOM only: seed from the current system time instead of a fixed number, so a graph left on
    // this setting draws a different arrangement every time the file is rendered. This deliberately
    // breaks the "same document always renders identically" guarantee set_seed() otherwise gives —
    // reach for it only when that variation is actually wanted (e.g. browsing a few scatters before
    // picking one), and call get_seed() right after to read off whichever seed you land on, so it can
    // be pinned down with set_seed() once you've found an arrangement worth keeping.
    void set_seed_from_time() { this._seed = seconds(); }

    void set_debug_mode(bool enabled) { this._debug_mode = enabled; }

    // Draw every vertex at the same size, rather than each auto-widened just enough for its own
    // label (the default). Off by default so a lone long label (e.g. a multi-digit weight reused as
    // a vertex name) still fits without needing this at all; turn it on for graphs like a tree or
    // cycle where mismatched circle sizes (short names like "L" next to "LA1") read as visually
    // uneven even though every label still fits.
    void set_uniform_vertex_size(bool enabled) { this._uniform_vertex_size = enabled; }
    bool get_uniform_vertex_size() { return this._uniform_vertex_size; }

    // On by default: curve a straight edge around any unrelated vertex it would otherwise pass
    // close to, so the drawing never reads as if that vertex were connected too. Has no effect when
    // nothing is in the way, so it's safe to leave on; turn it off if a particular curve looks worse
    // than the straight line it's avoiding.
    void set_avoid_vertex_overlap(bool enabled) { this._avoid_vertex_overlap = enabled; }
    bool get_avoid_vertex_overlap() { return this._avoid_vertex_overlap; }

    ////////////////////////////////////////////////////////////////////////////////////////////////
    // Function: render
    //
    // Description:
    // Compute vertex positions with the selected layout, then draw the edges and, on top of them,
    // the vertices. Edges are drawn first so that a vertex circle always covers the ends of the
    // edges meeting it; edges are additionally trimmed to each endpoint's rim, which is what puts a
    // directed edge's arrowhead against the circle instead of hidden beneath it.
    //
    // Inputs:
    //    width  - Available width in the given unit.
    //    height - Available height in the given unit.
    //    unit   - Unit size for the returned picture.
    //
    // Outputs:
    //    pic - The rendered picture containing the graph.
    ////////////////////////////////////////////////////////////////////////////////////////////////
    picture render(real width, real height, real unit = diagram_unit) {
        picture pic = new picture;
        unitsize(pic, unit);

        int n = this._vertex_labels.length;
        if (n == 0) return pic;

        // Layout algorithms work on plain index pairs, not the richer edge records.
        int[][] index_edges = new int[this._edges.length][];
        for (int e = 0; e < this._edges.length; ++e) {
            index_edges[e] = new int[] {this._edges[e].from_vertex, this._edges[e].to_vertex};
        }

        int root_index = (this._root == "") ? 0 : index_of(this._root);
        int source_index = (this._source == "") ? 0 : index_of(this._source);
        if (root_index == -1) {
            abort("GraphDiagram.render: set_root('" + this._root + "') names a vertex that doesn't exist.");
        }
        if (source_index == -1) {
            abort("GraphDiagram.render: set_source('" + this._source + "') names a vertex that doesn't exist.");
        }

        pair[] pos;
        if (this._layout == CIRCULAR) {
            pos = graph_layout_circular(n, width, height, graph_layout_margin);
        } else if (this._layout == TREE) {
            pos = graph_layout_tree(n, index_edges, width, height, graph_layout_margin, root_index);
        } else if (this._layout == LAYERED) {
            pos = graph_layout_layered(n, index_edges, width, height, graph_layout_margin, source_index);
        } else if (this._layout == GRID) {
            pos = graph_layout_grid(n, width, height, graph_layout_margin, this._grid_rows, this._grid_cols);
        } else if (this._layout == RANDOM) {
            pos = graph_layout_random(n, width, height, graph_layout_margin, this._seed);
        } else if (this._layout == BIPARTITE) {
            pos = graph_layout_bipartite(n, index_edges, width, height, graph_layout_margin);
            // An empty result means the 2-coloring failed, i.e. the graph contains an odd cycle.
            // Drawing it as two columns anyway would misrepresent it, so this is a hard error.
            if (pos.length == 0) {
                abort("GraphDiagram.render: layout is BIPARTITE but the graph is not bipartite"
                      + " (it contains an odd cycle). Use a different layout, e.g. FORCE.");
            }
        } else if (this._layout == PLANAR) {
            int[] face = new int[this._outer_face.length];
            for (int i = 0; i < this._outer_face.length; ++i) {
                face[i] = index_of(this._outer_face[i]);
                if (face[i] == -1) {
                    abort("GraphDiagram.render: set_outer_face names a vertex that doesn't exist: '"
                          + this._outer_face[i] + "'.");
                }
            }
            pos = graph_layout_planar(n, index_edges, width, height, graph_layout_margin, face);
            if (pos.length == 0) {
                abort("GraphDiagram.render: layout is PLANAR, which needs an outer face of at least"
                      + " 3 vertices — call set_outer_face() with the face's vertices in cyclic order.");
            }
        } else {
            pos = graph_layout_force(n, index_edges, width, height, graph_layout_margin);
        }

        // Per-vertex radius: wide enough for the vertex's own label, never smaller than the theme's
        // base radius. Computed up front because edge trimming below needs each endpoint's radius.
        real[] radius = new real[n];
        for (int i = 0; i < n; ++i) {
            real label_half_width = measure_text_size(this._vertex_labels[i], text_normal).x / 2;
            radius[i] = max(graph_vertex_radius, label_half_width + 0.12);
        }
        if (this._uniform_vertex_size) {
            real max_radius = 0;
            for (int i = 0; i < n; ++i) max_radius = max(max_radius, radius[i]);
            for (int i = 0; i < n; ++i) radius[i] = max_radius;
        }

        // Trim a path back from both ends by the given arc lengths. Works for straight and bowed
        // edges alike, since it measures along the path rather than assuming a straight line. A
        // segment too short to trim is left alone rather than collapsing to nothing.
        path trim_ends(path p, real start_trim, real end_trim) {
            real len = arclength(p);
            if (start_trim + end_trim >= len) return p;
            return subpath(p, arctime(p, start_trim), arctime(p, len - end_trim));
        }

        // Extra perpendicular bow needed to curve the straight edge a--b clear of any OTHER vertex
        // it would otherwise pass close enough to that the drawing reads as if that vertex were
        // connected too. Modeled against the single-control-point bow already used for parallel
        // edges below: a vertex sitting near the segment's midpoint needs close to the full
        // clearance made up by the bow, but one sitting near an endpoint needs much more, since the
        // curve is nearly flat there — the "taper" factor (peaking at 1 at the midpoint, tapering
        // to 0 at the ends, matching the curve's actual deviation shape) accounts for that. Vertices
        // within 15% of either end are skipped entirely: a curve can't usefully clear something
        // that close to where it's already trimmed back to the rim, and this near the endpoint the
        // ambiguity this guards against isn't really there anyway. When several vertices are in the
        // way, only the one demanding the largest bow is honored — this is a heuristic, not a
        // general router, and the common case is a single incidental vertex near the straight line.
        real avoidance_bow(int a, int b) {
            pair dir = unit(pos[b] - pos[a]);
            pair perp = rotate(90) * dir;
            real seg_length = length(pos[b] - pos[a]);
            real best_extra = 0;
            for (int k = 0; k < n; ++k) {
                if (k == a || k == b) continue;
                pair rel = pos[k] - pos[a];
                real t = dot(rel, dir);
                if (t < seg_length * 0.15 || t > seg_length * 0.85) continue;
                real perp_dist = dot(rel, perp);
                real needed = radius[k] + graph_edge_vertex_clearance;
                if (abs(perp_dist) >= needed) continue;
                real frac = t / seg_length;
                real taper = 4 * frac * (1 - frac);
                real extra = (needed - abs(perp_dist)) / max(taper, 0.3);
                real side = (perp_dist >= 0) ? 1 : -1;
                real signed_extra = -side * extra;
                if (abs(signed_extra) > abs(best_extra)) best_extra = signed_extra;
            }
            return best_extra;
        }

        // Parallel edges share endpoints and would otherwise be drawn exactly on top of each other.
        // Number each edge among its siblings so the drawing loop can bow them apart symmetrically.
        // Endpoints are compared unordered for an undirected graph, where A->B and B->A are the same
        // pair of vertices, and ordered for a directed one, where they are opposite arcs.
        int[] sibling_count = new int[this._edges.length];
        int[] sibling_index = new int[this._edges.length];
        for (int e = 0; e < this._edges.length; ++e) { sibling_count[e] = 0; sibling_index[e] = 0; }

        for (int e = 0; e < this._edges.length; ++e) {
            int seen_before = 0;
            int total = 0;
            for (int f = 0; f < this._edges.length; ++f) {
                bool same;
                if (this._directed) {
                    same = (this._edges[f].from_vertex == this._edges[e].from_vertex
                            && this._edges[f].to_vertex == this._edges[e].to_vertex);
                } else {
                    same = (this._edges[f].from_vertex == this._edges[e].from_vertex && this._edges[f].to_vertex == this._edges[e].to_vertex)
                        || (this._edges[f].from_vertex == this._edges[e].to_vertex && this._edges[f].to_vertex == this._edges[e].from_vertex);
                }
                if (!same) continue;
                ++total;
                if (f < e) ++seen_before;
            }
            sibling_count[e] = total;
            sibling_index[e] = seen_before;
        }

        pen edge_pen = graph_edge_color + graph_edge_thickness;

        for (int e = 0; e < this._edges.length; ++e) {
            int a = this._edges[e].from_vertex;
            int b = this._edges[e].to_vertex;
            string edge_label = this._edges[e].label;

            path edge_path;
            pair label_anchor;

            if (a == b) {
                // Self-loop: an arc leaving the vertex rim and returning to it. Successive loops at
                // the same vertex are rotated around it so they don't overlap.
                real turn = 360.0 * sibling_index[e] / max(1, sibling_count[e]);
                real base = 90 + turn;
                real half = graph_self_loop_angle / 2;
                real reach = graph_self_loop_size * radius[a] * 3;

                pair attach_1 = pos[a] + radius[a] * dir(base - half);
                pair attach_2 = pos[a] + radius[a] * dir(base + half);
                pair control_1 = pos[a] + reach * dir(base - half * 0.8);
                pair control_2 = pos[a] + reach * dir(base + half * 0.8);

                edge_path = attach_1 .. controls control_1 and control_2 .. attach_2;
                label_anchor = pos[a] + (reach + graph_edge_label_offset) * dir(base);
            } else {
                // Straight when this is the only edge between the pair; bowed symmetrically about
                // the straight line when there are several, so each stays individually visible.
                // Curving around an unrelated vertex in the way is added on top of that bow, so the
                // two needs (parallel-edge separation and vertex avoidance) don't fight each other.
                real bow = (sibling_index[e] - (sibling_count[e] - 1) / 2.0) * graph_multi_edge_bow;
                if (this._avoid_vertex_overlap) bow += avoidance_bow(a, b);
                pair midpoint_straight = (pos[a] + pos[b]) / 2;
                pair perpendicular = rotate(90) * unit(pos[b] - pos[a]);

                path full_path;
                if (abs(bow) < 1e-9) {
                    full_path = pos[a] -- pos[b];
                    label_anchor = midpoint_straight;
                } else {
                    pair bow_point = midpoint_straight + perpendicular * bow;
                    full_path = pos[a] .. bow_point .. pos[b];
                    label_anchor = bow_point;
                }
                edge_path = trim_ends(full_path, radius[a], radius[b]);

                // Push the label clear of the edge, on the same side the edge bows toward so it
                // never lands on top of a sibling edge.
                real side = (abs(bow) < 1e-9) ? 1 : (bow > 0 ? 1 : -1);
                label_anchor += perpendicular * side * graph_edge_label_offset;
            }

            draw(pic, edge_path, p=edge_pen,
                 arrow=(this._directed ? graph_directed_arrow : None));

            if (edge_label != "") {
                label(pic, edge_label, label_anchor, p=text_small);
            }
        }

        // Vertices last, so they sit on top of every edge meeting them.
        for (int i = 0; i < n; ++i) {
            filldraw(pic, circle(pos[i], radius[i]), graph_vertex_fill,
                     graph_vertex_outline + graph_vertex_thickness);
            label(pic, this._vertex_labels[i], pos[i], p=text_normal);
        }

        if (this._debug_mode) {
            draw(pic, box((0, 0), (width, height)), p=gray + linewidth(0.5));
        }

        return pic;
    }
};

// "Graph" alias: most callers should write Graph(...) rather than GraphDiagram(...). typedef makes
// the two type names fully interchangeable (variables, parameters, assignments); this wrapper
// function is what makes Graph() work as a constructor call.
typedef GraphDiagram Graph;
Graph Graph() {
    return GraphDiagram();
}
