%%
clear

%% Create a graph matrix

num_nodes = 4;
links = {[1,2],[2,3],[2,4],[1,4]};
weight = [1,2,3,4];

M=NaN(num_nodes);

for i = 1:length(links)
    index = links{i};
    node1 = index(1);
    node2 = index(2);
    M(node1,node2)=weight(i);
    M(node2,node1)=weight(i); %Symmetric
end

nodes_atrs = NaN;
    

%% Build the ARG

ARG = ARG(M,nodes_atrs);
