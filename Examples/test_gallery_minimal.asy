import MaximumMathematics;

// Minimal test - just one cell
Gallery gallery = Gallery(1, 1, visual_width=3, visual_height=2);
gallery.set_margin(0.5);
gallery.set_padding(0.3);

RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1"}, "A");
diagram.add_set(new string[] {"a"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0)});

gallery.add(diagram, 0, 0, "Test:", "Minimal gallery");



