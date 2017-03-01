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
        function self = mdl_ARG(A)
            
            M = A.edges_matrix;
            nodes_atrs = A.nodes_vector;
            
            % Throw error if not enough argument
            if nargin < 1
                error "NotEnoughArgument";
            end
            
            % Throw error if the matrix is not a square
            if size(M,1)~=size(M,2)
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
            nodes_atrs(self.num_nodes,:) = mean(nodes_atrs);
            M(self.num_nodes,:,:) = mean(M);
            M(:,self.num_nodes,:) = mean(M,2);
            
            % Allocate memory for nodes and edges
            self.nodes = cell(1,self.num_nodes);
            self.nodes_vector = zeros(self.num_nodes, size(nodes_atrs,2));
            self.nodes_cov = zeros(self.num_nodes, size(nodes_atrs,2)^2);
            self.edges = cell(self.num_nodes,self.num_nodes);
            self.edges_matrix = zeros(self.num_nodes, self.num_nodes, size(M,3));
            self.edges_cov = zeros(self.num_nodes, self.num_nodes, size(M,3)^2);
            
            
            % Create Nodes
            for ID = 1:self.num_nodes
                self.nodes{ID}=node(ID,self);
                self.nodes_vector(ID,:)=nodes_atrs(ID,:);
                self.nodes_cov(ID,:)=reshape(eye(size(nodes_atrs,2)),size(self.nodes_cov(ID,:)));
                self.nodes_freq(ID)=1/self.num_nodes;
            end
            
            % Create Edge
            for i = 1:self.num_nodes
                for j = 1:self.num_nodes
                    self.edges{i,j}=edge(self,self.nodes{i},self.nodes{j});
                    self.edges_matrix(i,j,:) = M(i,j,:);
                    self.edges_cov(i,j,:) = reshape(eye(size(M, 3)),size(self.edges_cov(i,j,:)));
                end
            end  
        end
        
        % delete nodes in the model according to the given indexes
        function modifyStructure(obj,deletingNodes)
            obj.num_nodes = obj.num_nodes-length(find(deletingNodes));
            obj.nodes_freq(deletingNodes) = [];
            obj.nodes(deletingNodes) = [];
            obj.edges(deletingNodes,:) = [];
            obj.edges(:,deletingNodes) = [];
            obj.nodes_vector(deletingNodes,:) = [];
            obj.nodes_cov(deletingNodes,:) = [];
            obj.edges_matrix(deletingNodes,:,:) = [];
            obj.edges_matrix(:,deletingNodes,:) = [];
            obj.edges_cov(deletingNodes,:,:) = [];
            obj.edges_cov(:,deletingNodes,:) = [];
            % update ID
                for i = 1:obj.num_nodes
                    obj.nodes{i}.ID=i;
                    for j = 1:obj.num_nodes
                        obj.edges{i,j}.node1=i;
                        obj.edges{i,j}.node2=j;
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

