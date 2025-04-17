//import graph;

import MaximumMathematics;

unitsize(1cm);

real f(real x) {
    return 0.2 * x^2 - 2*x + 1;
}

//path g = graph(f, 0, 2, n=200, Hermite);

fill(box((0, 0), (2, 2)), white);
//draw(g, p=function_color_1);

slope_field_1(
    2, 2, 
    (-10, 10), (-10, 10),
    (20, 20),
    0.6,
    f
);