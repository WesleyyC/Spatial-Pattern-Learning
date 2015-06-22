%% Random Graph Test

% The RandomGraphTest class will generate a 100 nodes graph and permutate
% it a bit. Then test the algorithm on the two graphs.

clear

%% Basic Configuration Setup

% How many rounds
rounds = 10;

% The size of the test graph
size = 100;

% The range of the edge rate
weight_range = 10;  % update with edge_compatibility
% How often two nodes are connected
connected_rate = 0.7;
% How many noise are there
noise_rate = 0.00;

% Node Attribute Flag
atr_flag = 0;

% Scoring
correct_match = 0;
mistaken_match = 0;

%% Run the test
tStart = tic();
for i = 1:rounds
    loopStart=tic();
    run RGTestLoop %which will increment correct_match or mistaken_match count
    display('One Single Loop');
    toc(loopStart);
end
display('Total Run Time');
toc(tStart);
%% Calculate the correct rate
correct_rate = correct_match/(correct_match+mistaken_match);

display('Correct Rate:');
display(correct_rate);

