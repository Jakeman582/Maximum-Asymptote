import MaximumMathematics;

// Create a gallery with 2 rows and 2 columns
Gallery gallery = Gallery(2, 2);
gallery.width(20);
gallery.height(12);
gallery.padding(0.3);
gallery.label_scheme(LOWERCASE);

///////////////////////////////////////////////////////////////////////////////////////////////////
// (a) Non-special relation (neither injective nor surjective)
// Domain: {1,2,3} -> Codomain: {a,b}
// 1->a, 2->a, 3->a: not injective (multiple sources map to a), not surjective (b is never hit)
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram1 = RelationDiagram();
diagram1.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram1.add_set(new string[] {"a", "b"}, "Codomain");
diagram1.add_relation(0, 1, new pair[] {(0,0), (1,0), (2,0)});  // All map to a, b not hit

///////////////////////////////////////////////////////////////////////////////////////////////////
// (b) Injective relation (one-to-one, but not onto)
// Domain: {1,2} -> Codomain: {a,b,c}
// 1->a, 2->b: injective (each source maps to a unique target), not surjective (c is not hit)
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram2 = RelationDiagram();
diagram2.add_set(new string[] {"1", "2"}, "Domain");
diagram2.add_set(new string[] {"a", "b", "c"}, "Codomain");
diagram2.add_relation(0, 1, new pair[] {(0,0), (1,1)});  // 1->a, 2->b, c not hit

///////////////////////////////////////////////////////////////////////////////////////////////////
// (c) Surjective relation (onto, but not one-to-one)
// Domain: {1,2,3} -> Codomain: {a,b}
// 1->a, 2->a, 3->b: surjective (every target is hit), not injective (1 and 2 both map to a)
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram3 = RelationDiagram();
diagram3.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram3.add_set(new string[] {"a", "b"}, "Codomain");
diagram3.add_relation(0, 1, new pair[] {(0,0), (1,0), (2,1)});  // 1->a, 2->a, 3->b

///////////////////////////////////////////////////////////////////////////////////////////////////
// (d) Bijective relation (one-to-one and onto)
// Domain: {1,2,3} -> Codomain: {a,b,c}
// 1->a, 2->b, 3->c: a perfect one-to-one correspondence
///////////////////////////////////////////////////////////////////////////////////////////////////

RelationDiagram diagram4 = RelationDiagram();
diagram4.add_set(new string[] {"1", "2", "3"}, "Domain");
diagram4.add_set(new string[] {"a", "b", "c"}, "Codomain");
diagram4.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});  // Perfect 1-1 correspondence

// Added in row-major order: (a) top-left, (b) top-right, (c) bottom-left, (d) bottom-right
gallery.add(diagram1);
gallery.add(diagram2);
gallery.add(diagram3);
gallery.add(diagram4);

gallery.caption_title("Figure 1");
gallery.caption_text("(a) neither injective nor surjective, (b) injective but not surjective, (c) surjective but not injective, (d) bijective.");
