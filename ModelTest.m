%% sprMDL auto testing

clear

%% Set up testing flags
view_pattern = 1;

%% Set up the testing pattern

% Pattern Size
pattern_size = 5;
pattern_connected_rate = 0.4;
% Node 
node_atr_size = 1;
node_atr_weight_range =10;
% Edge
edge_atr_size = 1;
edge_atr_weight_range =10;

% Generate a random matrix represented the pattern
pattern = triu(rand(pattern_size)*edge_atr_weight_range,1);    %  upper left part of a random matrix with weight_range
connected_nodes = triu(rand(pattern_size)<pattern_connected_rate,1);    % how many are connected
pattern = pattern.*connected_nodes;
pattern = pattern + pattern'; % make it symmetric
% Generate a random vector represented the node atrs
pattern_nodes_atrs = rand([1,pattern_size])*node_atr_weight_range;

%% Set up the training sample

% Number of Sample
number_of_training_samples = 10;
% Set up the sample size range
maximum_sample_size = pattern_size*2;
size_range = pattern_size:maximum_sample_size;
% Set up the sample connected rate
sample_connected_rate = pattern_connected_rate;
% Preallocate samples cell array
training_samples=cell([1,number_of_training_samples]);
% Noise Level
noise_rate = 0.1;

for i = 1:number_of_training_samples
    % Permute pattern
    % add noise to the pattern
    edge_noise = rand(pattern_size)*2-1; %-1~1
    edge_noise = edge_noise*edge_atr_weight_range*noise_rate;
    sample_pattern = pattern + edge_noise.*(pattern~=0);
    % adding noise to node
    node_noise = rand([1,pattern_size])*2-1;
    node_noise = node_noise*node_atr_weight_range*noise_rate;
    sample_pattern_nodes_atrs = pattern_nodes_atrs+node_noise;
    
    % Build Sample
    % pick a random size
    sample_size = datasample(size_range,1);
    % Generate a Random Matrix
    sampleM = triu(rand(sample_size)*edge_atr_weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(sample_size)<sample_connected_rate,1);    % how many are connected
    sampleM = sampleM.*connected_nodes;
    sampleM = sampleM + sampleM'; % make it symmetric
    % Generate a random vector represented the node atrs
    sample_nodes_atrs = rand([1,sample_size])*node_atr_weight_range;
    
    % Inject the pattern
    inject_starting_index = datasample(1:(sample_size-pattern_size+1),1);
    inject_range = inject_starting_index:(inject_starting_index+pattern_size-1);
    sampleM(inject_range,inject_range)=sample_pattern;
    sample_nodes_atrs(inject_range)=sample_pattern_nodes_atrs;
    
    % Permutate the sample
    idx = randperm(sample_size);
    sampleM = sampleM(idx,idx);
    sample_nodes_atrs = sample_nodes_atrs(idx);
        
    % Build up the sample ARG
    training_samples{i} = ARG(num2cell(sampleM), num2cell(sample_nodes_atrs));
end

%% Generate a model

% Set up model
number_of_component = 3;
trainStart=tic();

mdl = sprMDL(training_samples,number_of_component);

toc(trainStart);

%% Test Result

% check if the model can detect the base pattern
detect_pattern = mdl.checkSamePattern(ARG(num2cell(pattern),num2cell(pattern_nodes_atrs)))

% show the pattern and model pattern if the flag is up
if view_pattern
    pattern_bg = biograph(sparse(triu(pattern)),[],'ShowArrows','off','ShowWeights','on');

    view(pattern_bg)

    for i = 1:number_of_component
        view(mdl.mdl_ARGs{i}.showARG.bg)
    end
end
%% Set up the testing sample

% Number of Sample
number_of_testing_samples = 50;
% Preallocate samples cell array
testing_samples=cell([1,number_of_testing_samples]);

for i = 1:number_of_testing_samples
    % Permute pattern
    % add noise to the pattern
    edge_noise = rand(pattern_size)*2-1; %-1~1
    edge_noise = edge_noise*edge_atr_weight_range*noise_rate;
    sample_pattern = pattern + edge_noise.*(pattern~=0);
    % adding noise to node
    node_noise = rand([1,pattern_size])*2-1;
    node_noise = node_noise*node_atr_weight_range*noise_rate;
    sample_pattern_nodes_atrs = pattern_nodes_atrs+node_noise;
    
    % Build Sample
    % pick a random size
    sample_size = datasample(size_range,1);
    % Generate a Random Matrix
    sampleM = triu(rand(sample_size)*edge_atr_weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(sample_size)<sample_connected_rate,1);    % how many are connected
    sampleM = sampleM.*connected_nodes;
    sampleM = sampleM + sampleM'; % make it symmetric
    % Generate a random vector represented the node atrs
    sample_nodes_atrs = rand([1,sample_size])*node_atr_weight_range;
    
    % Inject the pattern
    inject_starting_index = datasample(1:(sample_size-pattern_size+1),1);
    inject_range = inject_starting_index:(inject_starting_index+pattern_size-1);
    sampleM(inject_range,inject_range)=sample_pattern;
    sample_nodes_atrs(inject_range)=sample_pattern_nodes_atrs;
    
    % Permutate the sample
    idx = randperm(sample_size);
    sampleM = sampleM(idx,idx);
    sample_nodes_atrs = sample_nodes_atrs(idx);
        
    % Build up the sample ARG
    testing_samples{i} = ARG(num2cell(sampleM), num2cell(sample_nodes_atrs));
end

% check the testing sample
checkPatternHandle=@(ARG)mdl.checkSamePattern(ARG);
detect_result = cellfun(checkPatternHandle, testing_samples);
test_correct_rate = sum(detect_result)/length(detect_result)


%% Set Up Random Test Sample

% Number of Sample
number_of_random_samples = number_of_testing_samples;
random_samples=cell([1,number_of_random_samples]);

for i = 1:number_of_random_samples
    % Build Sample
    % pick a random size
    sample_size = datasample(size_range,1);
    % Generate a Random Matrix
    sampleM = triu(rand(sample_size)*edge_atr_weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(sample_size)<sample_connected_rate,1);    % how many are connected
    sampleM = sampleM.*connected_nodes;
    sampleM = sampleM + sampleM'; % make it symmetric
    % Generate a random vector represented the node atrs
    sample_nodes_atrs = rand([1,sample_size])*node_atr_weight_range;
    % Create the sample
    random_samples{i} = ARG(num2cell(sampleM), num2cell(sample_nodes_atrs));
end

% check the random sample
random_detect_result = cellfun(checkPatternHandle, random_samples);
random_correct_rate = sum(random_detect_result)/length(random_detect_result)