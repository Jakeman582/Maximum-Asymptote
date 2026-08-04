// 1.) Import the MaximumMathematics library
import MaximumMathematics;

// 2.) Create the visualization
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_set(new string[] {"u", "v", "w"}, "C");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});
diagram.add_relation(1, 2, new pair[] {(0,1), (1,2), (2,0)});

// 3.) Create and configure an Image to hold the visualization
Image img = Image();
img.padding(0.2);

// 4.) Add the visualization to the Image
img.add(diagram);