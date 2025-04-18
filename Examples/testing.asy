//import graph;

import MaximumMathematics;

unitsize(2cm);
dotfactor = 9;

fill(box((0, 0), (10, 5)), white);

filldraw(ellipse((2, 2.5), 1, 2), drawpen = linewidth(1), fillpen = 0.3blue + 0.7white);
label("A", (1, 4.5), p = fontsize(1cm));
dot((2.3, 1.5));
label("a", (2.3, 1.5) + 0.2W, p = fontsize(0.8cm));

filldraw(ellipse((8, 2.5), 1, 2), drawpen = linewidth(1), fillpen = 0.3orange + 0.7white);
filldraw(ellipse((7.8, 2.8), 0.5, 1), drawpen = linewidth(1), fillpen = 0.7orange + 0.3white);
label("B", (9, 4.5), p = fontsize(1cm));
dot((7.8, 3.3));
label("b", (7.8, 3.3) + 0.2E, p = fontsize(0.8cm));

path arrow_path = (2.3, 1.5) .. (5.05, 3) .. (7.8, 3.3);

dot((8, 1.3));
label("c", (8, 1.3) + 0.2E, p = fontsize(0.8cm));

draw(
    arrow_path,
    arrow = ArcArrow(size = 0.3cm),
    margin = Margin(0.08cm, 0.08cm)
);

//Label arrow_label = Label("$f$", position = Relative(0.5));
//label(arrow_label, arrow_path, align = Relative(W));

path_label("$f$", label_path = arrow_path, align = N, p = fontsize(0.8cm));