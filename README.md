# Adaptive Impedance Control for Free-Floating Space Manipulator Capture

MATLAB/Simulink models and supporting MATLAB functions for studying compliant contact control of a planar, two-link free-floating space manipulator. The project compares fixed impedance control, an adaptive damping law, and a DDPG-based damping adjustment strategy for capture tasks with uncertain contact conditions.

> **Project status:** Research prototype. The committed Simulink models and MATLAB source are provided as-is. Training requires the listed MathWorks toolboxes and may take substantial compute time.

## Highlights

- Planar five-state free-floating space-manipulator dynamics.
- Cartesian impedance-control experiments with fixed and adaptive damping.
- DDPG agent definition for learning a bounded damping adjustment.
- Force- and position-tracking result figures and a Chinese report.

## Repository layout

```text
.
├── controllers/
│   ├── FixedImpedance.slx             # Fixed-parameter impedance model
│   ├── AdaptationLawImpedance.slx     # Adaptive damping impedance model
│   ├── DDPGImpedance.slx              # DDPG impedance model
│   ├── agent_define_simplified.m      # DDPG actor, critic, and training setup
│   └── RobotTraining.m                # Incremental training script
├── models/
│   ├── RobotParameters.m              # Robot and contact parameters
│   ├── dynamics_model.m               # Inertia and nonlinear dynamics terms
│   └── jacobian_matrix.m              # End-effector Jacobian
├── experiment/
│   ├── PlanarForceTracking.jpg
│   └── PlanarPositionTracking.jpg
└── results/
    └── CaptureControlReport(Chinese).pdf
```

## Control concept

The outer loop regulates end-effector contact behavior in Cartesian space. A PID position loop tracks the corresponding joint motion, while force feedback affects the impedance response. The adaptive and learning-based variants update the damping term online to balance compliant contact, force-tracking error, and response smoothness.

```text
Desired trajectory → impedance controller → damping adjustment → PID position control
                                                              ↓
Contact-force feedback ← free-floating space manipulator ← joint commands
```

The DDPG setup uses a five-element observation vector and one continuous action. The action is scaled to the interval `[-100, 100]` and represents a damping modification.

## Requirements

- MATLAB R2024b (the version used for this project)
- Simulink
- Reinforcement Learning Toolbox (for `agent_define_simplified.m` and DDPG experiments)
- Parallel Computing Toolbox (optional; the training scripts request a local parallel pool)

## Getting started

1. Clone the repository and open MATLAB in the repository root.
2. Add the source folders to the MATLAB path:

   ```matlab
   addpath('models', 'controllers');
   savepath;
   ```

3. Open one of the models in `controllers/` and inspect its block parameters before simulation:

   ```matlab
   open_system('controllers/FixedImpedance.slx')
   ```

4. Run the desired simulation from Simulink. Compare fixed, adaptive, and DDPG variants under the same initial conditions and contact configuration.

### DDPG training note

`controllers/agent_define_simplified.m` uses the included `DDPGImpedance.slx` model and its `DDPGImpedance/RL Agent` block. Run this script for an initial training session; it saves `DDPG_Robot.mat`. `controllers/RobotTraining.m` then loads that same file for incremental training.

Generated `.mat` training files are intentionally ignored by Git because they can be large. Review the episode count, stopping criterion, exploration noise, and local parallel-pool settings before starting a long training run.

## Model parameters

`models/RobotParameters.m` centralizes the main values used by the MATLAB functions, including base and link masses, link geometry, inertias, contact stiffness/damping, end-effector and target radii, desired inertia, and torque limit. Adjust these values before running a simulation that uses a different robot or contact environment.

## Included results

The repository includes the tracking plots below and a [Chinese capture-control report](results/CaptureControlReport(Chinese).pdf).

| Force tracking | Position tracking |
| --- | --- |
| ![Planar force tracking](experiment/PlanarForceTracking.jpg) | ![Planar position tracking](experiment/PlanarPositionTracking.jpg) |

The original project report compares fixed impedance control, adaptive impedance control, and DDPG-based impedance control. Treat the plots as experiment outputs rather than independently reproduced benchmarks; reproduce them with documented initial conditions, solver settings, and random seeds.

## Limitations and next steps

- The current implementation is planar and simulation-only.
- Training can be computationally expensive and generates large saved-agent data files.
- Before publishing quantitative comparisons, document initial conditions, the contact surface, solver settings, random seeds, and episode configuration.

Potential extensions include 3D dynamics, hardware-in-the-loop validation, and comparison with SAC or TD3.

## License

No license has been specified. Contact the repository owner before reusing the code outside personal or academic evaluation.
