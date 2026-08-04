// 1.) Import the MaximumMathematics library
import MaximumMathematics;

// 2.) Create a visualization (documentation for supplying any desired data is available for all visualization types)
real_function_1 f = new real(real x) {return sin(x);};
Plot plot = Plot();
plot.set_window(-5, 5, -2, 2);
plot.add(f);

// 3.) Create the Image that will hold the visualization, and configure it
Image image = Image();
image.width(12);
image.height(12);
image.caption_title("Figure 1");
image.caption_text("A basic sine curve.");

// 4.) Add the visualization to the Image and render it
image.add(plot);