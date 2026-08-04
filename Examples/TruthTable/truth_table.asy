import MaximumMathematics;

TruthTable table = TruthTable();
table.add("!p");
table.add("!q");
table.add("!p & !q");
table.add("p & q");
table.add("!(p & q)");

Image img = Image();
img.width(14);
img.height(5);
img.padding(0.2);
img.add(table);
