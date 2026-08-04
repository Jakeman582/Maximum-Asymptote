import MaximumMathematics;

// Example: a directed, weighted flow network drawn with the LAYERED layout — source on the left,
// sink on the right, everything in between placed by distance from the source. The edge labels are
// capacities, the sort of figure a max-flow problem is posed on.

Graph network = Graph();
network.set_directed(true);
network.set_layout(LAYERED);
network.set_source("s");

network.add_edge("s", "a", "16");
network.add_edge("s", "b", "13");
network.add_edge("a", "c", "12");
network.add_edge("b", "a", "4");
network.add_edge("b", "d", "14");
network.add_edge("c", "b", "9");
network.add_edge("c", "t", "20");
network.add_edge("d", "c", "7");
network.add_edge("d", "t", "4");

Image img = Image();
img.width(11);
img.height(7);
img.padding(0.5);
img.caption_title("Figure");
img.caption_text("A flow network with edge capacities.");
img.add(network);

// Note: run `asy Examples/Graph/test_graph_network.asy` to render
