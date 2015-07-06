classdef mdl_ARG < handle
    %   mdl_ARG represetns a component in our model
    properties (GetAccess=public,SetAccess=private)
        num_nodes = NaN;
        nodes = {};
        edges = {};        
    end
    
    methods
        function self = mdl_ARG(ARG)
            % Throw error if not enough argument
            if nargin < 1
                error "NotEnoughArgument";
            end
            
            % Get the number of nodes
            self.num_nodes=ARG.num_nodes;
            
            % Allocate memory for nodes and edges
            self.nodes = cell(1,self.num_nodes+1);
            self.edges = cell(self.num_nodes,self.num_nodes);
            
            % Initial frequency
            freq = 1/(self.num_nodes+1);
            
            % Create Nodes
            mdl_node_handle=@(node)mdl_node(node.ID,node.atrs,freq);
            self.nodes = cellfun(mdl_node_handle,ARG.nodes,'UniformOutput',false);
            
            % The null node for backgroudn matching
            self.nodes{self.num_nodes+1}=mdl_node(self.num_nodes+1,NaN,freq);
            
            % Create Edge
            mdl_edge_handle=@(edge)mdl_edge(edge.atrs,edge.node1ID,edge.node2ID,self.nodes);
            self.edges = cellfun(mdl_edge_handle,ARG.edges,'UniformOutput',false);    
        end
        
    end
    
end

