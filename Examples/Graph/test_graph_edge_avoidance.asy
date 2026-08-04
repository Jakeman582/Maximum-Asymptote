import MaximumMathematics;

// Example: a straight edge that would otherwise cut across an unrelated vertex curves around it
// instead, so the drawing never reads as if that vertex were connected too. The grid's own
// horizontal and vertical edges are unaffected — only the corner-to-corner shortcut passes close
// enough to the center vertex ("E") to need it. Compare against
// mesh.set_avoid_vertex_overlap(false) to see the straight line it would otherwise draw.

Graph mesh = Graph();
mesh.set_layout(GRID);
mesh.set_grid_dimensions(3, 3);

string[][] labels = {{"A", "B", "C"}, {"D", "E", "F"}, {"G", "H", "I"}};
for (int row = 0; row < 3; ++row)
    for (int col = 0; col < 3; ++col)
        mesh.add_vertex(labels[row][col]);

// Lattice edges.
for (int row = 0; row < 3; ++row)
    for (int col = 0; col < 2; ++col)
        mesh.add_edge(labels[row][col], labels[row][col + 1]);
for (int row = 0; row < 2; ++row)
    for (int col = 0; col < 3; ++col)
        mesh.add_edge(labels[row][col], labels[row + 1][col]);

// A shortcut straight across the grid — without avoidance this would run right through "E".
mesh.add_edge("A", "I");

Image img = Image();
img.width(8);
img.height(8);
img.padding(0.5);
img.caption_title("Figure");
img.caption_text("A shortcut edge curves around the vertex it would otherwise cross.");
img.add(mesh);

// Note: run `asy Examples/Graph/test_graph_edge_avoidance.asy` to render
