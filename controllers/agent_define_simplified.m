clearvars; close all; clc;

% Reproducible initial DDPG training entry point.
rng(42, 'twister');
modelName = 'DDPGImpedance';
agentBlock = modelName + "/RL Agent";
agentSampleTime = 0.065;
maxEpisodes = 60;
useParallel = strcmpi(getenv('MATLAB_RL_USE_PARALLEL'), 'true');

load_system(modelName);
episodeDuration = str2double(get_param(modelName, 'StopTime'));
maxStepsPerEpisode = ceil(episodeDuration / agentSampleTime);

[agent, obsInfo, actInfo] = create_ddpg_agent(agentSampleTime);
env = rlSimulinkEnv(modelName, agentBlock, obsInfo, actInfo, ...
    'UseFastRestart', 'on');

% Verify the model-agent interface before starting a long training run.
set_param(agentBlock, 'Agent', 'agent');
set_param(modelName, 'SimulationCommand', 'update');

if useParallel && isempty(gcp('nocreate'))
    parpool('local');
end

trainingOpts = rlTrainingOptions( ...
    'UseParallel', useParallel, ...
    'MaxEpisodes', maxEpisodes, ...
    'MaxStepsPerEpisode', maxStepsPerEpisode, ...
    'StopTrainingCriteria', 'EpisodeCount', ...
    'StopTrainingValue', maxEpisodes, ...
    'Verbose', true, ...
    'Plots', 'training-progress');

trainStats = train(agent, env, trainingOpts);
save('DDPG_Robot.mat', 'agent', 'trainStats', 'env', 'trainingOpts', '-v7.3');
disp('Training complete. Agent and training statistics saved to DDPG_Robot.mat.');
