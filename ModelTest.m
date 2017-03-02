%% sprMDL auto testing
clear

%% Test Flag

view_pattern = 0;

save_result = 0;

%% Setup Parameter

g_size = 10;
weight_range = 1;
connected_rate = 0.2;
noise_rate = 0.1;

node_feature = 5;
edge_feature = 5;

%% Set up the testing pattern

% setup edge
M = cell(g_size);
for i = 1:g_size
    for j = i+1:g_size
        if rand < connected_rate
            M{i,j} = (rand([1,edge_feature])*2-1)*weight_range;
            M{j,i} = M{i,j};
        end
    end
end

% setup vector
V = cell([1, g_size]);
for n = 1:g_size
    V{n} = (rand([1,node_feature])*2-1)*weight_range;
end

%% Set up the training sample

% Number of Sample
number_of_training_samples = 5;

% Preallocate samples cell array
training_samples=cell([1,number_of_training_samples]);

for i = 1:number_of_training_samples
    
    % setup sample
    M1_size = round((1+rand*noise_rate*2)*g_size);
    M1 = cell(M1_size);
    for x = 1:M1_size
        for y = x+1:M1_size
            if rand < connected_rate
                M1{x,y} = (rand([1,edge_feature])*2-1)*weight_range;
                M1{y,x} = M1{x,y};
            end
        end
    end
    V1 = cell([1, M1_size]);
    for n = 1:M1_size
        V1{n} = (rand([1,node_feature])*2-1)*weight_range;
    end
    
    % inject pattern
    M1(1:g_size,1:g_size) = M;
    V1(1:g_size) = V;
    
    % add noise
    for x = 1:M1_size
        for y = x+1:M1_size
            if M1{x,y}
                M1{x,y} = M1{x,y} +randn([1,edge_feature])*weight_range*noise_rate;
                M1{y,x} = M1{x,y};
            end
        end
    end
    for n = 1:M1_size
        V1{n} = V1{n} + randn([1,node_feature])*weight_range*noise_rate;
    end
    
%     % pemutate sample
%     idx1 = randperm(M1_size);
%     M1=M1(idx1,idx1);
%     V1=V1(idx1);
    
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
    M1_size = round((1+rand*noise_rate*2)*g_size);
    M1 = cell(M1_size);
    for x = 1:M1_size
        for y = x+1:M1_size
            if rand < connected_rate
                M1{x,y} = (rand([1,edge_feature])*2-1)*weight_range;
                M1{y,x} = M1{x,y};
            end
        end
    end
    V1 = cell([1, M1_size]);
    for n = 1:M1_size
        V1{n} = (rand([1,node_feature])*2-1)*weight_range;
    end
    
    % inject pattern
    M1(1:g_size,1:g_size) = M;
    V1(1:g_size) = V;
    
    % add noise
    for x = 1:M1_size
        for y = x+1:M1_size
            if M1{x,y}
                M1{x,y} = M1{x,y} +randn([1,edge_feature])*weight_range*noise_rate;
                M1{y,x} = M1{x,y};
            end
        end
    end
    for n = 1:M1_size
        V1{n} = V1{n} + randn([1,node_feature])*weight_range*noise_rate;
    end
    
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
    M1_size = round((1+rand*noise_rate*2)*g_size);
    M1 = cell(M1_size);
    for x = 1:M1_size
        for y = x+1:M1_size
            if rand() < connected_rate
                M1{x,y} = (rand([1,edge_feature])*2-1)*weight_range;
                M1{y,x} = M1{x,y};
            end
        end
    end
    V1 = cell([1, M1_size]);
    for n = 1:M1_size
        V1{n} = (rand([1,node_feature])*2-1)*weight_range;
    end
    
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

histogram(test_score_result)
hold on
histogram(random_score_result)
hold on
line([mdl.thredshold_score mdl.thredshold_score],get(hax,'YLim'),'Color','g','LineWidth', 2)
hold on
legend('Pattern Embedding','Random Embedding')

%% save file
if save_result
    saveas(fig, 'result.png');
    save result;
end