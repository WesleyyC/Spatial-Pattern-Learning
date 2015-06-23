%% Random Graph Test

% The RandomGraphTest class will generate a 100 nodes graph and permutate
% it a bit. Then test the algorithm on the two graphs.

clear
tStart = tic();
%% Basic Configuration Setup

% How many rounds
rounds = 10;

% The size if the test graph
size = 20;

% The range of the edge rate
weight_range = 10;  % update with edge_compatibility/node_compatibility
% How often two nodes are connected
connected_rate = 0.6;
% How many noise are there
noise_rate = 0.05;

% Node Attribute Flag
atr_flag = 1;

% Scoring
correct_match = 0;
mistaken_match = 0;

%% Run the test
for i = 1:rounds
    loopStart=tic();
    run RGTestLoop %which will increment correct_match or mistaken_match count
    display('Singe Round');
    toc(loopStart);
end
%% Calculate the correct rate
correct_rate = correct_match/(correct_match+mistaken_match);

display(' ');
display(correct_rate);

display(' ');
display('Total Run Time');
toc(tStart);

