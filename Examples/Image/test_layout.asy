import MaximumMathematics;

// Create a simple test diagram
picture test_diagram = new picture;
unitsize(test_diagram, 1cm);
fill(test_diagram, box((0,0), (9,6)), yellow);
label(test_diagram, "Test Diagram", (3, 2), p=fontsize(0.8cm));

// Create and configure image
Image img = Image(12, 10);
img.set_margin(0.5);
img.set_diagram_padding(0.3);
img.set_caption_padding(0.2);
img.set_debug_mode(true);  // Enable debug visualization
img.caption_title("A");
img.caption_text("B");

// Add visual and auto-render
img.add_visual(test_diagram);

