import MaximumMathematics;

// Example: compound interest (5% per period) to demonstrate AccumulationTable
real principal = 1000;
real rate = 0.05;
int periods = 8;

real accum_func(real x) {
    // x represents the previous accumulated value; return next value
    return x * (1 + rate);
}

AccumulationTable table = AccumulationTable(principal, periods, accum_func, "Compound Interest (5 percent)");

Image img = Image();
img.width(18);
img.height(9);
img.padding(0.5);

// Directly add the table to the Image (Image.add overload was added)
img.add(table);

// Note: run `asy Examples/AccumulationTableExamples/test_accumulation_table.asy` to render
