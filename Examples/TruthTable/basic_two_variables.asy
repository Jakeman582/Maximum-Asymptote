import MaximumMathematics;

// Example: a single expression over two atomic propositions.

TruthTable table = TruthTable();
table.add("p & q");

Image img = Image();
img.width(6);
img.height(4);
img.padding(0.3);
img.add(table);
