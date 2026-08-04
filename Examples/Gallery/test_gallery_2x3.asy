import MaximumMathematics;

// Create a gallery with 2 rows and 3 columns
Gallery gallery = Gallery(2, 3);
gallery.width(9);
gallery.height(4);
gallery.padding(0.3);
gallery.label_scheme(LOWERCASE);
gallery.debug();  // Enable debug outlines

// Helper function to create a colored square picture
picture create_colored_square(real width, real height, pen color) {
    picture pic = new picture;
    unitsize(pic, diagram_unit);
    fill(pic, box((0, 0), (width, height)), color);
    draw(pic, box((0, 0), (width, height)), black + linewidth(1));
    return pic;
}

// Create colored squares for each cell (6 total)
picture red_square = create_colored_square(3, 2, red);
picture blue_square = create_colored_square(3, 2, blue);
picture green_square = create_colored_square(3, 2, green);
picture yellow_square = create_colored_square(3, 2, yellow);
picture orange_square = create_colored_square(3, 2, orange);
picture purple_square = create_colored_square(3, 2, purple);

// Add squares in row-major order
// Row 0
gallery.add_visual(red_square);
gallery.add_visual(blue_square);
gallery.add_visual(green_square);

// Row 1
gallery.add_visual(yellow_square);
gallery.add_visual(orange_square);
gallery.add_visual(purple_square);

// Add gallery caption
gallery.caption_title("Figure 1");
gallery.caption_text("A 2x3 gallery of colored squares demonstrating the layout system with automatic text wrapping for long captions that exceed the available width.");
