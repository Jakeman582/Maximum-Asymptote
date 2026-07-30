////////////////////////////////////////////////////////////////////////////////////////////////////
// File: BooleanExpression.asy
//
// Description:
// Parses a programmer-style boolean expression string (identifiers, !, &, |, and parentheses; ! >
// & > | precedence) into an ExprNode tree, and normalizes that tree into negation normal form
// (NNF) — pushing every negation down to the leaves via De Morgan's laws, so a NOT node never
// appears in a normalized tree at all; a negated variable is just a LEAF with negated=true instead.
// Used by SwitchingNetwork, but not specific to it.
////////////////////////////////////////////////////////////////////////////////////////////////////

int EXPR_LEAF = 0;
int EXPR_NOT = 1;
int EXPR_AND = 2;
int EXPR_OR = 3;

// A node in a boolean expression tree.
//
// Field applicability by kind:
//    variable, negated - LEAF only. negated is always false on a freshly parsed tree (raw parse
//                        trees represent negation with a NOT node instead); normalize() below is
//                        what moves negation onto the leaf itself.
//    children          - NOT: exactly 1 child. AND/OR: exactly 2 children (chains like A & B & C
//                        parse as nested binary nodes, e.g. AND(AND(A,B),C) — equivalent to a
//                        flat n-ary AND for every purpose this tree is used for).
struct ExprNode {
    int kind;
    string variable;
    bool negated;
    ExprNode[] children;
}

// Mutable scan position over the input string, shared across parse_level()'s recursive calls.
struct ParserState {
    string input;
    int pos;
    int len;

    void operator init(string input) {
        this.input = input;
        this.pos = 0;
        this.len = length(input);
    }
}

bool is_identifier_char(string c) {
    return (c >= "a" && c <= "z") || (c >= "A" && c <= "Z") || (c >= "0" && c <= "9") || c == "_";
}

void skip_whitespace(ParserState s) {
    while (s.pos < s.len && substr(s.input, s.pos, 1) == " ") ++s.pos;
}

string peek_char(ParserState s) {
    skip_whitespace(s);
    if (s.pos >= s.len) return "";
    return substr(s.input, s.pos, 1);
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: parse_level
//
// Description:
// Recursive-descent parser for one grammar level, folded into a single self-recursive function
// rather than the more usual one-function-per-level (parse_or/parse_and/parse_not/parse_atom, each
// calling the next): Asymptote does not support mutual recursion between separately named
// functions (confirmed directly — a forward-declared function's variable is still null when an
// earlier-defined function tries to call it, and struct methods can't reference a sibling declared
// later at all), so a parenthesized sub-expression's "re-enter the grammar from the top" step has
// to be a call to this same function instead. level 0 = OR (lowest precedence), 1 = AND, 2 =
// NOT/atom (highest) — matching ! > & > | binding order.
//
// Inputs:
//    s     - Shared mutable scan position; advanced past whatever this call consumes.
//    level - Grammar level to parse at (0, 1, or 2 — see above).
//
// Outputs:
//    node - The parsed subtree for this level.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode parse_level(ParserState s, int level) {
    if (level == 0) {
        ExprNode left = parse_level(s, 1);
        while (peek_char(s) == "|") {
            ++s.pos;
            ExprNode right = parse_level(s, 1);
            ExprNode n = new ExprNode;
            n.kind = EXPR_OR;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else if (level == 1) {
        ExprNode left = parse_level(s, 2);
        while (peek_char(s) == "&") {
            ++s.pos;
            ExprNode right = parse_level(s, 2);
            ExprNode n = new ExprNode;
            n.kind = EXPR_AND;
            n.children = new ExprNode[] {left, right};
            left = n;
        }
        return left;
    } else {
        if (peek_char(s) == "!") {
            ++s.pos;
            ExprNode child = parse_level(s, 2);   // right-recursive, so !!A parses as NOT(NOT(A))
            ExprNode n = new ExprNode;
            n.kind = EXPR_NOT;
            n.children = new ExprNode[] {child};
            return n;
        }
        if (peek_char(s) == "(") {
            ++s.pos;
            ExprNode e = parse_level(s, 0);
            if (peek_char(s) != ")") {
                abort("SwitchingNetwork: expected ')' in expression: " + s.input);
            }
            ++s.pos;
            return e;
        }
        skip_whitespace(s);
        int start = s.pos;
        while (s.pos < s.len && is_identifier_char(substr(s.input, s.pos, 1))) ++s.pos;
        if (s.pos == start) {
            abort("SwitchingNetwork: expected a variable name at position " + string(start)
                  + " in expression: " + s.input);
        }
        ExprNode n = new ExprNode;
        n.kind = EXPR_LEAF;
        n.variable = substr(s.input, start, s.pos - start);
        return n;
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: parse_boolean_expression
//
// Description:
// Parse a full boolean expression string into a raw ExprNode tree (still containing NOT nodes —
// see normalize() to convert to negation normal form). Aborts if the expression contains anything
// left over after a complete parse (e.g. a stray trailing character or an unmatched paren).
//
// Inputs:
//    input - The expression string, e.g. "A & (B | !C)".
//
// Outputs:
//    root - The raw parsed tree.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode parse_boolean_expression(string input) {
    ParserState s = ParserState(input);
    ExprNode result = parse_level(s, 0);
    skip_whitespace(s);
    if (s.pos != s.len) {
        abort("SwitchingNetwork: unexpected character '" + peek_char(s) + "' at position "
              + string(s.pos) + " in expression: " + input);
    }
    return result;
}

////////////////////////////////////////////////////////////////////////////////////////////////////
// Function: normalize
//
// Description:
// Convert a raw expression tree into negation normal form: every NOT is pushed down to the leaves
// via De Morgan's laws (NOT(AND(a,b)) = OR(NOT a, NOT b); NOT(OR(a,b)) = AND(NOT a, NOT b)) and
// double negations cancel, so the returned tree contains only LEAF, AND, and OR nodes — a LEAF's
// own negated field carries what would otherwise have been a NOT wrapping it.
//
// Inputs:
//    node   - Subtree to normalize.
//    negate - Whether this subtree is under an odd number of enclosing NOTs (pass false at the
//             top-level call).
//
// Outputs:
//    node - The normalized subtree.
////////////////////////////////////////////////////////////////////////////////////////////////////
ExprNode normalize(ExprNode node, bool negate) {
    if (node.kind == EXPR_LEAF) {
        ExprNode n = new ExprNode;
        n.kind = EXPR_LEAF;
        n.variable = node.variable;
        n.negated = negate;
        return n;
    } else if (node.kind == EXPR_NOT) {
        return normalize(node.children[0], !negate);
    } else if (node.kind == EXPR_AND) {
        ExprNode a = normalize(node.children[0], negate);
        ExprNode b = normalize(node.children[1], negate);
        ExprNode n = new ExprNode;
        n.kind = negate ? EXPR_OR : EXPR_AND;
        n.children = new ExprNode[] {a, b};
        return n;
    } else {
        ExprNode a = normalize(node.children[0], negate);
        ExprNode b = normalize(node.children[1], negate);
        ExprNode n = new ExprNode;
        n.kind = negate ? EXPR_AND : EXPR_OR;
        n.children = new ExprNode[] {a, b};
        return n;
    }
}
