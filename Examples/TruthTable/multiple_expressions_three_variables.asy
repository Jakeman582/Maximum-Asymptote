import MaximumMathematics;

// Example: several expressions, together depending on three atomic propositions.

TruthTable table = TruthTable();
table.add("p & q");
table.add("q | r");
table.add("(p & q) | r");
table.add("p -> (q & r)");

Image img = Image();
img.width(16);
img.height(6);
img.padding(0.3);
img.add(table);
