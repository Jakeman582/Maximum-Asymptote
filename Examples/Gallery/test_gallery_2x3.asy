import MaximumMathematics;

// Create a gallery with 2 rows and 3 columns
Gallery gallery = Gallery(2, 3, visual_width=3, visual_height=2);

// Configure gallery-wide settings
gallery.set_margin(0.5);
gallery.set_padding(0.3);
gallery.set_caption_height(3.8);  // Increased by 3cm (was 0.8)
gallery.set_debug_mode(true);  // Enable debug outlines

// Helper function to create a colored square picture
picture create_colored_square(real width, real height, pen color) {
    picture pic = new picture;
    unitsize(pic, 1cm);
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

// Add squares to gallery with captions
// Row 0
gallery.add(red_square, 0, 0, "(a)");
gallery.add(blue_square, 0, 1, "(b)");
gallery.add(green_square, 0, 2, "(c)");

// Row 1
gallery.add(yellow_square, 1, 0, "(d)");
gallery.add(orange_square, 1, 1, "(e)");
gallery.add(purple_square, 1, 2, "(f)");

// Add gallery caption
gallery.caption_title("Figure 1:");
gallery.caption_text("A 2x3 gallery of colored squares demonstrating the layout system with automatic text wrapping for long captions that exceed the available width.");

// Gallery automatically renders!
gallery.render();

