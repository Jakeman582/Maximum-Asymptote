//settings.outformat = "png";
//settings.prc = false;
//settings.render = 16;

import three;
import MaximumMathematics;

size(20cm, 0);

currentprojection = orthographic((10, 10, 10), up = Z);

draw(O--6X, blue);
draw(O--6Y, green);
draw(O--6Z, red);

for(int i = 0; i < 5; ++i) {
    for(int j = 0; j < 5; ++j) {
        drawbox((i, j, 0), 1, 1, (11 - i - j)/2.0);
    }
    //drawbox((i, 0, 0), 1, 1, 1/(i * 1.0 + 1.0));
}
//drawbox((0, 0, 0), 1, 1, 5);