unitsize(1cm);

// Sample text to display
string sample_text = "The quick brown fox jumps. 0123456789";

// Starting position
real y_start = 10;
real y_spacing = 1.0;  // Increased spacing to prevent overlap
real x_label = 0;
real x_text = 8.5;  // Lots of space between font names and sample text
real margin = 1.0;  // Increased margin to prevent text cutoff

// Calculate final y position (trace through all elements)
// Sans-serif: 5 fonts, Default: 1 font, Serif: 6 fonts (Bookman, NewCenturySchoolBook, Palatino, TimesRoman, TimesRoman Bold, TimesRoman Italic), Special: 3 fonts
// Plus section headers and spacing
real final_y = y_start - 0.5 - 5*y_spacing - 0.3 - 0.5 - 1*y_spacing - 0.3 - 0.5 - 6*y_spacing - 0.3 - 0.5 - 3*y_spacing;

// Draw white background first (extend much further left to cover all text, including left-aligned text)
pair min_corner = (x_label - margin - 4.0, final_y - margin - 0.5);
pair max_corner = (22, y_start + 2.5);  // Extended to accommodate sample text further right
fill(box(min_corner, max_corner), white);

// Function to draw a font sample
void draw_font_sample(string font_name, pen font_pen, real y_pos) {
    // Draw font name label
    label(font_name, (x_label, y_pos), align=W, fontsize(0.4cm));
    
    // Draw sample text with the font
    label(sample_text, (x_text, y_pos), align=W, p=fontsize(0.35cm) + font_pen);
}

// Draw title (centered over the content area)
label("Asymptote Font Samples", (11, y_start + 1.5), fontsize(0.6cm));

real current_y = y_start;

// Sans-serif fonts
label("Sans-serif Fonts:", (0, current_y + 0.3), fontsize(0.45cm), align=W);
current_y -= 0.5;

draw_font_sample("AvantGarde", AvantGarde(), current_y);
current_y -= y_spacing;

draw_font_sample("Helvetica", Helvetica(), current_y);
current_y -= y_spacing;

draw_font_sample("Helvetica Bold", Helvetica("b"), current_y);
current_y -= y_spacing;

draw_font_sample("Helvetica Italic", Helvetica("m", "it"), current_y);
current_y -= y_spacing;

draw_font_sample("Courier", Courier(), current_y);
current_y -= y_spacing;

// Default font (ComputerModern - LaTeX default)
current_y -= 0.3;
label("Default Font:", (0, current_y + 0.3), fontsize(0.45cm), align=W);
current_y -= 0.5;

// Default font (no font specified - uses LaTeX default)
label("Default (CM Roman)", (x_label, current_y), align=W, fontsize(0.4cm));
label(sample_text, (x_text, current_y), align=W, fontsize(0.35cm));  // No font specified = default
current_y -= y_spacing;

// Serif fonts
current_y -= 0.3;
label("Serif Fonts:", (0, current_y + 0.3), fontsize(0.45cm), align=W);
current_y -= 0.5;

draw_font_sample("Bookman", Bookman(), current_y);
current_y -= y_spacing;

draw_font_sample("NewCenturySchoolBook", NewCenturySchoolBook(), current_y);
current_y -= y_spacing;

draw_font_sample("Palatino", Palatino(), current_y);
current_y -= y_spacing;

draw_font_sample("TimesRoman", TimesRoman(), current_y);
current_y -= y_spacing;

draw_font_sample("TimesRoman Bold", TimesRoman("b"), current_y);
current_y -= y_spacing;

draw_font_sample("TimesRoman Italic", TimesRoman("m", "it"), current_y);
current_y -= y_spacing;

// Special fonts
current_y -= 0.3;
label("Special Fonts:", (0, current_y + 0.3), fontsize(0.45cm), align=W);
current_y -= 0.5;

draw_font_sample("ZapfChancery", ZapfChancery(), current_y);
current_y -= y_spacing;

// Symbol font - showing Greek letters (using character codes a-z map to Greek)
label("Symbol", (x_label, current_y), align=W, fontsize(0.4cm));
// In Symbol font, lowercase a-z map to Greek letters α-ω
label("abcdefghijklmnopqrstuvwxyz", (x_text, current_y), align=W, p=fontsize(0.35cm) + Symbol());
current_y -= y_spacing;

// ZapfDingbats - showing decorative symbols (using character codes)
label("ZapfDingbats", (x_label, current_y), align=W, fontsize(0.4cm));
// ZapfDingbats uses specific character codes - showing some common ones
// Using simple ASCII characters that map to symbols
label("ABCDEFGHIJKLMNOPQRSTUVWXYZ", (x_text, current_y), align=W, p=fontsize(0.35cm) + ZapfDingbats());
current_y -= y_spacing;

// Draw frame (matching background bounds)
pair min_corner = (x_label - margin - 4.0, current_y - margin - 0.5);
pair max_corner = (22, y_start + 2.5);
draw(box(min_corner, max_corner));

