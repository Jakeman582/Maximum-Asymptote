import MaximumMathematics;

// Example: highlighting three interior cells at once. (0, 0) and (0, 2) share row 0, and (3, 1)
// shares neither a row nor a column with either of the other two.

TruthTable table = TruthTable();
table.add("p & q");
table.add("p | q");
table.add("p ^ q");
table.highlight(0, 0);
table.highlight(0, 2);
table.highlight(3, 1);

Image img = Image();
img.width(10);
img.height(5);
img.padding(0.3);
img.add(table);
