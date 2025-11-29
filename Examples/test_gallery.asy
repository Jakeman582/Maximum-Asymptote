import MaximumMathematics;

// Create a gallery with 2 rows and 2 columns
Gallery gallery = Gallery(2, 2, visual_width=4, visual_height=3);

// Set gallery-wide settings
gallery.set_margin(0.5);
gallery.set_padding(0.3);
gallery.set_caption_height(0.8);

// Create relation diagrams for each cell
RelationDiagram diagram1 = RelationDiagram();
diagram1.add_set(new string[] {"1", "2"}, "A");
diagram1.add_set(new string[] {"a", "b"}, "B");
diagram1.add_relation(0, 1, new pair[] {(0,0), (1,1)});

RelationDiagram diagram2 = RelationDiagram();
diagram2.add_set(new string[] {"3", "4"}, "C");
diagram2.add_set(new string[] {"c", "d"}, "D");
diagram2.add_relation(0, 1, new pair[] {(0,1), (1,0)});

RelationDiagram diagram3 = RelationDiagram();
diagram3.add_set(new string[] {"5", "6"}, "E");
diagram3.add_set(new string[] {"e", "f"}, "F");
diagram3.add_relation(0, 1, new pair[] {(0,0), (1,1)});

RelationDiagram diagram4 = RelationDiagram();
diagram4.add_set(new string[] {"7", "8"}, "G");
diagram4.add_set(new string[] {"g", "h"}, "H");
diagram4.add_relation(0, 1, new pair[] {(0,1), (1,0)});

// Add diagrams to gallery with captions
gallery.add(diagram1, 0, 0, "Figure 1:", "First relation");
gallery.add(diagram2, 0, 1, "Figure 2:", "Second relation");
gallery.add(diagram3, 1, 0, "Figure 3:", "Third relation");
gallery.add(diagram4, 1, 1, "Figure 4:", "Fourth relation");

// Gallery automatically renders!



