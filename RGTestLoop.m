%% Run from RandomGraphTest.m 

%with the following header

% %% Basic Configuration Setup
% 
% % How many rounds
% rounds = 10;
% 
% % The size of the test graph
% size = 5;
% 
% % The range of the edge rate
% weight_range = 10;
% % How often two nodes are connected
% connected_rate = 0.9;
% % How many noise are there
% noise_rate = 0.00;
% 
% % Node Attribute Flag
% atr_flag = 0;
% 
% % Scoring
% correct_match = 0;
% mistaken_match = 0;

%% Generate a Random Matrix
M = zeros(size);
for i = 1:size
    for j = i+1:size
        if rand()<connected_rate
            M(i,j)=rand()*weight_range;
            M(j,i)=M(i,j);
        end
    end
end


%% Generate the Permutation of M

% Determine the size of the permutation of M
low_limit = round(0.1*size+1);    % control the limit of lower bound so that the permutation is large enough
low_bound = randi([1 low_limit],1,1);
up_limit =round(0.9*size);   % control the limit of up_bound so that the permutation matrix is large enough
up_bound = randi([up_limit,size],1,1);
test_size = up_bound-low_bound+1;
test_range = low_bound:up_bound;

% Get the base testing_Matrix
test_M=M(test_range,test_range);

%Generate Random Permutation Matrix
per = speye( test_size );
idx = randperm(test_size);
clearvars rev;  % the rev memory will mess up the indexes so clear it before we generate the new rev
rev(idx)=1:test_size;

% Permute the matrix
test_M=test_M(idx,idx);

%% Node Attribute
nodes_atrs=NaN;
test_nodes_atrs=NaN;
if atr_flag
    nodes_atrs=rand([1,size])*weight_range;
    test_nodes_atrs = nodes_atrs(idx);
end

%% Adding Noise
if noise_rate~=0
    % adding noise to edge
    edge_noise = rand(test_size)*2-1; %-1~1
    edge_noise = edge_noise*weight_range*noise_rate;
    test_M = test_M + edge_noise;
    if atr_flag
        % adding noise to node
        node_noise = rand([1,test_size])*2-1;
        node_noise = node_noise*weight_range*noise_rate;
        test_nodes_atrs=test_nodes_atrs+node_noise;
    end
end

%% Generate the Graph
ARG1 = ARG(M,nodes_atrs);
ARG2 = ARG(test_M,test_nodes_atrs);

%% Do the match algorithm
match = graduated_assign_algorithm(ARG2,ARG1);
% Get back the original
result = match(rev,:);

%% Counting correct or mistaken match
for i = 1:test_size
    if result(i,test_range(i))==1
        correct_match = correct_match+1;
    else
        mistaken_match = mistaken_match+1;
    end
end