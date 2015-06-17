%% Random Graph Test

% The RandomGraphTest class will generate a 100 nodes graph and permutate
% it a bit. Then test the algorithm on the two graphs.

clear

%% Basic Configuration Setup

% How many rounds
rounds = 5;

% The size of the test graph
size = 10;

% The range of the edge rate
weight_range = 10;
% How often two nodes are connected
connected_rate = 0.9;
% How many noise are there
noise_rate = 0.00;

% Node Attribute Flag
atr_flag = 0;

% Scoring
correct_match = 0;
mistaken_match = 0;

%% Run the test

tic()
for i = 1:rounds
    run RGTestLoop %which will increment correct_match or mistaken_match count
end
toc()

%% Calculate the correct rate
correct_rate = correct_match/(correct_match+mistaken_match)

