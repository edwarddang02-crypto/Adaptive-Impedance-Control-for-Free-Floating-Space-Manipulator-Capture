# Controller workflow

This directory contains three Simulink experiments sharing the planar free-floating manipulator model in `../models`.

| Model | Purpose |
| --- | --- |
| `FixedImpedance.slx` | Fixed-parameter Cartesian impedance baseline. |
| `AdaptationLawImpedance.slx` | Impedance baseline with an online adaptation law. |
| `DDPGImpedance.slx` | Reinforcement-learning experiment with a bounded damping modification. |

## Shared model structure

Each model contains the same main elements:

1. A trajectory generator and inverse kinematics block.
2. An outer compliant-control loop that adjusts the end-effector reference.
3. A joint-space PID tracking loop with torque saturation.
4. The five-coordinate free-floating dynamics and a Kelvin-Voigt contact model.

All three committed models use a 28 s simulation horizon, fixed-step `ode4`, and a `1e-4` s integration step. Keep these values identical when comparing controllers.

## DDPG experiment

`DDPGImpedance.slx` supplies the RL Agent with five normalized observations:

1. Contact-force error.
2. Contact-force-error derivative.
3. Sine of the trajectory phase.
4. Cosine of the trajectory phase.
5. Previous action.

The single action is a damping modification `ΔB`, bounded to `[-100, 100]` N·s/m. The model adds it to a 200 N·s/m nominal damping value before applying the impedance dynamics. The reward combines force-tracking reward, symmetric action-rate regularization, and a force-error safety penalty. Episodes terminate when the absolute contact force exceeds 30 N.

Run `agent_define_simplified.m` for a fresh, seeded training run. It creates `DDPG_Robot.mat`; run `RobotTraining.m` only to continue that checkpoint. Do not reuse checkpoints created before the current Jacobian and reward revisions. Training is sequential by default; set the environment variable `MATLAB_RL_USE_PARALLEL=true` only after confirming that each worker has the project path and required toolboxes.

## Verification

From the repository root, run:

```matlab
addpath('models', 'controllers', 'tests');
run_model_sanity_checks;
validate_controller_models;
```

`run_model_sanity_checks` compares the analytic end-effector Jacobian with finite-difference forward kinematics and checks inertia-matrix symmetry and positive definiteness. `validate_controller_models` creates a fresh DDPG agent and update-checks all committed Simulink models.

## Experiment reporting minimum

For a defensible comparison, report the model revision/commit, initial state, desired force, contact parameters, solver configuration, training seed, total environment steps, and evaluation seed. Evaluate the trained policy without exploration noise and report results across multiple seeds.
