function [agent, obsInfo, actInfo] = create_ddpg_agent(sampleTime)
%CREATE_DDPG_AGENT Construct the DDPG agent used by DDPGImpedance.slx.

arguments
    sampleTime (1,1) double {mustBePositive} = 0.065
end

obsInfo = rlNumericSpec([5 1], 'Name', 'observations');
actionLimit = 100;
actInfo = rlNumericSpec([1 1], 'LowerLimit', -actionLimit, 'UpperLimit', actionLimit, ...
    'Name', 'action');

actorNet = [
    featureInputLayer(obsInfo.Dimension(1), 'Name', 'observation')
    fullyConnectedLayer(64, 'Name', 'fc1')
    reluLayer('Name', 'relu1')
    fullyConnectedLayer(64, 'Name', 'fc2')
    reluLayer('Name', 'relu2')
    fullyConnectedLayer(actInfo.Dimension(1), 'Name', 'fc3')
    tanhLayer('Name', 'tanh')
    scalingLayer('Scale', actionLimit, 'Bias', 0, 'Name', 'scale')
    ];

obsPath = [
    featureInputLayer(obsInfo.Dimension(1), 'Name', 'observation')
    fullyConnectedLayer(64, 'Name', 'obs_fc1')
    reluLayer('Name', 'obs_relu1')
    fullyConnectedLayer(64, 'Name', 'obs_fc2')
    ];
actPath = [
    featureInputLayer(actInfo.Dimension(1), 'Name', 'action')
    fullyConnectedLayer(64, 'Name', 'act_fc1')
    ];
commonPath = [
    additionLayer(2, 'Name', 'add')
    reluLayer('Name', 'common_relu1')
    fullyConnectedLayer(64, 'Name', 'common_fc')
    reluLayer('Name', 'common_relu2')
    fullyConnectedLayer(1, 'Name', 'q_value')
    ];

criticNet = layerGraph(obsPath);
criticNet = addLayers(criticNet, actPath);
criticNet = addLayers(criticNet, commonPath);
criticNet = connectLayers(criticNet, 'obs_fc2', 'add/in1');
criticNet = connectLayers(criticNet, 'act_fc1', 'add/in2');

actor = rlContinuousDeterministicActor(actorNet, obsInfo, actInfo);
critic = rlQValueFunction(criticNet, obsInfo, actInfo, ...
    'ObservationInputNames', 'observation', ...
    'ActionInputNames', 'action');

agentOpts = rlDDPGAgentOptions('SampleTime', sampleTime);
agentOpts.ActorOptimizerOptions.LearnRate = 1e-4;
agentOpts.CriticOptimizerOptions.LearnRate = 1e-3;
agentOpts.NoiseOptions.StandardDeviation = 45;
agentOpts.NoiseOptions.StandardDeviationDecayRate = 1e-4;
agentOpts.MiniBatchSize = 128;
agentOpts.ExperienceBufferLength = 1e6;

agent = rlDDPGAgent(actor, critic, agentOpts);
end
