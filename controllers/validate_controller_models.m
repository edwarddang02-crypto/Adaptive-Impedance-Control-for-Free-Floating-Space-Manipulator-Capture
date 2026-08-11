function validate_controller_models
%VALIDATE_CONTROLLER_MODELS Update-check the committed Simulink models.

projectRoot = fileparts(fileparts(mfilename('fullpath')));
addpath(fullfile(projectRoot, 'models'), fullfile(projectRoot, 'controllers'));

modelNames = {'FixedImpedance', 'AdaptationLawImpedance', 'DDPGImpedance'};
for index = 1:numel(modelNames)
    modelName = modelNames{index};
    load_system(modelName);

    if strcmp(modelName, 'DDPGImpedance')
        agent = create_ddpg_agent(0.065);
        assignin('base', 'agent', agent);
        set_param(modelName + "/RL Agent", 'Agent', 'agent');
    end

    set_param(modelName, 'SimulationCommand', 'update');
    fprintf('%s: model update passed.\n', modelName);
    close_system(modelName, 0);
end
end
