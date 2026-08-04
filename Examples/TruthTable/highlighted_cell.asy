import MaximumMathematics;

// Example: highlighting a single interior cell (row 2 -> p=1, q=0; column 1 -> "p | q").

TruthTable table = TruthTable();
table.add("p & q");
table.add("p | q");
table.highlight(2, 1);

Image img = Image();
img.width(8);
img.height(5);
img.padding(0.3);
img.add(table);
