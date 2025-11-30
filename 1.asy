import MaximumMathematics;

// Relation Diagram
RelationDiagram diagram = RelationDiagram();

// Defining the sets
diagram.add_set(new string[] {"Anchorage", "Chicago", "Denver", "Miami"}, "City");
diagram.add_set(new string[] {"Low", "Mid", "High"}, "Latitude");
diagram.add_set(new string[] {"Cold", "Mild", "Hot"}, "Temperature");

// Defining the relations
diagram.add_relation(0, 1, new pair[] {(0,2), (1,1), (2, 1), (3, 0)});
diagram.add_relation(1, 2, new pair[] {(0, 2), (1, 1), (2, 0)});

Image img = Image(22, 12);
img.add(diagram);