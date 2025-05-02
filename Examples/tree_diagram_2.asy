///////////////////////////////////////////////////////////////////////////////////////////////////
// Library imports
///////////////////////////////////////////////////////////////////////////////////////////////////

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
real width = 14;
real height = 11;
real margin = 0.2;
real horizontal_margin = 0.3;
real vertical_margin = 0.1;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram user visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Label locations relative to the width
real label_location_factor_1 = 0.5;
real label_location_factor_2 = 0.9;

// Label widths
real label_width_1 = 0.6;
real label_width_2 = 1.3;

// Dealing with margins and spacing of the branches
real branch_margin_1 = 0.1;
real branch_margin_2 = 0.1;

// Dealing with margins and spacing of the labels and their dots
real dot_margin_1 = 0.1;
real dot_margin_2 = 0.1; 

// How big the dots should be
dotfactor = 8;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram derived visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Since there are three sets, the first set will appear on the 1/3 vertical mark, and 
// the second set will appear on the 2/3 vertical mark. The root and third set will 
// appear on the image's edges.
real label_location_1 = width * label_location_factor_1;
real label_location_2 = width * label_location_factor_2;

// Determine how much vertical space each branch should use
real branch_1_height = (height - (2 * vertical_margin) - ((A.length - 1) * branch_margin_1)) / A.length;
real branch_2_height = branch_1_height / B.length;

// Handle the root location, which means we also have to consider the gaps between branches
pair root = (0, height / 2);

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram drawing
///////////////////////////////////////////////////////////////////////////////////////////////////

// Draw the background
fill(box((-horizontal_margin, -vertical_margin), (width + horizontal_margin, height + vertical_margin)), white);

dot(root);

for(int i = 0; i < A.length; ++i){

    // Determine where the label should be printed
    real branch_1_top = height - vertical_margin - (i * (branch_1_height + branch_margin_1));
    pair element_1_location = (label_location_1, branch_1_top - (branch_1_height / 2.0));
    string element_1_string = A[i];

    // If we are supposed to draw pruned branches, color them the pruned color
    if(pruned_branches.is_pruned(Branch2(A[i]))) {
        if(draw_pruned_branches) {
            draw(root--(element_1_location - dot_margin_1), pruned_branch_color);
            dot(element_1_location - dot_margin_1);
            label(element_1_string, element_1_location, p = label_size + pruned_branch_color, align = right);
        }
    } else {
        draw(root--(element_1_location - dot_margin_1));
        dot(element_1_location - dot_margin_1);
        label(element_1_string, element_1_location, p = label_size, align = right);
    }

    // Branch into the second set
    for(int j = 0; j < B.length; ++j) {

        // Determine where the label should be printed
        real branch_2_top = branch_1_top - (j * (branch_2_height + branch_margin_2));
        pair element_2_location = (label_location_2, branch_2_top - (branch_2_height / 2.0));
        string element_2_string = "(" + A[i] + "," + B[j] + ")";

        // If we are supposed to draw pruned branches, color them the pruned color
        if(pruned_branches.is_pruned(Branch2(A[i], B[j]))) {
            if(draw_pruned_branches) {
                draw((element_1_location + label_width_1 + dot_margin_1)--(element_2_location - dot_margin_2), pruned_branch_color);
                dot(element_1_location + label_width_1 + dot_margin_1);
                dot(element_2_location - dot_margin_2);
                label(element_2_string, element_2_location, p = label_size + pruned_branch_color, align = right);
            }
        } else {
            draw((element_1_location + label_width_1 + dot_margin_1)--(element_2_location - dot_margin_2));
            dot(element_1_location + label_width_1 + dot_margin_1);
            dot(element_2_location - dot_margin_2);
            label(element_2_string, element_2_location, p = label_size, align = right);
        }

    }

}