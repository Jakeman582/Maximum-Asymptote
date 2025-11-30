import MaximumMathematics;

///////////////////////////////////////////////////////////////////////////////
// Relation Diagram
///////////////////////////////////////////////////////////////////////////////
RelationDiagram diagram = RelationDiagram();

// Adding the sets
diagram.add_set(new string[] {"1", "2", "3"}, "Bus");
diagram.add_set(new string[] {"Downtown", "Airport", "Suburbs", "Harbor"}, "Destinations");
diagram.add_set(new string[] {"Low", "Medium", "High"}, "Traffic");

// Defining the relations
diagram.add_relation(0, 1, new pair[] {(0, 0), (1, 2), (2, 1)});
diagram.add_relation(1, 2, new pair[] {(0, 2), (1, 1), (2, 0), (3, 0)});

///////////////////////////////////////////////////////////////////////////////
// Creating the Image
///////////////////////////////////////////////////////////////////////////////
Image image = Image(17, 10);
image.add(diagram);