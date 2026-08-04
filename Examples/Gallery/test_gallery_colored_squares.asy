import MaximumMathematics;

// Create a gallery with 2 rows and 2 columns
Gallery gallery = Gallery(2, 2);
gallery.width(6);
gallery.height(4);
gallery.padding(0.3);
gallery.label_scheme(LOWERCASE);

// Helper function to create a colored square picture
picture create_colored_square(real width, real height, pen color) {
    picture pic = new picture;
    unitsize(pic, diagram_unit);
    fill(pic, box((0, 0), (width, height)), color);
    draw(pic, box((0, 0), (width, height)), black + linewidth(1));
    return pic;
}

// Create colored squares for each cell
picture red_square = create_colored_square(3, 2, red);
picture blue_square = create_colored_square(3, 2, blue);
picture green_square = create_colored_square(3, 2, green);
picture yellow_square = create_colored_square(3, 2, yellow);

// Add squares in row-major order: top-left, top-right, bottom-left, bottom-right
gallery.add_visual(red_square);
gallery.add_visual(blue_square);
gallery.add_visual(green_square);
gallery.add_visual(yellow_square);
