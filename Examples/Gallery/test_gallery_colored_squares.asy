import MaximumMathematics;

// Create a gallery with 2 rows and 2 columns
Gallery gallery = Gallery(2, 2, visual_width=3, visual_height=2);

// Configure gallery-wide settings
gallery.set_margin(0.5);
gallery.set_padding(0.3);
gallery.set_caption_height(0.8);

// Helper function to create a colored square picture
picture create_colored_square(real width, real height, pen color) {
    picture pic = new picture;
    unitsize(pic, 1cm);
    fill(pic, box((0, 0), (width, height)), color);
    draw(pic, box((0, 0), (width, height)), black + linewidth(1));
    return pic;
}

// Create colored squares for each cell
picture red_square = create_colored_square(3, 2, red);
picture blue_square = create_colored_square(3, 2, blue);
picture green_square = create_colored_square(3, 2, green);
picture yellow_square = create_colored_square(3, 2, yellow);

// Add squares to gallery with captions
gallery.add(red_square, 0, 0, "(a)");
gallery.add(blue_square, 0, 1, "(b)");
gallery.add(green_square, 1, 0, "(c)");
gallery.add(yellow_square, 1, 1, "(d)");

// Gallery automatically renders!
gallery.render();
