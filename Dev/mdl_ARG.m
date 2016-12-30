classdef mdl_ARG < handle
    %   mdl_ARG represetns a component in our model
    properties (GetAccess=public,SetAccess=public)
        num_nodes = NaN;
        nodes_freq = NaN;
        nodes = {};
        edges = {};
        nodes_vector = NaN;
        nodes_cov = NaN;
        edges_matrix = NaN;
        edges_cov = NaN;
    end
    
    methods
        
        % setting up constructor which will take an sample ARG and build a
        % new component for the model.
        function self = mdl_ARG(M, nodes_atrs)
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
            self.num_nodes=length(M)+1;
            
            % Build null node
            nodes_atrs(self.num_nodes) = mean(nodes_atrs);
            M(self.num_nodes,:) = mean(M);
            M(:,self.num_nodes) = mean(M,2);
            
            % Allocate memory for nodes and edges
            self.nodes = cell(1,self.num_nodes);
            self.nodes_vector = zeros(1,self.num_nodes);
            self.edges = cell(self.num_nodes,self.num_nodes);
            
            % Create Nodes
            for ID = 1:self.num_nodes
                self.nodes{ID}=node(ID,self);
                self.nodes_vector(ID)=nodes_atrs(ID);
                self.nodes_freq(ID)=1/self.num_nodes;
            end
            
            % Create Edge
            for i = 1:self.num_nodes
                for j = 1:self.num_nodes
                    self.edges{i,j}=edge(self,self.nodes{i},self.nodes{j});
                end
            end
            
            self.edges_matrix = M;
            
            % build cov
            self.nodes_cov = ones(size(self.nodes_vector));
            self.edges_cov = ones(size(self.edges_matrix));     
        end
        
        % delete nodes in the model according to the given indexes
        function modifyStructure(obj,deletingNodes)
            obj.num_nodes = obj.num_nodes-length(find(deletingNodes));
            obj.nodes_freq(deletingNodes) = [];
            obj.nodes(deletingNodes) = [];
            obj.edges(deletingNodes,:) = [];
            obj.edges(:,deletingNodes) = [];
            obj.nodes_vector(deletingNodes) = [];
            obj.nodes_cov(deletingNodes) = [];
            obj.edges_matrix(deletingNodes,:) = [];
            obj.edges_matrix(:,deletingNodes) = [];
            obj.edges_cov(deletingNodes,:) = [];
            obj.edges_cov(:,deletingNodes) = [];
            % update ID
                for i = 1:obj.num_nodes
                    obj.nodes{i}.ID=i;
                    for j = 1:obj.num_nodes
                        obj.edges{i,j}.node1=i;
                        obj.edges{i,j}.node2=j;
                    end
                end
        end
        
        % show the model ARG in matrix
        function pattern_bg = showARG(obj)
            pattern_bg = biograph(sparse(triu(obj.edges_matrix)),[],'ShowArrows','off','ShowWeights','on');
            view(pattern_bg)
        end
    end
    
end

