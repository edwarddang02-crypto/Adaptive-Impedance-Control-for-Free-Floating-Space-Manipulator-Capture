# Adaptive Impedance Control for Free-Floating Space Manipulator Capture

## DDPG-Based Intelligent Variable Damping Control for On-Orbit Compliant Capture

## Overview

This project investigates active compliant capture control for free-floating space manipulators under uncertain contact environments.

Space robotic capture tasks involve significant challenges including:

- nonlinear and coupled dynamics caused by base-manipulator interaction;
- unknown target properties and environmental stiffness;
- high impact force during contact operations.

To address these problems, this work develops an adaptive impedance control framework combining conventional control theory and deep reinforcement learning.

A planar two-link Free-Floating Space Robot (FFSR) is modeled and simulated in MATLAB/Simulink.

The proposed framework integrates:

- Cartesian impedance control;
- adaptive variable damping regulation;
- Deep Deterministic Policy Gradient (DDPG)-based intelligent impedance optimization.


---

# System Architecture


The overall control architecture consists of:

Desired trajectory → Impedance Controller → Adaptive Damping Adjustment
→ PID Position Controller
→ Free-Floating Space Manipulator
→ Contact Force Feedback

The controller adopts a dual-loop structure:

- Inner loop:
  PID-based joint position tracking

- Outer loop:
  Cartesian impedance regulation based on contact force error


---

# Main Contributions

## 1. Free-Floating Space Manipulator Modeling

A planar two-link free-floating space manipulator is established considering:

- base-manipulator coupling effect;
- nonlinear dynamics;
- underactuated characteristics.

The kinematic model is derived using the modified D-H method.

The dynamic model is constructed based on recursive Newton-Euler formulation.


---

## 2. Adaptive Variable Damping Impedance Control

A time-varying damping adaptation strategy is proposed.

Instead of using fixed impedance parameters, the damping coefficient is updated online according to:

- force tracking error;
- end-effector velocity compensation.

The controller improves the balance between:

- trajectory tracking accuracy;
- contact compliance;
- impact force suppression.


---

## 3. DDPG-Based Intelligent Impedance Optimization

A Deep Deterministic Policy Gradient (DDPG) controller is introduced to optimize impedance parameters.

The reinforcement learning agent:

### State:


[
force error,
force error derivative,
robot motion information,
previous action
]


### Action:


ΔB


where ΔB represents the damping modification.

The Actor-Critic network learns the optimal damping adjustment strategy through environment interaction.


---

# Reward Function Design

A composite reward function is designed containing:

## Force Tracking Reward

Encourages convergence toward desired contact force.


## Smoothness Constraint

Penalizes excessive damping variation to avoid control oscillation.


## Safety Boundary Protection

Introduces exponential penalties to prevent unstable exploration.


---

# Simulation Results

Three controllers are compared:

| Controller | Description |
|-|-|
| Fixed Impedance Control | Constant impedance parameters |
| Adaptive Impedance Control | Time-varying damping adaptation |
| DDPG Impedance Control | Reinforcement learning based optimization |


## Complex Unknown Surface Contact

Simulation environment:

- unknown sinusoidal surface;
- variable contact condition;
- desired contact force: 20 N.


## Force Tracking Performance

| Method | Stable Force Error |
|-|-|
| Fixed Impedance | 1.04 N |
| Adaptive Impedance | 0.45 N |
| DDPG Impedance | 0.38 N |


The proposed DDPG-based controller achieves the best force tracking accuracy and convergence performance.


---

# Environment

## Software

- MATLAB
- Simulink
- Reinforcement Learning Toolbox


## Tested Version

MATLAB R2024b


---

# Future Work

Future improvements include:

- Extension to 3D space manipulators;
- Hardware-in-the-loop validation;
- Comparison with SAC and TD3 algorithms;
- Deployment on ROS/Gazebo simulation platform.


---
