---
title: AccumulationTable
parent: Visualizations
nav_order: 3
---

# AccumulationTable
{: .no_toc }

An iterative accumulation: starting from a seed, each row applies your function to the previous total. Columns are Step, Current Total, Change, and Next Total.

```asy
real compound(real x) { return x * 1.05; }   // 5% per period

AccumulationTable table = AccumulationTable(1000, 8, compound, "Compound Interest (5\%)");

Image img = Image();

img.width(18);

img.height(9);
img.padding(0.5);
img.add(table);
```

<img src="{{ '/assets/images/accumulation-table/accumulation-table.svg' | relative_url }}" alt="An accumulation table for compound interest" class="mx-auto d-block" style="max-width: 650px; width: 100%;" />

## Methods

| Method | Purpose |
|---|---|
| `AccumulationTable(seed=0, steps=10, func=identity, title="Accumulation Table")` | Build the table |
| `set_title(title)` | Set the top header |
| `set_step_header / set_accum_header / set_change_header / set_next_total_header(label)` | Rename a column |
| `set_debug_mode(bool)` | Draw bounds |

`func` has type `real_function_1` (`real(real)`) and maps the current total to the next total.
