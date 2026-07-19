# Sliders

## Zoom

`NeonPlannerZoomSlider` maps a continuous pointer position onto six semantic zoom levels. The timeline recomposes only when the semantic level changes. Keyboard arrows, Home/End, reset, and optional plus/minus actions are supported.

## Snap strength

`NeonPlannerSnapSlider` exposes off, soft, balanced, and strong settings with a custom thin track and semantic value labels.

## Time range

`NeonPlannerTimeRangeSlider` has distinct start/end thumbs, duration constraints, snap interval, blocked segments, keyboard control, and optional direct start/end actions. It does not use the stock Material `RangeSlider` visual.

All controls use large gesture regions even where the visible track is thin.
