////////////////////////////////////////////////////////////////////////////////////////////////////
// File: GraphLayout.asy
//
// Description:
// Vertex-placement algorithms for graph-theory diagrams: given only a vertex count and an edge list,
// compute a position for every vertex so callers never have to supply coordinates by hand. Each
// algorithm returns a pair[] of positions, already normalized into the requested width x height box;
// no drawing happens here, which keeps the geometry independently testable and reusable.
//
// Every algorithm is deterministic — the same graph always produces the same positions, including
// the force-directed one, which seeds from a circle rather than random placement. That matters for a
// notes/document library: a figure must not shift between renders of the same source.
//
// Used by Visualizations/GraphDiagram.asy, but not specific to it.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Layout algorithm names, for GraphDiagram.set_layout().
string FORCE = "force";          // General-purpose; needs nothing but the edges
string CIRCULAR = "circular";    // Cycles, complete graphs, small graphs
string TREE = "tree";            // Trees and hierarchies; rooted
string BIPARTITE = "bipartite";  // Two facing columns; 2-coloring is auto-detected
string LAYERED = "layered";      // Flow networks: source on the left, layered rightward
string GRID = "grid";            // Lattices and meshes
string PLANAR = "planar";        // Tutte embedding; crossing-free for 3-connected planar graphs
string RANDOM = "random";        // Seeded scatter over a lattice; ignores edges entirely

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_build_adjacency
//
// Description:
// Build an undirected adjacency list from an edge list. Edge direction is ignored (both endpoints
// record each other) because every layout below positions vertices by connectivity alone, not by
// orientation. Self-loops are skipped — they connect a vertex to itself and so exert no positioning
// influence.
//
// Inputs:
//    n     - Number of vertices.
//    edges - Array of {from, to} index pairs.
//
// Outputs:
//    adjacency - adjacency[v] lists every vertex sharing an edge with v.
////////////////////////////////////////////////////////////////////////////////////////////////////
int[][] graph_build_adjacency(int n, int[][] edges) {
    int[][] adjacency = new int[n][];
    for (int i = 0; i < n; ++i) adjacency[i] = new int[0];
    for (int e = 0; e < edges.length; ++e) {
        int a = edges[e][0];
        int b = edges[e][1];
        if (a == b) continue;
        adjacency[a].push(b);
        adjacency[b].push(a);
    }
    return adjacency;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_normalize_positions
//
// Description:
// Scale and translate raw layout coordinates to fit inside a width x height box, inset by margin on
// every side, then center them. Scaling is uniform (the same factor on both axes) so a layout's
// shape is never distorted — a circular layout stays circular, and a tree's branch angles are
// preserved — matching the letterboxing approach Plot and SwitchingNetwork already use. A degenerate
// axis (every vertex sharing an x or y, e.g. a single vertex or a straight path) is centered on that
// axis rather than divided by a zero extent.
//
// Inputs:
//    pos    - Raw positions to normalize, in any coordinate range.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//
// Outputs:
//    positions - The normalized positions.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_normalize_positions(pair[] pos, real width, real height, real margin) {
    int n = pos.length;
    if (n == 0) return pos;

    real avail_w = max(0, width - 2 * margin);
    real avail_h = max(0, height - 2 * margin);

    real min_x = pos[0].x, max_x = pos[0].x;
    real min_y = pos[0].y, max_y = pos[0].y;
    for (int i = 1; i < n; ++i) {
        min_x = min(min_x, pos[i].x);  max_x = max(max_x, pos[i].x);
        min_y = min(min_y, pos[i].y);  max_y = max(max_y, pos[i].y);
    }
    real span_x = max_x - min_x;
    real span_y = max_y - min_y;

    // Uniform scale: the tighter of the two axis fits, so neither overflows.
    real scale = 1;
    if (span_x > 1e-9 && span_y > 1e-9)      scale = min(avail_w / span_x, avail_h / span_y);
    else if (span_x > 1e-9)                   scale = avail_w / span_x;
    else if (span_y > 1e-9)                   scale = avail_h / span_y;

    real drawn_w = span_x * scale;
    real drawn_h = span_y * scale;
    real offset_x = (width - drawn_w) / 2;
    real offset_y = (height - drawn_h) / 2;

    pair[] result = new pair[n];
    for (int i = 0; i < n; ++i) {
        real x = (span_x > 1e-9) ? offset_x + (pos[i].x - min_x) * scale : width / 2;
        real y = (span_y > 1e-9) ? offset_y + (pos[i].y - min_y) * scale : height / 2;
        result[i] = (x, y);
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_circular
//
// Description:
// Place every vertex evenly around a circle, in index order. Exactly right for cycles (a cycle graph
// becomes a regular polygon) and complete graphs, and a reasonable choice for any small graph.
//
// Inputs:
//    n      - Number of vertices.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_circular(int n, real width, real height, real margin) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;
    if (n == 1) { pos[0] = (0, 0); return graph_normalize_positions(pos, width, height, margin); }

    for (int i = 0; i < n; ++i) {
        // Start at the top and go counterclockwise, so vertex 0 sits at 12 o'clock.
        real angle = pi / 2 + 2 * pi * i / n;
        pos[i] = (cos(angle), sin(angle));
    }
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_force
//
// Description:
// Fruchterman-Reingold force-directed layout: every pair of vertices repels (like charged
// particles), every edge attracts (like a spring), and the maximum per-step displacement cools
// linearly to zero so the system settles instead of oscillating. Needs nothing but the edge list,
// which makes it the sensible default for an arbitrary graph.
//
// The initial placement is a circle rather than the random scatter the original algorithm calls for.
// That keeps the result reproducible — the same graph always renders identically — and costs
// nothing, since the relaxation pulls structure out of the circle anyway (verified: a star graph
// correctly resolves to a hub at the centroid of its leaves, not a ring).
//
// Inputs:
//    n          - Number of vertices.
//    edges      - Array of {from, to} index pairs.
//    width      - Target box width.
//    height     - Target box height.
//    margin     - Blank border to reserve on every side.
//    iterations - Relaxation steps; higher settles more at the cost of render time.
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_force(int n, int[][] edges, real width, real height, real margin,
                           int iterations = graph_force_iterations) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;
    if (n == 1) { pos[0] = (0, 0); return graph_normalize_positions(pos, width, height, margin); }

    real avail_w = max(1e-6, width - 2 * margin);
    real avail_h = max(1e-6, height - 2 * margin);

    for (int i = 0; i < n; ++i) {
        real angle = pi / 2 + 2 * pi * i / n;
        pos[i] = (avail_w / 2 + (avail_w / 3) * cos(angle), avail_h / 2 + (avail_h / 3) * sin(angle));
    }

    real k = sqrt((avail_w * avail_h) / n);   // Ideal edge length
    real temperature = avail_w / 10;          // Cap on how far a vertex may move in one step
    real cooling = temperature / (iterations + 1);

    for (int iter = 0; iter < iterations; ++iter) {
        pair[] displacement = new pair[n];
        for (int i = 0; i < n; ++i) displacement[i] = (0, 0);

        // Repulsion between every pair, proportional to k^2 / distance.
        for (int i = 0; i < n; ++i) {
            for (int j = i + 1; j < n; ++j) {
                pair delta = pos[i] - pos[j];
                real d = length(delta);
                // Coincident vertices have no defined direction to separate along; nudge them apart
                // diagonally so the next iteration has a gradient to work with.
                if (d < 1e-9) { delta = (1e-6, 1e-6); d = length(delta); }
                pair force = (delta / d) * (k * k / d);
                displacement[i] += force;
                displacement[j] -= force;
            }
        }

        // Attraction along each edge, proportional to distance^2 / k.
        for (int e = 0; e < edges.length; ++e) {
            int a = edges[e][0];
            int b = edges[e][1];
            if (a == b) continue;
            pair delta = pos[a] - pos[b];
            real d = length(delta);
            if (d < 1e-9) continue;
            pair force = (delta / d) * (d * d / k);
            displacement[a] -= force;
            displacement[b] += force;
        }

        for (int i = 0; i < n; ++i) {
            real dl = length(displacement[i]);
            if (dl > 1e-9) pos[i] += (displacement[i] / dl) * min(dl, temperature);
            pos[i] = (min(avail_w, max(0, pos[i].x)), min(avail_h, max(0, pos[i].y)));
        }
        temperature -= cooling;
    }
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_tree
//
// Description:
// Rooted tree layout: a breadth-first spanning tree fixes each vertex's depth (its row) and parent,
// then each subtree is allotted a horizontal band proportional to how many leaves it contains, with
// every parent centered over its own children. Using a spanning tree rather than requiring an actual
// tree means a graph with cycles still lays out sensibly — extra edges simply draw across the tree
// as back edges instead of aborting.
//
// Vertices unreachable from the root (a disconnected graph) are laid out as additional trees to the
// right of the main one, so nothing is silently dropped or stacked at the origin.
//
// Inputs:
//    n      - Number of vertices.
//    edges  - Array of {from, to} index pairs.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//    root   - Index of the vertex to place at the top.
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_tree(int n, int[][] edges, real width, real height, real margin, int root) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;

    int[][] adjacency = graph_build_adjacency(n, edges);

    int[] depth = new int[n];
    int[][] children = new int[n][];
    bool[] seen = new bool[n];
    for (int i = 0; i < n; ++i) { depth[i] = 0; children[i] = new int[0]; seen[i] = false; }

    real[] subtree_width = new real[n];
    real[] x_position = new real[n];
    for (int i = 0; i < n; ++i) { subtree_width[i] = 0; x_position[i] = 0; }

    // Leaves occupy one slot; an internal vertex spans the total of its children's slots.
    real compute_width(int v) {
        if (children[v].length == 0) { subtree_width[v] = 1; return 1; }
        real total = 0;
        for (int c : children[v]) total += compute_width(c);
        subtree_width[v] = total;
        return total;
    }

    // Walk each subtree's allotted band left to right, then center the parent over its children.
    void assign_x(int v, real left) {
        if (children[v].length == 0) { x_position[v] = left + 0.5; return; }
        real cursor = left;
        for (int c : children[v]) { assign_x(c, cursor); cursor += subtree_width[c]; }
        x_position[v] = (x_position[children[v][0]] + x_position[children[v][children[v].length - 1]]) / 2;
    }

    // Each connected component becomes its own tree, placed to the right of the previous one.
    real band_start = 0;
    for (int pass = 0; pass < n; ++pass) {
        int start = -1;
        if (pass == 0) {
            start = (root >= 0 && root < n) ? root : 0;
        } else {
            for (int i = 0; i < n; ++i) if (!seen[i]) { start = i; break; }
        }
        if (start == -1 || seen[start]) {
            if (pass == 0) continue;
            break;
        }

        seen[start] = true;
        int[] queue = new int[] {start};
        int head = 0;
        while (head < queue.length) {
            int v = queue[head]; ++head;
            for (int u : adjacency[v]) {
                if (!seen[u]) {
                    seen[u] = true;
                    depth[u] = depth[v] + 1;
                    children[v].push(u);
                    queue.push(u);
                }
            }
        }

        compute_width(start);
        assign_x(start, band_start);
        band_start += subtree_width[start] + 1;   // One slot of separation between components
    }

    // Depth grows downward, so negate it: the root ends up at the top.
    for (int i = 0; i < n; ++i) pos[i] = (x_position[i], -depth[i]);
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_two_color
//
// Description:
// Attempt a breadth-first 2-coloring of the graph, which succeeds exactly when the graph is
// bipartite (no odd cycle). Every connected component is colored independently, so a disconnected
// bipartite graph still succeeds.
//
// Inputs:
//    n         - Number of vertices.
//    adjacency - Adjacency list from graph_build_adjacency.
//    color     - Output array, length n; filled with 0 or 1 per vertex on success.
//
// Outputs:
//    bipartite - True if a valid 2-coloring exists; false if an odd cycle was found (color is then
//                partially filled and should not be used).
////////////////////////////////////////////////////////////////////////////////////////////////////
bool graph_two_color(int n, int[][] adjacency, int[] color) {
    for (int i = 0; i < n; ++i) color[i] = -1;
    for (int s = 0; s < n; ++s) {
        if (color[s] != -1) continue;
        color[s] = 0;
        int[] queue = new int[] {s};
        int head = 0;
        while (head < queue.length) {
            int v = queue[head]; ++head;
            for (int u : adjacency[v]) {
                if (color[u] == -1) { color[u] = 1 - color[v]; queue.push(u); }
                else if (color[u] == color[v]) return false;
            }
        }
    }
    return true;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_bipartite
//
// Description:
// Two facing columns, one per color class of a breadth-first 2-coloring, each column's vertices
// spread evenly down its side. Since the coloring is computed rather than supplied, this needs
// nothing from the caller beyond the edges.
//
// A graph containing an odd cycle is not bipartite and has no such layout; in that case this returns
// an empty array so the caller can fall back to another algorithm rather than drawing something
// misleading.
//
// Inputs:
//    n      - Number of vertices.
//    edges  - Array of {from, to} index pairs.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//
// Outputs:
//    positions - One position per vertex, or an empty array if the graph is not bipartite.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_bipartite(int n, int[][] edges, real width, real height, real margin) {
    if (n == 0) return new pair[0];

    int[][] adjacency = graph_build_adjacency(n, edges);
    int[] color = new int[n];
    if (!graph_two_color(n, adjacency, color)) return new pair[0];

    int left_count = 0, right_count = 0;
    for (int i = 0; i < n; ++i) { if (color[i] == 0) ++left_count; else ++right_count; }

    pair[] pos = new pair[n];
    int left_seen = 0, right_seen = 0;
    for (int i = 0; i < n; ++i) {
        if (color[i] == 0) {
            real t = (left_count == 1) ? 0.5 : left_seen / (left_count - 1.0);
            pos[i] = (0, -t);
            ++left_seen;
        } else {
            real t = (right_count == 1) ? 0.5 : right_seen / (right_count - 1.0);
            pos[i] = (1, -t);
            ++right_seen;
        }
    }
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_layered
//
// Description:
// Flow-network layout: breadth-first distance from the source fixes each vertex's layer (its
// column), and vertices sharing a layer are spread evenly down that column. The source ends up alone
// on the left and the graph flows rightward, which is the conventional way to draw a network with a
// source and a sink.
//
// Vertices unreachable from the source are collected into one extra layer past the deepest reached
// one, so a disconnected graph still shows everything.
//
// Inputs:
//    n      - Number of vertices.
//    edges  - Array of {from, to} index pairs.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//    source - Index of the vertex to place in the leftmost layer.
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_layered(int n, int[][] edges, real width, real height, real margin, int source) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;

    int[][] adjacency = graph_build_adjacency(n, edges);
    int start = (source >= 0 && source < n) ? source : 0;

    int[] layer = new int[n];
    for (int i = 0; i < n; ++i) layer[i] = -1;

    layer[start] = 0;
    int[] queue = new int[] {start};
    int head = 0;
    int max_layer = 0;
    while (head < queue.length) {
        int v = queue[head]; ++head;
        for (int u : adjacency[v]) {
            if (layer[u] == -1) {
                layer[u] = layer[v] + 1;
                max_layer = max(max_layer, layer[u]);
                queue.push(u);
            }
        }
    }
    for (int i = 0; i < n; ++i) if (layer[i] == -1) layer[i] = max_layer + 1;

    int total_layers = 0;
    for (int i = 0; i < n; ++i) total_layers = max(total_layers, layer[i] + 1);

    int[] layer_size = new int[total_layers];
    int[] layer_seen = new int[total_layers];
    for (int l = 0; l < total_layers; ++l) { layer_size[l] = 0; layer_seen[l] = 0; }
    for (int i = 0; i < n; ++i) ++layer_size[layer[i]];

    for (int i = 0; i < n; ++i) {
        int l = layer[i];
        real t = (layer_size[l] == 1) ? 0.5 : layer_seen[l] / (layer_size[l] - 1.0);
        pos[i] = (l, -t);
        ++layer_seen[l];
    }
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_grid
//
// Description:
// Place vertices on a regular lattice in index order, filling left to right and top to bottom. When
// rows or cols is left at 0 they are derived from the vertex count, giving as square a grid as the
// count allows.
//
// Inputs:
//    n      - Number of vertices.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//    rows   - Number of rows, or 0 to derive from cols (or from n if both are 0).
//    cols   - Number of columns, or 0 to derive from rows (or from n if both are 0).
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_grid(int n, real width, real height, real margin, int rows = 0, int cols = 0) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;

    int c = cols;
    int r = rows;
    if (c <= 0 && r <= 0) {
        c = ceil(sqrt(n));
        r = ceil(n / c);
    } else if (c <= 0) {
        c = ceil(n / r);
    } else if (r <= 0) {
        r = ceil(n / c);
    }
    if (c <= 0) c = 1;

    for (int i = 0; i < n; ++i) {
        int row = quotient(i, c);
        int col = i % c;
        pos[i] = (col, -row);
    }
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_pop_random
//
// Description:
// Remove and return one uniformly chosen element of pool, shrinking it. Asymptote arrays are
// references, so the caller's array really does shrink — which is what makes repeated calls sample
// without replacement, and so guarantees no two vertices are ever assigned the same grid point.
// Internal helper for graph_layout_random.
//
// Inputs:
//    pool - Non-empty array to draw from; the chosen element is deleted from it.
//
// Outputs:
//    value - The removed element.
////////////////////////////////////////////////////////////////////////////////////////////////////
int graph_pop_random(int[] pool) {
    int index = rand() % pool.length;
    int value = pool[index];
    pool.delete(index);
    return value;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_random
//
// Description:
// Scatter vertices over an n x n lattice (n = the vertex count), placing the first four on the
// lattice boundary — one per side — and the rest on interior lattice points, all sampled without
// replacement so no two vertices collide. Unlike every other layout here this ignores the edges
// completely; it is a deliberate scatter, useful for showing that a graph's drawing is not unique,
// or as a neutral starting picture to rearrange by hand.
//
// Anchoring one vertex to each of the four sides is what makes the result fill its box: those four
// alone force the bounding box to span the whole lattice, so the normalization step scales the
// scatter up to the full area instead of leaving it huddled wherever the sampling happened to land.
//
// The scatter is seeded, so a given seed always reproduces the same picture — the same guarantee
// the force-directed layout provides, and for the same reason: a figure must not shift between
// renders of an unchanged document. Vary seed to get a different arrangement.
//
// Fewer than four vertices cannot occupy four sides; those cases simply place one vertex per
// available side. If the interior is ever exhausted before every vertex is placed, the remaining
// vertices fall back to unused boundary points rather than stacking.
//
// Inputs:
//    n      - Number of vertices.
//    width  - Target box width.
//    height - Target box height.
//    margin - Blank border to reserve on every side.
//    seed   - Random seed; the same seed reproduces the same scatter.
//
// Outputs:
//    positions - One position per vertex.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_random(int n, real width, real height, real margin,
                            int seed = graph_random_seed) {
    pair[] pos = new pair[n];
    if (n == 0) return pos;
    if (n == 1) { pos[0] = (0, 0); return graph_normalize_positions(pos, width, height, margin); }

    srand(seed);

    // Lattice point (col, row) encoded as a single int so the pools can be plain int arrays.
    // Each corner is claimed by the first side that matches, so no point appears on two sides.
    int[][] sides = new int[4][];
    for (int s = 0; s < 4; ++s) sides[s] = new int[0];
    int[] interior = new int[0];

    for (int col = 0; col < n; ++col) {
        for (int row = 0; row < n; ++row) {
            int code = col * n + row;
            if (row == 0)          sides[0].push(code);   // Bottom
            else if (row == n - 1) sides[1].push(code);   // Top
            else if (col == 0)     sides[2].push(code);   // Left
            else if (col == n - 1) sides[3].push(code);   // Right
            else                   interior.push(code);
        }
    }

    int[] assigned = new int[n];
    int placed = 0;

    for (int s = 0; s < 4 && placed < n; ++s) {
        if (sides[s].length == 0) continue;
        assigned[placed] = graph_pop_random(sides[s]);
        ++placed;
    }

    while (placed < n) {
        if (interior.length > 0) {
            assigned[placed] = graph_pop_random(interior);
            ++placed;
            continue;
        }
        bool found = false;
        for (int s = 0; s < 4; ++s) {
            if (sides[s].length > 0) {
                assigned[placed] = graph_pop_random(sides[s]);
                ++placed;
                found = true;
                break;
            }
        }
        if (!found) break;   // Every lattice point taken; cannot happen for n >= 1, but never loop forever
    }

    for (int i = 0; i < n; ++i) pos[i] = (quotient(assigned[i], n), assigned[i] % n);
    return graph_normalize_positions(pos, width, height, margin);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: graph_layout_planar
//
// Description:
// Tutte's spring embedding: pin the given outer-face vertices to a convex polygon, then repeatedly
// move every remaining vertex to the average of its neighbors' positions until the configuration
// stops changing. Tutte's theorem guarantees the result is a straight-line drawing with no crossing
// edges, provided the graph is planar and 3-connected and the named face really is a face — this is
// the one genuinely topological algorithm here, as opposed to the physical analogy behind
// graph_layout_force.
//
// Because that guarantee depends on the outer face, this is the only layout that cannot run from the
// edge list alone. An outer face of fewer than 3 vertices cannot form a polygon; that returns an
// empty array so the caller can fall back.
//
// Inputs:
//    n          - Number of vertices.
//    edges      - Array of {from, to} index pairs.
//    width      - Target box width.
//    height     - Target box height.
//    margin     - Blank border to reserve on every side.
//    outer_face - Indices of the outer-face vertices, in cyclic order around the face.
//    iterations - Relaxation steps.
//
// Outputs:
//    positions - One position per vertex, or an empty array if outer_face is too small.
////////////////////////////////////////////////////////////////////////////////////////////////////
pair[] graph_layout_planar(int n, int[][] edges, real width, real height, real margin,
                            int[] outer_face, int iterations = graph_force_iterations) {
    if (n == 0) return new pair[0];
    if (outer_face.length < 3) return new pair[0];

    int[][] adjacency = graph_build_adjacency(n, edges);

    pair[] pos = new pair[n];
    bool[] pinned = new bool[n];
    for (int i = 0; i < n; ++i) { pos[i] = (0, 0); pinned[i] = false; }

    // Pin the outer face to a regular polygon, in the order given.
    int m = outer_face.length;
    for (int i = 0; i < m; ++i) {
        int v = outer_face[i];
        if (v < 0 || v >= n) continue;
        real angle = pi / 2 + 2 * pi * i / m;
        pos[v] = (cos(angle), sin(angle));
        pinned[v] = true;
    }

    // Every interior vertex relaxes to the centroid of its neighbors. An isolated interior vertex
    // has no neighbors to average, so it simply stays where it is.
    for (int iter = 0; iter < iterations; ++iter) {
        for (int v = 0; v < n; ++v) {
            if (pinned[v]) continue;
            if (adjacency[v].length == 0) continue;
            pair sum = (0, 0);
            for (int u : adjacency[v]) sum += pos[u];
            pos[v] = sum / adjacency[v].length;
        }
    }
    return graph_normalize_positions(pos, width, height, margin);
}
