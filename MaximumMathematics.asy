import graph;
import contour;  // used by ContinuousPlot.asy for implicit (f(x, y) = 0) functions

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include theme
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Theme/MaximumMathematicsTheme.asy";

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include utilities
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Utilities/TextMeasurement.asy";  // defines measure_text_size, used by wrap_text below
include "Utilities/TextWrapping.asy";
include "Utilities/TextSetWidth.asy";
include "Utilities/DefaultFunctions.asy";
include "Utilities/FunctionTypes.asy";
include "Utilities/Functions/Line.asy";   // defines Line, a predefined implicit_2-producing function type
include "Utilities/Functions/Conic.asy";  // defines Conic, a predefined implicit_2-producing function type
include "Utilities/AxisTicks.asy";        // defines compute_ticks, used by DiscretePlot and Plot below
include "Utilities/BooleanExpression.asy"; // defines ExprNode/parse_boolean_expression/normalize, used by SwitchingNetwork below
include "Utilities/GraphLayout.asy";      // defines the vertex-placement algorithms, used by GraphDiagram below

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include RelationDiagram
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Visualizations/RelationDiagram.asy";
include "Visualizations/DiscretePlot.asy";
include "Visualizations/ContinuousPlot.asy";
include "Visualizations/AccumulationTable.asy";
include "Visualizations/TruthTable.asy";
include "Visualizations/SwitchingNetwork.asy";
include "Visualizations/GraphDiagram.asy";

///////////////////////////////////////////////////////////////////////////////////////////////////
// Include utilities
///////////////////////////////////////////////////////////////////////////////////////////////////

include "Utilities/Image.asy";
include "Utilities/Gallery.asy";
