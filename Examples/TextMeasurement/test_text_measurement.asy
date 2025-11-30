import MaximumMathematics;

// Test file to visualize text measurement functionality
// Shows characters with boxes to demonstrate width measurement

settings.outformat = "svg";

// All characters in a single string
string sample_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,;:!?()[]{}";

// Fixed 9x9 grid
int cols = 9;
int rows = 9;
int total_chars = length(sample_chars);

// Spacing between characters
real spacing = 1.0 * 2.0 / 3.0 * 0.9 * 0.9 * 0.9 * 0.9 * 0.9 * 0.9;  // 2/3 of 1cm, then reduced by 10% six times

unitsize(1cm);

// Calculate image size
real image_width = cols * spacing;
real image_height = rows * spacing;

// Set viewport to show the full image
size(image_width, image_height);

// Draw white background
fill(box((0, 0), (image_width, image_height)), white);

// Starting position (top-left of grid)
real start_x = 0;
real start_y = image_height;

// Draw characters in a grid with boxes
int char_index = 0;
for (int row = 0; row < rows; ++row) {
    for (int col = 0; col < cols; ++col) {
        if (char_index < total_chars) {
            // Extract exactly one character at position char_index
            // substr(string, pos, n) where n is the length (not end position)
            string ch = substr(sample_chars, char_index, 1);
            
            // Calculate cell position
            real cell_x = start_x + col * spacing;
            real cell_y = start_y - row * spacing;
            
            // Draw box around the entire cell
            path cell_box = (cell_x, cell_y - spacing)--
                           (cell_x + spacing, cell_y - spacing)--
                           (cell_x + spacing, cell_y)--
                           (cell_x, cell_y)--cycle;
            draw(cell_box, p=gray + linewidth(0.3));
            
            // Draw the character (centered in cell)
            label(ch, (cell_x + spacing / 2, cell_y - spacing / 2), p=text_normal.p, align=Center);
            
            char_index = char_index + 1;
        }
    }
}

