import MaximumMathematics;

// Example: the RANDOM layout, which scatters vertices over a lattice instead of arranging them by
// connectivity. The same graph is drawn under three seeds — a useful way to show a class that a
// graph's drawing is not unique, since all three are the same graph.
//
// Each seed reproduces its own arrangement exactly, so these three pictures are stable across
// renders; changing a seed is what changes an arrangement, not re-running the file.

void build_graph(Graph g) {
    g.add_edge("A", "B");  g.add_edge("B", "C");  g.add_edge("C", "D");
    g.add_edge("D", "E");  g.add_edge("E", "F");  g.add_edge("F", "A");
    g.add_edge("A", "D");  g.add_edge("B", "E");  g.add_edge("C", "F");
}

Graph seed_1 = Graph();  build_graph(seed_1);  seed_1.set_layout(RANDOM);  seed_1.set_seed(1);
Graph seed_2 = Graph();  build_graph(seed_2);  seed_2.set_layout(RANDOM);  seed_2.set_seed(2);
Graph seed_3 = Graph();  build_graph(seed_3);  seed_3.set_layout(RANDOM);  seed_3.set_seed(3);

Gallery gallery = Gallery(1, 3);
gallery.width(18);
gallery.height(6);
gallery.padding(0.3);
gallery.label_scheme(NUMERIC);

// Added left to right: seed 1, seed 2, seed 3.
gallery.add(seed_1);
gallery.add(seed_2);
gallery.add(seed_3);

gallery.caption_title("Figure 1");
gallery.caption_text("The same graph laid out under RANDOM with seeds 1, 2, and 3, left to right.");

// Note: run `asy Examples/Graph/test_graph_random.asy` to render
