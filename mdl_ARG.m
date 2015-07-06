classdef mdl_ARG
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
            for ID = 1:self.num_nodes
                self.nodes{ID}=mdl_node(ARG.nodes{ID},freq);
            end
            
            % The null node for backgroudn matching
            self.nodes{self.num_nodes+1}=mdl_node(self.num_nodes+1,NaN,freq);
            
            % Create Edge
            for i = 1:self.num_nodes
                for j = 1:self.num_nodes
                    self.edges{i,j}=mdl_edge(ARG.edges{i.j});
                end
            end
            
        end
        
    end
    
end

