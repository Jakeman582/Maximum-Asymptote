///////////////////////////////////////////////////////////////////////////////////////////////////
// Text wrapping utility functions
///////////////////////////////////////////////////////////////////////////////////////////////////

// Wrap text to fit within a given width
// Returns an array of strings, one per line
// Uses text_normal TypographyPen as the default
string[] wrap_text(string text, real max_width, TypographyPen typo_pen = text_normal) {
    real char_width = typo_pen.char_width_estimate > 0 ? typo_pen.char_width_estimate : 0.4374;
    if (length(text) == 0) {
        return new string[] {""};
    }
    
    // Split text into words (split on spaces)
    string[] words = split(text, " ");
    
    if (words.length == 0) {
        return new string[] {""};
    }
    
    string[] lines = new string[];
    string current_line = "";
    
    for (int i = 0; i < words.length; ++i) {
        string word = words[i];
        string test_line = current_line;
        
        // Add word to current line (with space if not first word)
        if (length(current_line) > 0) {
            test_line = test_line + " " + word;
        } else {
            test_line = word;
        }
        
        // Estimate width of test line
        real test_width = length(test_line) * char_width;
        
        // If line would exceed max width, start a new line
        if (test_width > max_width && length(current_line) > 0) {
            // Save current line and start new one
            lines.push(current_line);
            current_line = word;
        } else {
            // Add word to current line
            current_line = test_line;
        }
    }
    
    // Add the last line if it's not empty
    if (length(current_line) > 0) {
        lines.push(current_line);
    }
    
    return lines;
}

