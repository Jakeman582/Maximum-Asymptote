///////////////////////////////////////////////////////////////////////////////////////////////////
// Text measurement utility functions
// Provides functions to measure actual rendered text width for visual testing
// Used to help determine spacing values (char_width_estimate) for TypographyPen structs
///////////////////////////////////////////////////////////////////////////////////////////////////

// Measure the actual width of text when rendered with a given pen
// Returns the width in the current units
// Use this function to visually test and determine appropriate char_width_estimate values
real measure_text_width(string text, pen p) {
    if (length(text) == 0) {
        return 0;
    }
    
    // Create a temporary picture to measure the text
    picture temp_pic = new picture;
    unitsize(temp_pic, 1cm);  // Use 1cm as base unit
    
    // Render the text with the given pen at origin, left-aligned
    label(temp_pic, text, (0, 0), p=p, align=W);
    
    // Get the size of the picture (this is more reliable than min/max)
    pair pic_size = size(temp_pic);
    
    // Return the width (x component)
    real text_width = pic_size.x;
    
    // Cap at reasonable maximum to prevent measurement errors
    // Typical text width should be much less than 100 units
    if (text_width > 100) {
        return length(text) * 0.4;  // Fallback if measurement is clearly wrong
    }
    
    // If width is 0 or very small, use simple fallback (avoid circular dependency)
    if (text_width < 0.1) {
        return length(text) * 0.4;  // Simple fallback estimate
    }
    
    return text_width;
}

// Find a single character width that works for all characters (monospace-like)
// Measures a sample of characters and returns the maximum width
// Use this function to visually test and determine appropriate char_width_estimate values
real find_universal_char_width(pen p) {
    // Sample characters: all letters, numbers, and common symbols
    string sample_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,;:!?()[]{}";
    
    real max_width = 0;
    int count = 0;
    
    // Measure each character
    for (int i = 0; i < length(sample_chars); ++i) {
        string ch = substr(sample_chars, i, i+1);
        real char_width = measure_text_width(ch, p);
        // Only count valid measurements (reasonable range: 0.01 to 5.0)
        if (char_width > 0.01 && char_width < 5.0) {
            max_width = max(max_width, char_width);
            count = count + 1;
        }
    }
    
    if (count == 0 || max_width < 0.1) {
        // Fallback to simple estimation (avoid circular dependency)
        // Use a conservative estimate based on typical font sizes
        return 0.4;  // Default fallback
    }
    
    // Use the maximum width to ensure all characters fit
    // This gives us a "monospace" width that accommodates the widest character
    return max_width;
}

