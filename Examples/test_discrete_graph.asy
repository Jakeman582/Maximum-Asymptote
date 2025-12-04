import MaximumMathematics;

// Example: compound interest accumulation (discrete compounding per period)

// Parameters
real principal = 1000;
real rate = 0.05; // 5% per period
int periods = 8;
real dt = 1; // step size (one period)
real first_x = 0; // start at period 0

// Function: value after k periods, sampled at period center
real value_func(real x) {
    // x is the period index (could be non-integer when sampling midpoints)
    return principal * exp(log(1 + rate) * x);
}

DiscreteGraph g = DiscreteGraph(dt, first_x, "left", periods, value_func);
// Set a nicer window (x from -0.5 to periods+0.5, y auto)
g.set_window(-0.5, periods + 0.5, 0, 0); // ymin==ymax triggers auto-compute in the struct
// Optional: styling

Image img = Image(12, 6);
img.set_diagram_padding(0.5);
img.caption_title("Figure");
img.caption_text("Compound interest accumulation (discrete, per-period)");
img.add(g); // Image.add supports diagrams with render()

// Note: run `asy Examples/test_discrete_graph.asy` to render
