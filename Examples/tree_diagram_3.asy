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

string[] A = {"H", "T"};
string[] B = {"$\spadesuit$", "$\heartsuit$", "$\diamondsuit$", "$\clubsuit$"};
string[] C = {"B", "R"};

///////////////////////////////////////////////////////////////////////////////////////////////////
// Pruned Branches
///////////////////////////////////////////////////////////////////////////////////////////////////

bool draw_pruned_branches = true;

PrunedBranches3 pruned_branches;
pruned_branches.prune_branch(Branch3("T"));
pruned_branches.prune_branch(Branch3("H", "$\diamondsuit$"));
pruned_branches.prune_branch(Branch3("H", "$\clubsuit$", "R"));

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

defaultpen(fontsize(8pt));

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram user visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Dealing with margins and spacing of the branches
real branch_gap_1 = 0.5;
real branch_gap_2 = 0.5;
real branch_gap_3 = 0;

// Dealing with margins and spacing of the labels and their dots
real margin = 1;
real margin_label_1 = 0.25;
real margin_label_2 = 0.5;
real margin_label_3 = 0.6;  

// Drawing the dots
dotfactor = 8;

///////////////////////////////////////////////////////////////////////////////////////////////////
// Tree Diagram derived visual settings
///////////////////////////////////////////////////////////////////////////////////////////////////

// Since there are three sets, the first set will appear on the 1/3 vertical mark, and 
// the second set will appear on the 2/3 vertical mark. The root and third set will 
// appear on the image's edges.
real branch_width = width / 3;
real branch_line_1 = branch_width;
real branch_line_2 = branch_line_1 + branch_width;

// Determine how much vertical space each branch should use
real branch_1_height = (height - ((A.length -1) * branch_gap_1)) / A.length;
real branch_2_height = (branch_1_height - ((B.length - 1) * branch_gap_2)) / B.length;
real branch_3_height = branch_2_height / C.length;

// Handle the root location, which means we also have to consider the gaps between branches
pair root = (0, height / 2);

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
    if(pruned_branches.is_pruned(Branch3(A[i]))) {
        if(draw_pruned_branches) {
            draw(root--(element_1_location + margin_label_1 * W), pruned_branch_color);
            dot(element_1_location + margin_label_1 * W);
            label(element_1_string, element_1_location, pruned_branch_color);
        }
    } else {
        draw(root--(element_1_location + margin_label_1 * W));
        dot(element_1_location + margin_label_1 * W);
        label(element_1_string, element_1_location);
    }

    // Branch into the second set
    for(int j = 0; j < B.length; ++j) {

        // Determine where the label should be printed
        real branch_2_top = branch_1_top - (j * (branch_2_height + branch_gap_2));
        pair element_2_location = (branch_line_2, branch_2_top - (branch_2_height / 2.0));
        string element_2_string = "(" + A[i] + "," + B[j] + ")";

        // If we are supposed to draw pruned branches, color them the pruned color
        if(pruned_branches.is_pruned(Branch3(A[i], B[j]))) {
            if(draw_pruned_branches) {
                draw((element_1_location + margin_label_1 * E)--(element_2_location + margin_label_2 * W), pruned_branch_color);
                dot(element_1_location + margin_label_1 * E);
                dot(element_2_location + margin_label_2 * W);
                label(element_2_string, element_2_location, pruned_branch_color);
            }
        } else {
            draw((element_1_location + margin_label_1 * E)--(element_2_location + margin_label_2 * W));
            dot(element_1_location + margin_label_1 * E);
            dot(element_2_location + margin_label_2 * W);
            label(element_2_string, element_2_location);
        }

        // Branch into the third set
        for(int k = 0; k < C.length; ++k){

            // Determine where the label should be drawn
            real branch_3_top = branch_2_top - (k * branch_3_height);
            pair element_3_location = (width, branch_3_top - (branch_3_height / 2.0));
            string element_3_string = "(" + A[i] + "," + B[j] + "," + C[k] + ")";

            // If we are supposed to draw pruned branches, color them the pruned color
            if(pruned_branches.is_pruned(Branch3(A[i], B[j], C[k]))) {
                if(draw_pruned_branches) {
                    draw((element_2_location + margin_label_2 * E)--(element_3_location + margin_label_3 * W), pruned_branch_color);
                    dot(element_2_location + margin_label_2 * E);
                    dot(element_3_location + margin_label_3 * W);
                    label(element_3_string, element_3_location, pruned_branch_color);
                }
            } else {
                draw((element_2_location + margin_label_2 * E)--(element_3_location + margin_label_3 * W));
                dot(element_2_location + margin_label_2 * E);
                dot(element_3_location + margin_label_3 * W);
                label(element_3_string, element_3_location);
            }

        }

    }

}