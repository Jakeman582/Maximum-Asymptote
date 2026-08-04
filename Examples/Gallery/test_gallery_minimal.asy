import MaximumMathematics;

// Minimal test - just one cell
Gallery gallery = Gallery(1, 1);
gallery.width(3);
gallery.height(3);
gallery.padding(0.3);

RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1"}, "A");
diagram.add_set(new string[] {"a"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0)});

gallery.add(diagram);
