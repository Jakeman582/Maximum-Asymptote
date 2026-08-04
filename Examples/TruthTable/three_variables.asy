import MaximumMathematics;

// Example: a single expression over three atomic propositions.

TruthTable table = TruthTable();
table.add("(p & q) | r");

Image img = Image();
img.width(8);
img.height(6);
img.padding(0.3);
img.add(table);
