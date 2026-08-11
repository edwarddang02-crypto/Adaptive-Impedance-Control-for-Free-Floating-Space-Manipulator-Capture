function run_model_sanity_checks
%RUN_MODEL_SANITY_CHECKS Verify core model-function invariants numerically.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'models'));

rng(42, 'twister');
for sample = 1:20
    q = [randn(2,1); 2*pi*rand(3,1)-pi];
    dq = randn(5,1);
    [D, C] = dynamics_model(q, dq);

    assert(isequal(size(D), [5 5]) && isequal(size(C), [5 1]));
    assert(all(isfinite(D), 'all') && all(isfinite(C)));
    assert(norm(D - D.', 'fro') < 1e-10, 'Inertia matrix is not symmetric.');
    assert(min(eig((D + D.') / 2)) > 0, 'Inertia matrix is not positive definite.');

    J = jacobian_matrix(q);
    finiteDifferenceJ = finite_difference_jacobian(q);
    assert(norm(J - finiteDifferenceJ, 'fro') < 1e-6, ...
        'Jacobian does not match finite-difference forward kinematics.');
end

fprintf('Model sanity checks passed for 20 deterministic samples.\n');
end

function J = finite_difference_jacobian(q)
step = 1e-7;
J = zeros(2, 5);
for column = 1:5
    qPlus = q;
    qMinus = q;
    qPlus(column) = qPlus(column) + step;
    qMinus(column) = qMinus(column) - step;
    J(:, column) = (forward_kinematics(qPlus) - forward_kinematics(qMinus)) / (2 * step);
end
end

function position = forward_kinematics(q)
parameters = RobotParameters;
baseRotation = [cos(q(3)), -sin(q(3)); sin(q(3)), cos(q(3))];
relativePosition = [ ...
    parameters.b_b + parameters.l1*cos(q(4)) + parameters.l2*cos(q(4) + q(5)); ...
    parameters.l1*sin(q(4)) + parameters.l2*sin(q(4) + q(5))];
position = q(1:2) + baseRotation * relativePosition;
end
