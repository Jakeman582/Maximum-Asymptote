---
title: RelationDiagram
parent: Visualizations
nav_order: 1
---

# RelationDiagram
{: .no_toc }

Functions, relations, and mappings between sets.

```asy
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2", "3"}, "A");
diagram.add_set(new string[] {"a", "b", "c"}, "B");
diagram.add_set(new string[] {"u", "v", "w"}, "C");

// Relations connect neighboring sets by element index: (source_index, target_index)
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1), (2,2)});   // A -> B
diagram.add_relation(1, 2, new pair[] {(0,1), (1,2), (2,0)});   // B -> C

Image img = Image();
img.padding(0.5);
img.add(diagram);
```

<img src="{{ '/assets/images/relation-diagram/relation-diagram.svg' | relative_url }}" alt="A RelationDiagram showing arrows between three sets" class="mx-auto d-block" style="max-width: 500px; width: 100%;" />

## Methods

| Method | Purpose |
|---|---|
| `RelationDiagram()` / `RelationDiagram(sets, names)` | Empty, or seeded with `string[][]` sets and `string[]` names |
| `add_set(elements, name="", width=0)` | Add one set (`width=0` auto-sizes) |
| `add_sets(sets, names={}, widths={})` | Add several sets at once |
| `set_width(set_index, width)` | Fix a set's width |
| `add_relation(from_set, to_set, pairs)` | Arrows between two sets, by element index |
| `set_debug_mode(bool)` | Draw zones and boundaries |
