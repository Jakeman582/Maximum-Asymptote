import MaximumMathematics;

// Create a simple gallery with 1 row and 2 columns -- only the first cell is filled, leaving the
// second empty to show that's a valid state.
Gallery gallery = Gallery(1, 2);
gallery.width(6);
gallery.height(4);
gallery.padding(0.3);

// Create a simple relation diagram
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2"}, "A");
diagram.add_set(new string[] {"a", "b"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1)});

gallery.add(diagram);

gallery.caption_title("Figure 1");
gallery.caption_text("Test caption");
