import MaximumMathematics;

// Example: highlighting an entire data row (row 3 -> p=1, q=1).

TruthTable table = TruthTable();
table.add("p & q");
table.add("p | q");
table.highlight_row(3);

Image img = Image();
img.width(8);
img.height(5);
img.padding(0.3);
img.add(table);
