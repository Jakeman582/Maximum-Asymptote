///////////////////////////////////////////////////////////////////////////////////////////////////
// Library imports
///////////////////////////////////////////////////////////////////////////////////////////////////
import graph;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Maximum Mathematics import
///////////////////////////////////////////////////////////////////////////////////////////////////
import MaximumMathematics;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Set Definitions
///////////////////////////////////////////////////////////////////////////////////////////////////

string[] A = {"$\spadesuit$", "$\heartsuit$", "$\diamondsuit$", "$\clubsuit$"};
string[] B = {"B", "R"};

///////////////////////////////////////////////////////////////////////////////////////////////////
// Pruned Branches
///////////////////////////////////////////////////////////////////////////////////////////////////

bool draw_pruned_branches = true;

PrunedBranches2 pruned_branches;
pruned_branches.prune_branch(Branch2("$\heartsuit$"));
pruned_branches.prune_branch(Branch2("$\clubsuit$", "R"));

///////////////////////////////////////////////////////////////////////////////////////////////////
// Output settings
///////////////////////////////////////////////////////////////////////////////////////////////////

settings.outformat = "svg";

///////////////////////////////////////////////////////////////////////////////////////////////////
// Image settings
///////////////////////////////////////////////////////////////////////////////////////////////////

unitsize(1cm);
real width = 13;
real height = 9;
real margin = 0.6;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram user visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Dealing with margins and spacing of the branches
real branch_gap_1 = 0.5;
real branch_gap_2 = 0.5;

// Dealing with margins and spacing of the labels and their dots
real margin_label_1 = 0.4;
real margin_label_2 = 0.8;

// Drawing the dots
dotfactor = 8;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram derived visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Since there are two sets, the first set will appear on the 1/2 line. The root and 
// second set will appear on the image's edges.
real branch_width = width / 2;
real branch_line_1 = branch_width;

// Determine how much vertical space each branch should use
real branch_1_height = (height - ((A.length -1) * branch_gap_1)) / A.length;
real branch_2_height = (branch_1_height - ((B.length - 1) * branch_gap_2)) / B.length;

// Handle the root location, which means we also have to consider the gaps between branches
pair root = (0, height / 2);

defaultpen(fontsize(8pt));

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram drawing
///////////////////////////////////////////////////////////////////////////////////////////////////

// Draw the background
fill(box((-margin, -margin), (width + margin, height + margin)), white);

dot(root);

for(int i = 0; i < A.length; ++i){

    // Determine where the label should be printed
    real branch_1_top = height - (i * (branch_1_height + branch_gap_1));
    pair element_1_location = (branch_line_1, branch_1_top - (branch_1_height / 2.0));
    string element_1_string = A[i];
    
    // If we are supposed to draw pruned branches, color them the pruned color
    if(pruned_branches.is_pruned(Branch2(A[i]))) {
        if(draw_pruned_branches) {
            draw(root--(element_1_location + margin_label_1 * W), pruned_branch_color);
            dot(element_1_location + margin_label_1 * W);
            label(element_1_string, element_1_location, p = label_size + pruned_branch_color);
        }
    } else {
        draw(root--(element_1_location + margin_label_1 * W));
        dot(element_1_location + margin_label_1 * W);
        label(element_1_string, element_1_location, p = label_size);
    }
    

    // Branch into the second set
    for(int j = 0; j < B.length; ++j) {

        // Determine where the label should be printed
        real branch_2_top = branch_1_top - (j * (branch_2_height + branch_gap_2));
        pair element_2_location = (width, branch_2_top - (branch_2_height / 2.0));
        string element_2_string = "(" + A[i] + "," + B[j] + ")";

        // If we are supposed to draw pruned branches, color them the pruned color
        if(pruned_branches.is_pruned(Branch2(A[i], B[j]))) {
            if(draw_pruned_branches) {
                draw((element_1_location + margin_label_1 * E)--(element_2_location + margin_label_2 * W), pruned_branch_color);
                dot(element_1_location + margin_label_1 * E);
                dot(element_2_location + margin_label_2 * W);
                label(element_2_string, element_2_location, p = label_size + pruned_branch_color);
            }
        } else {
            dot(element_1_location + margin_label_1 * E);
            draw((element_1_location + margin_label_1 * E)--(element_2_location + margin_label_2 * W));
            dot(element_2_location + margin_label_2 * W);
            label(element_2_string, element_2_location, p = label_size);
        }

    }

}