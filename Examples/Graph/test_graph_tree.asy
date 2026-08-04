import MaximumMathematics;

// Example: a rooted tree with the TREE layout. Depth comes from a breadth-first walk from the root,
// and each parent is centered over its own children — so an unbalanced tree (here, the left subtree
// is deeper than the right) still spaces out evenly instead of overlapping.

Graph tree = Graph();
tree.set_layout(TREE);
tree.set_root("root");
//tree.set_uniform_vertex_size(true);  // Otherwise "root" and "LA1"/"LA2" draw larger than "L"/"R"

tree.add_edge("root", "L");
tree.add_edge("root", "R");
tree.add_edge("L", "LA");
tree.add_edge("L", "LB");
tree.add_edge("LA", "LA1");
tree.add_edge("LA", "LA2");
tree.add_edge("R", "RA");

Image img = Image();
img.width(10);
img.height(7);
img.padding(0.5);
img.caption_title("Figure");
img.caption_text("An unbalanced rooted tree.");
img.add(tree);

// Note: run `asy Examples/Graph/test_graph_tree.asy` to render
