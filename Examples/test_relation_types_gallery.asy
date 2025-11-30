import MaximumMathematics;

// Create a gallery with 1 row and 4 columns
Gallery gallery = Gallery(1, 4, visual_width=4, visual_height=3);

// Configure gallery-wide settings
gallery.set_margin(0.5);
gallery.set_padding(0.3);
gallery.set_caption_height(0.8);

///////////////////////////////////////////////////////////////////////////////////////////////////
// 1. Non-special relation (neither injective nor surjective)
// Domain: {1,2,3} -> Codomain: {a,b}
// 1->a, 2->a, 3->b
// Not injective (1 and 2 both map to a)
// Not surjective (b is hit, but a is hit twice, so it's actually surjective... let me fix this)
// Actually: 1->a, 2->a, 3->a (not surjective since b is not hit, not injective since multiple map to a)
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram1 = RelationDiagram();
diagram1.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram1.add_set(new string[] {"a", "b"}, "Codomain");
diagram1.add_relation(0, 1, new pair[] {(0,0), (1,0), (2,0)});  // All map to a, b not hit

gallery.add(diagram1, 0, 0, "Non-special:", "Neither injective nor surjective");

///////////////////////////////////////////////////////////////////////////////////////////////////
// 2. Injective relation (one-to-one, but not onto)
// Domain: {1,2} -> Codomain: {a,b,c}
// 1->a, 2->b
// Injective: each source maps to unique target
// Not surjective: c is not hit
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram2 = RelationDiagram();
diagram2.add_set(new string[] {"1", "2"}, "Domain");
diagram2.add_set(new string[] {"a", "b", "c"}, "Codomain");
diagram2.add_relation(0, 1, new pair[] {(0,0), (1,1)});  // 1->a, 2->b, c not hit

gallery.add(diagram2, 0, 1, "Injective:", "One-to-one, not onto");

///////////////////////////////////////////////////////////////////////////////////////////////////
// 3. Surjective relation (onto, but not one-to-one)
// Domain: {1,2,3} -> Codomain: {a,b}
// 1->a, 2->a, 3->b
// Surjective: all targets are hit
// Not injective: 1 and 2 both map to a
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram3 = RelationDiagram();
diagram3.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram3.add_set(new string[] {"a", "b"}, "Codomain");
diagram3.add_relation(0, 1, new pair[] {(0,0), (1,0), (2,1)});  // 1->a, 2->a, 3->b

gallery.add(diagram3, 0, 2, "Surjective:", "Onto, not one-to-one");

///////////////////////////////////////////////////////////////////////////////////////////////////
// 4. Bijective relation (one-to-one and onto)
// Domain: {1,2,3} -> Codomain: {a,b,c}
// 1->a, 2->b, 3->c
// Bijective: perfect one-to-one correspondence
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram4 = RelationDiagram();
diagram4.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram4.add_set(new string[] {"a", "b", "c"}, "Codomain");
diagram4.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});  // Perfect 1-1 correspondence

gallery.add(diagram4, 0, 3, "Bijective:", "One-to-one and onto");

// Gallery automatically renders!



