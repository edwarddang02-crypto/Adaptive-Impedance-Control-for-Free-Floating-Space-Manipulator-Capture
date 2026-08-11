clearvars; close all; clc;

% Continue training an agent produced by agent_define_simplified.m.
checkpointFile = 'DDPG_Robot.mat';
if ~isfile(checkpointFile)
    error('Checkpoint not found: %s. Run agent_define_simplified.m first.', checkpointFile);
end

rng(42, 'twister');
load(checkpointFile, 'agent', 'env');
agent.AgentOptions.ResetExperienceBufferBeforeTraining = false;

modelName = 'DDPGImpedance';
load_system(modelName);
episodeDuration = str2double(get_param(modelName, 'StopTime'));
maxStepsPerEpisode = ceil(episodeDuration / agent.AgentOptions.SampleTime);
maxEpisodes = 100;
useParallel = strcmpi(getenv('MATLAB_RL_USE_PARALLEL'), 'true');

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

trainingStats = train(agent, env, trainingOpts);
save(checkpointFile, 'agent', 'env', 'trainingStats', 'trainingOpts', '-v7.3');
