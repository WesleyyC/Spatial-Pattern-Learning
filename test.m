%% This is the test for not related attributes and no weight involve

clear

%% Create the 1st graph matrix

num_nodes = 3;
links = {[1,2],[2,3],[3,1]};
weight = [1,1,1];

M=NaN(num_nodes);

for i = 1:length(links)
    index = links{i};
    node1 = index(1);
    node2 = index(2);
    M(node1,node2)=weight(i);
    M(node2,node1)=weight(i); %Symmetric
end

nodes_atrs = NaN;
    

%% Build the 1st ARG

ARG1 = ARG(M,nodes_atrs);

%% Create the 2nd matrix

num_nodes = 5;
links = {[4,5],[4,3],[3,5],[5,1],[1,2],[3,2]};
weight = [1,1,1,1,1,1];

M=NaN(num_nodes);

for i = 1:length(links)
    index = links{i};
    node1 = index(1);
    node2 = index(2);
    M(node1,node2)=weight(i);
    M(node2,node1)=weight(i); %Symmetric
end

nodes_atrs = NaN;

%% Build the 2nd ARG

ARG2 = ARG(M,nodes_atrs);

%% Try to Match
match = graduated_assign_algorithm(ARG1,ARG2);
