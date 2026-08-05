function J = jacobian_matrix(q)
    % 返回2x5的雅可比矩阵
    theta_b = q(3); theta1 = q(4); theta2 = q(5);
    L1 = RobotParameters.l1; L2 = RobotParameters.l2;
    
    % 几何雅可比计算
    J_rel = [-L1*sin(theta1)-L2*sin(theta1+theta2), -L2*sin(theta1+theta2);
              L1*cos(theta1)+L2*cos(theta1+theta2),  L2*cos(theta1+theta2)];
    
    R = [cos(theta_b) -sin(theta_b); sin(theta_b) cos(theta_b)];
    
    % 完整雅可比：前3列是基座运动，后2列是关节运动
    J = zeros(2,5);
    J(:,1:2) = eye(2);  % 基座平动直接影响末端
    J(:,3) = [- (L1*sin(theta1)+L2*sin(theta1+theta2))*sin(theta_b) + ...
               (L1*cos(theta1)+L2*cos(theta1+theta2))*cos(theta_b);
              - (L1*sin(theta1)+L2*sin(theta1+theta2))*cos(theta_b) - ...
               (L1*cos(theta1)+L2*cos(theta1+theta2))*sin(theta_b)];
    J(:,4:5) = R * J_rel;
end