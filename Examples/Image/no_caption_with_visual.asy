// 1.) Import the MaximumMathematics library
import MaximumMathematics;

// 2.) Create a visualization (documentation for supplying any desired data is available for all visualization types)
real_function_1 f = new real(real x) {return x^2 - 3*x - 4;};
Plot plot = Plot();
plot.set_window(-5, 5, -5, 5);
plot.add(f);

// 3.) Create the Image that will hold the visualization, and configure it
Image image = Image();
image.padding_horizontal(1);

// 4.) Add the visualization to the Image and render it
image.add(plot);