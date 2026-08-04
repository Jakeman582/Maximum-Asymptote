---
title: Standalone rendering
nav_order: 6
---

# Standalone rendering

If you want a visualization on its own, without an enclosing `Image`, call its `render(width, height, unit=diagram_unit)` and add the picture yourself. This is the one place you render explicitly.

```asy
RelationDiagram diagram = RelationDiagram();
diagram.add_set(new string[] {"1", "2"}, "A");
diagram.add_set(new string[] {"a", "b"}, "B");
diagram.add_relation(0, 1, new pair[] {(0,0), (1,1)});

picture p = diagram.render(8, 6);   // width, height (cm) — unit defaults to the theme's diagram_unit
add(currentpicture, p);
```

Every visualization implements the same `render(width, height, unit=diagram_unit)` contract and lays itself out to fill the given `width` x `height`. `unit` is only there to override the scale for this one call — pass it explicitly (e.g. `render(8, 6, 2cm)`) if you need a picture at a different scale than the rest of your figures; otherwise there's nothing to specify.
