import MaximumMathematics;

// Example: the same graph — the 3-cube Q3, whose vertices are the 3-bit strings with an edge
// between any two differing in exactly one bit — drawn under four different layouts. Only the
// vertex and edge sets are ever specified; every coordinate is computed by the library.
//
// Q3 is both bipartite (by parity of bit count) and planar, so all four layouts apply to it.

// Build the cube once, as a plain edge list. add_edge() creates each endpoint on first mention,
// so there are no separate add_vertex() calls and no coordinates anywhere.
void build_cube(Graph g) {
    g.add_edge("A", "B");  g.add_edge("A", "C");  g.add_edge("A", "E");
    g.add_edge("B", "D");  g.add_edge("B", "F");
    g.add_edge("C", "D");  g.add_edge("C", "G");
    g.add_edge("D", "H");
    g.add_edge("E", "F");  g.add_edge("E", "G");
    g.add_edge("F", "H");
    g.add_edge("G", "H");
}

Graph force_graph = Graph();      build_cube(force_graph);      force_graph.set_layout(FORCE);
Graph circular_graph = Graph();   build_cube(circular_graph);   circular_graph.set_layout(CIRCULAR);
Graph bipartite_graph = Graph();  build_cube(bipartite_graph);  bipartite_graph.set_layout(BIPARTITE);
Graph grid_graph = Graph();       build_cube(grid_graph);       grid_graph.set_layout(GRID);

Gallery gallery = Gallery(2, 2);
gallery.width(14);
gallery.height(14);
gallery.padding(0.3);
gallery.label_scheme(NUMERIC);

// Added in row-major order: (1) FORCE, (2) CIRCULAR, (3) BIPARTITE, (4) GRID.
gallery.add(force_graph);
gallery.add(circular_graph);
gallery.add(bipartite_graph);
gallery.add(grid_graph);

gallery.caption_title("Figure 1");
gallery.caption_text("The same graph under four layouts, in row-major order: (1) FORCE, (2) CIRCULAR, (3) BIPARTITE, (4) GRID.");

// Note: run `asy Examples/Graph/test_graph_layouts.asy` to render
