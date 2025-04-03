settings.outformat = "png";
settings.render = 16;

// We want the final image to be a square scaled based on a given length
real length = 5;

// Image sizing and rendering options
size(length * cm);
unitsize(1cm);

defaultpen(fontsize(8pt));

string[] set_1 = {"$\spadesuit$", "$\heartsuit$", "$\diamondsuit$", "$\clubsuit$"};
string[] set_2 = {"B", "R"};

// Data about the image
real x_min = -length;
real x_max = length;
real y_min = -length;
real y_max = length;

real width = x_max - x_min;
real height = y_max - y_min;

// Dealing with margins and spacing of the branches
real branch_gap_1 = 0.5;
real branch_gap_2 = 0.5;

// Dealing with margins and spacing of the labels
real margin = 1;
real margin_label_1 = 0.25;
real margin_label_2 = 0.5;

// Since there are two sets, the first set will appear on the 1/2. The root and second set will 
// appear on the image's edges.
real branch_width = width / 2;
real branch_line_1 = x_min + branch_width;

// Determine how much vertical space each branch should use
real branch_1_height = (height - ((set_1.length -1) * branch_gap_1)) / set_1.length;
real branch_2_height = (branch_1_height - ((set_2.length - 1) * branch_gap_2)) / set_2.length;

// Handle the root location, which means we also have to consider the gaps between branches
pair root = (x_min + margin, 0);
dot(root);

for(int i = 0; i < set_1.length; ++i){

    // Determine where the label should be printed
    real branch_1_top = x_max - (i * (branch_1_height + branch_gap_1));
    pair element_1_location = (branch_line_1, branch_1_top - (branch_1_height / 2.0));
    string element_1_string = set_1[i];
    
    // Draw the label for this element
    draw(root--(element_1_location + margin_label_1 * W));
    dot(element_1_location + margin_label_1 * W);
    label(element_1_string, element_1_location);

    // Branch into the second set
    for(int j = 0; j < set_2.length; ++j) {

        // Determine where the label should be printed
        real branch_2_top = branch_1_top - (j * (branch_2_height + branch_gap_2));
        pair element_2_location = (x_max - margin, branch_2_top - (branch_2_height / 2.0));
        string element_2_string = "(" + set_1[i] + "," + set_2[j] + ")";

        // Draw the label
        dot(element_1_location + margin_label_1 * E);
        draw((element_1_location + margin_label_1 * E)--(element_2_location + margin_label_2 * W));
        dot(element_2_location + margin_label_2 * W);
        label(element_2_string, element_2_location);

    }

}