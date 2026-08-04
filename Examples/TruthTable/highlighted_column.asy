import MaximumMathematics;

// Example: highlighting an entire expression column (column 1 -> "p | q").

TruthTable table = TruthTable();
table.add("p & q");
table.add("p | q");
table.highlight_column(1);

Image img = Image();
img.width(8);
img.height(5);
img.padding(0.3);
img.add(table);
