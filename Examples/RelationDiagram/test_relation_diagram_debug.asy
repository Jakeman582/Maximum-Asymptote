import MaximumMathematics;

// Example: Relation diagram with debug visualization enabled
// This shows the element zones, set boundaries, and label/element zone separation

RelationDiagram diagram = RelationDiagram();

// Add sets with names
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_set(new string[] {"u", "v", "w"}, "C");

// Add relations
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});
diagram.add_relation(1, 2, new pair[] {(0,1), (1,2), (2,0)});

// Enable debug mode to visualize zones and boundaries
diagram.set_debug_mode(true);

// Add diagram to image
Image img = Image();
img.set_diagram_padding(0.5);
img.add(diagram);

