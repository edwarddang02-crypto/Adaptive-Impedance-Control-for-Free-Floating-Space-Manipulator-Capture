clear; close all; clc;

%% 1. 环境与空间定义
obsInfo = rlNumericSpec([5 1]); 
obsInfo.Name = 'observations';

actInfo = rlNumericSpec([1 1], "UpperLimit", 100, "LowerLimit", -100);
actInfo.Name = 'action';

env = rlSimulinkEnv("DDPGImpedance","DDPGImpedance/RL Agent",obsInfo,actInfo,'UseFastRestart', 'on');

%% 2. Actor 网络构造 (极简 MLP 架构: 64 -> 64)
actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Name', 'observation')
    fullyConnectedLayer(64, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc3')
    tanhLayer('Name', 'tanh')
    % 注意：Scale 的值必须与 actInfo 的 UpperLimit 保持绝对一致
    scalingLayer('Scale', 100, 'Bias', 0, 'Name', 'scale') 
];

%% 3. Critic 网络构造 (降低维度，匹配 Actor)
obsPath = [
    featureInputLayer(obsInfo.Dimension(1), 'Name', 'observation')
    fullyConnectedLayer(64, 'Name', 'obs_fc1')
    reluLayer('Name', 'obs_relu1')
    fullyConnectedLayer(64, 'Name', 'obs_fc2') % 输出 64 维准备相加
];
actPath = [
    featureInputLayer(actInfo.Dimension(1), 'Name', 'action')
    fullyConnectedLayer(64, 'Name', 'act_fc1') % 输出 64 维准备相加
];
commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'common_relu1')
    fullyConnectedLayer(64, 'Name', 'common_fc')
    reluLayer('Name', 'common_relu2')
    fullyConnectedLayer(1,'Name','q_Value')
];

criticNet = layerGraph();
criticNet = addLayers(criticNet, obsPath);
criticNet = addLayers(criticNet, actPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'obs_fc2', 'add/in1');
criticNet = connectLayers(criticNet, 'act_fc1', 'add/in2');

%% 4. Agent 与表示对象实例化
actor  = rlContinuousDeterministicActor(actorNet, obsInfo, actInfo);
critic = rlQValueFunction(criticNet, obsInfo, actInfo, ...
    'ObservationInputNames', 'observation', ...
    'ActionInputNames', 'action');

%% 5. Agent 超参数设置
agentOpts = rlDDPGAgentOptions('SampleTime', 0.065); 
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;

% 探索噪声配置
agentOpts.NoiseOptions.StandardDeviation = 45; 
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-4;

agentOpts.MiniBatchSize = 128; 
agentOpts.ExperienceBufferLength = 1e6;

agent = rlDDPGAgent(actor, critic, agentOpts);

%% 6. 并行与训练配置
if isempty(gcp('nocreate')), parpool('local', 4); end

testOpts = rlTrainingOptions(...
    'UseParallel', true, ...
    'MaxEpisodes', 60, ...           
    'MaxStepsPerEpisode', 2000, ...  
    'Verbose', true, ...               
    'Plots', 'training-progress');          

testOpts.StopTrainingValue = 1e6;
trainStats = train(agent, env, testOpts);

save('DDPG_Robot.mat', 'agent', 'trainStats', 'env', '-v7.3');
disp('训练完成，模型已保存。');
