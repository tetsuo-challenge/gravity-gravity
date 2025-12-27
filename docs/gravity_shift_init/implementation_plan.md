# Level Redesign Specifications

## Physics Constraints
- **Jump Height**: 120px. (Single jump cannot reach Y=400 from Y=600 without double jump or gravity switch).
- **Gravity Switch**: Can travel infinitely vertical until collision.
- **Horizontal Reach**: At full speed (400px/s), a full jump (0.8s air time) covers 320px.

## [Level 2: Velocity] Layout
**Goal**: High speed flow.

1.  **Start (0 - 1500px)**
    - Floor: Y=600 (Solid).
    - Ceiling: Y=100 (Solid).
    - **Action**: Run -> Jump at X=1200 -> Switch Gravity -> Fly Up to Ceiling.
    - **Requirement**: Ceiling MUST exist at X=1200.

2.  **Mid-Section (1500 - 4500px)**
    - Floor: Y=600. Ceiling: Y=100.
    - **Hazard**: Moving Spikes attached to surfaces.
    - **Spike 1**: Floor (X=2000). Player must be on ceiling.
    - **Spike 2**: Ceiling (X=2500). Player must drop to floor.
    - **Spike 3**: Floor (X=3000). Player must switch to ceiling.
    - **Timing**: Delay set so player can just run through if they switch lanes correctly.

3.  **End (4500 - 6000px)**
    - **Hazard**: Falling Spikes.
#### [NEW] [FallingSpike.gd](file:///e:/godot/gragra/scripts/FallingSpike.gd)

### UI/UX
#### [MODIFY] [HUD.tscn](file:///e:/godot/gragra/scenes/HUD.tscn)
- Add `PauseMenu` (Control) with:
    - Resume Button
    - Title Button
    - Quit Button
#### [MODIFY] [HUD.gd](file:///e:/godot/gragra/scripts/HUD.gd)
- Handle button presses:
    - Resume: `get_tree().paused = false`, hide menu.
    - Title: `get_tree().paused = false`, `get_tree().change_scene_to_file("res://scenes/Title.tscn")`.
    - Quit: `get_tree().quit()`.
#### [MODIFY] [Main.gd](file:///e:/godot/gragra/scripts/Main.gd)
- Input `ui_cancel` (Esc) -> Toggle Pause.

### Impact Effects

## [Level 3: Mastery] Layout
**Goal**: Precision.

1.  **Start (0 - 1000px)**
    - Floor Y=600.
    - **Obstacle**: Wall at X=800. Height 200px (Y=600 to 400).
    - **Action**: Jump over.

2.  **The Void (1000 - 3000px)**
    - NO FLOOR. NO CEILING.
    - Only small platforms at Y=400, Y=200.
    - **Action**: Jump P1 -> Switch -> Land P2 (Ceiling side) -> Switch -> Land P3.

3.  **Goal (5500px)**

## Implementation Rules
- **NO SCALING** on CollisionShapes. Use resource-defined sizes.
- **SNAP COORDINATES**: Use multiples of 100 for clean layouts.
