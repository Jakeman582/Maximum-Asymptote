import MaximumMathematics;

// Create a simple gallery with 1 row and 2 columns
Gallery gallery = Gallery(1, 2, visual_width=3, visual_height=2);

// Create a simple relation diagram
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2"}, "A");
diagram.add_set(new string[] {"a", "b"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1)});

// Add to gallery
gallery.add(diagram, 0, 0, "Figure 1: Test caption");

// Ensure gallery is rendered
gallery.render();



