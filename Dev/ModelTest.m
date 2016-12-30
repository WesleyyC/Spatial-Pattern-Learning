%% sprMDL auto testing
clear

%% Test Flag

view_pattern = 0;

%% Setup Parameter

size = 20;
weight_range = 1;
connected_rate = 0.2;
noise_rate = 0.1;

%% Set up the testing pattern

M = triu((rand(size)*2-1)*weight_range,1);    %  upper left part of a random matrix with weight_range
connected_nodes = triu(rand(size)<connected_rate,1);    % how many are connected
M = M.*connected_nodes;
M = M + M'; % make it symmetric

V = (rand([1,size])*2-1)*weight_range;

%% Set up the training sample

% Number of Sample
number_of_training_samples = 5;

% Preallocate samples cell array
training_samples=cell([1,number_of_training_samples]);

for i = 1:number_of_training_samples
    
    % setup sample
    M1_size = round((1+rand*noise_rate*2)*size);
    M1 = triu((rand(M1_size)*2-1)*weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(M1_size)<connected_rate,1);    % how many are connected
    M1 = M1.*connected_nodes;
    M1 = M1 + M1'; % make it symmetric
    V1 = (rand([1,M1_size])*2-1)*weight_range;
    
    % inject pattern
    M1(1:size,1:size) = M;
    V1(1:size) = V;
    
    % add noise
    M1_noise = randn(M1_size); %-1~1
    M1_noise = M1_noise*weight_range*noise_rate;
    M1 = M1 + M1_noise.*(M1~=0);
    V1_noise = randn([1,M1_size]);
    V1_noise = V1_noise*weight_range*noise_rate;
    V1 = V1+V1_noise;
    
    % pemutate sample
    idx1 = randperm(M1_size);
    M1=M1(idx1,idx1);
    V1=V1(idx1);
    
    % Build up the sample ARG
    training_samples{i} = ARG(M1, V1);
end

%% Generate a model

% Set up model
number_of_component = 2;
trainStart=tic();

mdl = sprMDL(training_samples,number_of_component);

toc(trainStart);

%% Test Result

% check if the model can detect the base pattern
detect_pattern = mdl.checkPattern(ARG(M, V))

%% Check Pattern

% show the pattern and model pattern if the flag is up
if view_pattern
    pattern_bg = biograph(sparse(triu(M)),[],'ShowArrows','off','ShowWeights','on');

    view(pattern_bg)
end

%% Set up the testing sample

% Number of Sample
number_of_testing_samples = 50;
% Preallocate samples cell array
test_score_result = zeros([1,number_of_testing_samples]);
test_detect_result = zeros([1,number_of_testing_samples]);

for i = 1:number_of_testing_samples
    % setup sample
    M1_size = round((1+rand*noise_rate*2)*size);
    M1 = triu((rand(M1_size)*2-1)*weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(M1_size)<connected_rate,1);    % how many are connected
    M1 = M1.*connected_nodes;
    M1 = M1 + M1'; % make it symmetric
    V1 = (rand([1,M1_size])*2-1)*weight_range;
    
    % inject pattern
    M1(1:size,1:size) = M;
    V1(1:size) = V;
    
    % add noise
    M1_noise = randn(M1_size); %-1~1
    M1_noise = M1_noise*weight_range*noise_rate;
    M1 = M1 + M1_noise.*(M1~=0);
    V1_noise = randn([1,M1_size]);
    V1_noise = V1_noise*weight_range*noise_rate;
    V1 = V1+V1_noise;
    
    % pemutate sample
    idx1 = randperm(M1_size);
    M1=M1(idx1,idx1);
    V1=V1(idx1);
    
    % Build up the sample ARG
    [tf, score] = mdl.checkPattern(ARG(M1, V1));
    test_score_result(i) = score;
    test_detect_result(i) = tf;
end

% check the testing sample
test_score_average = sum(test_score_result)/length(test_score_result)
test_detect_rate = sum(test_detect_result)/length(test_detect_result)

%% Set Up Random Test Sample

% Number of Sample
number_of_random_samples = number_of_testing_samples;
random_score_result = zeros([1,number_of_random_samples]);
random_detect_result = zeros([1,number_of_random_samples]);

for i = 1:number_of_random_samples
    % setup sample
    M1_size = round((1+rand*noise_rate*2)*size);
    M1 = triu((rand(M1_size)*2-1)*weight_range,1);    %  upper left part of a random matrix with weight_range
    connected_nodes = triu(rand(M1_size)<connected_rate,1);    % how many are connected
    M1 = M1.*connected_nodes;
    M1 = M1 + M1'; % make it symmetric
    V1 = (rand([1,M1_size])*2-1)*weight_range;
    % Create the sample
    % Build up the sample ARG
    [tf, score] = mdl.checkPattern(ARG(M1, V1));
    random_score_result(i) = score;
    random_detect_result(i) = tf;
end

% check the random sample
random_score_average = sum(random_score_result)/length(random_score_result)
random_detect_rate = sum(random_detect_result)/length(random_detect_result)

%% compare reuslt
fig = figure;
hax = axes;

min_s = floor(min([test_score_result,random_score_result]));
max_s = ceil(max([test_score_result,random_score_result]));

histogram(test_score_result, min_s:max_s)
hold on
histogram(random_score_result, min_s:max_s)
hold on
line([mdl.thredshold_score mdl.thredshold_score],get(hax,'YLim'),'Color','g','LineWidth', 2)
hold on
text(mdl.thredshold_score+1, -0.1, ' +3SD ');
legend('Pattern Embedding','Random Embedding')
