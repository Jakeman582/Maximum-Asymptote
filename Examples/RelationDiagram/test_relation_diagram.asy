import MaximumMathematics;

// Example: Relation diagram with 3 sets showing a composed relation
// The diagram is divided into two zones:
// - Top 2 units: Set label zone (for set names "A", "B", "C") - labels vertically centered
// - Remaining height: Element zone (for set elements)

RelationDiagram diagram = RelationDiagram();

// Add sets with names
// Sets are evenly distributed horizontally (first at left, last at right)
// Elements are evenly distributed vertically in the element zone
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_set(new string[] {"u", "v", "w"}, "C");

// Optional: Specify custom widths for sets (0 = auto-calculate)
// diagram.set_width(0, 1.5);  // Set width of first set to 1.5
// diagram.set_width(1, 1.5);  // Set width of second set to 1.5

// Add relations between neighboring sets
// Relations use index pairs: (source_element_index, target_element_index)
// A→B: 1→a, 2→b, 3→c
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});
// B→C: a→v, b→w, c→u
diagram.add_relation(1, 2, new pair[] {(0,1), (1,2), (2,0)});

// Add diagram to image (automatically renders with new layout)
// Set padding of 0.5 to prevent elements from being cut off at edges
Image img = Image();
img.set_diagram_padding(0.5);
img.add(diagram);

