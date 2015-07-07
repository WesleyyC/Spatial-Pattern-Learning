classdef mdl_ARG < handle
    %   mdl_ARG represetns a component in our model
    properties (GetAccess=public,SetAccess=private)
        num_nodes = NaN;
        nodes = {};
        edges = {};
    end
    
    methods
        
        % setting up constructor which will take an sample ARG and build a
        % new component for the model.
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
            
            % Initial frequency to a uniform frequency
            freq = 1/(self.num_nodes+1);
            
            % Convert ARG node to mdl_node
            mdl_node_handle=@(node)mdl_node(node.ID,node.atrs,freq);
            self.nodes = cellfun(mdl_node_handle,ARG.nodes,'UniformOutput',false);
            
            % This should not be include in the graph matching, but there
            % should be a way to incoprate this.
%             % Set an null node for backgroudn matching to the end of nodes
%             self.nodes{self.num_nodes+1}=mdl_node(self.num_nodes+1,NaN,freq);
%             self.num_nodes = self.num_nodes+1;
            
            % Convert ARG edge to mdl_edge
            mdl_edge_handle=@(edge)mdl_edge(edge.atrs,edge.node1ID,edge.node2ID,self.nodes);
            self.edges = cellfun(mdl_edge_handle,ARG.edges,'UniformOutput',false);    
        end
        
    end
    
end

