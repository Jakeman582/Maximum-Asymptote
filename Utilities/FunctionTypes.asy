////////////////////////////////////////////////////////////////////////////////////////////////////
// File: FunctionTypes.asy
//
// Description:
// Provide reusable function type aliases for common Asymptote routines.
////////////////////////////////////////////////////////////////////////////////////////////////////

// Real-valued function aliases
using real_function_1 = real(real);             // Single-variable real-valued function
using real_function_2 = real(real, real);       // Two-variable real-valued function
using real_function_3 = real(real, real, real); // Three-variable real-valued function

// Implicit function aliases
using implicit_2 = real(real, real);            // Implicit relation f(x, y) = 0 for implicit plotting

// Boolean-valued function aliases
using bool_function_1 = bool(bool);                   // Single-variable boolean-valued function
using bool_function_2 = bool(bool, bool);             // Two-variable boolean-valued function
using bool_function_3 = bool(bool, bool, bool);       // Three-variable boolean-valued function
using bool_function_4 = bool(bool, bool, bool, bool); // Four-variable boolean-valued function
