# Version 3 implementation

Version 3 extends the existing timeline painters rather than adding a new
screen, navigation shell, or dashboard.

## Rendering pipeline

The neural-core indicator is painted in this order:

1. shadow and volumetric aura
2. bloom
3. halo rings and vector-field arcs
4. neural glass body and nucleus
5. chromatic fringe and spectral ring
6. reflections, orbit particles, and lens rays
7. internal lattice nodes and shockwaves
8. diffraction spikes, sparks, and focus halo

The photon-lattice connector is painted in this order:

1. base energy beam
2. wide photon field
3. synchronized wave strands
4. cross-links and interference marks
5. packet trails and transverse flares
6. deterministic moving particles

## Performance

`NeonTimelineRenderQuality` changes only sampling density:

- `balanced`: dense lists and lower-power devices
- `high`: default product quality
- `ultra`: hero timelines and showcase nodes

All effects remain deterministic, package-local, dependency-free, and driven
by the shared `NeonTimelineMotionScope`.
