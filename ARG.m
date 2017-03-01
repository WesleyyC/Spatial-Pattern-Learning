classdef ARG < handle
    %	Attributed Relational Graphs represents a graph data strucutre with
    %	a list of node
    %   We have a E_arg(M) that we want to minimize
    
    properties (GetAccess=public,SetAccess=public)
        num_nodes = NaN;
        nodes = {};
        edges = {};
        nodes_vector = NaN;
        edges_matrix = NaN;
    end
    
    methods
        function self = ARG(M,nodes_atrs)
            % Throw error if not enough argument
            if nargin < 2
                error "NotEnoughArgument";
            end
            
            % Throw error if the matrix is not a square
            if size(M)~=size(M')
                error "MisNotSquare";
            end
            
            % Throw error if the graph matrix and the nodes_atrs does not
            % match
            if length(M)~=length(nodes_atrs)
                    error "AtrributeArrasySizeNotMatch";
            end
            
            % Get the number of nodes
            self.num_nodes=length(M);
            
            % Allocate memory for nodes and edges
            self.nodes = cell(1,self.num_nodes);
            self.nodes_vector = zeros(self.num_nodes,length(nodes_atrs{1}));
            self.edges = cell(self.num_nodes,self.num_nodes);
            edge_feature = max(max(cellfun(@(x) numel(x), M)));
            self.edges_matrix = zeros(self.num_nodes, self.num_nodes, edge_feature);
            
            % Create Nodes
            for ID = 1:self.num_nodes
                self.nodes{ID}=node(ID,self);
                self.nodes_vector(ID,:)=nodes_atrs{ID};
            end
            
            % Create Edge
            for i = 1:self.num_nodes
                for j = 1:self.num_nodes
                    self.edges{i,j}=edge(self,self.nodes{i},self.nodes{j});
                    if M{i,j}
                        self.edges_matrix(i,j,:) = M{i,j};
                    end
                end
            end
            
        end
        
        % show ARG in matrix
        function pattern_bg = showARG(obj)
            pattern_bg = biograph(sparse(triu(any(obj.edges_matrix,3))),[],'ShowArrows','off','ShowWeights','off');
            view(pattern_bg)
        end
        
    end
    
end

