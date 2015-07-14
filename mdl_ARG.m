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
            self.num_nodes=ARG.num_nodes+1;
            
            % Allocate memory for nodes and edges
            self.nodes = cell(1,self.num_nodes);
            self.edges = cell(self.num_nodes,self.num_nodes);
            
            % Initial frequency to 1
            freq = 1;
            
            % Convert ARG node to mdl_node
            mdl_node_handle=@(node)mdl_node(node.ID,node.atrs,freq);
            self.nodes(1:self.num_nodes-1) = cellfun(mdl_node_handle,ARG.nodes,'UniformOutput',false);
            
            % Convert ARG edge to mdl_edge
            mdl_edge_handle=@(edge)mdl_edge(edge.atrs,edge.node1ID,edge.node2ID,self.nodes);
            self.edges(1:self.num_nodes-1,1:self.num_nodes-1) = cellfun(mdl_edge_handle,ARG.edges,'UniformOutput',false);
            
            % Add null for background
            self.nodes{self.num_nodes} = mdl_node(self.num_nodes,0,freq);
            for i=1:self.num_nodes
                self.edges{self.num_nodes,i}=mdl_edge(0,self.num_nodes,i,self.nodes);
                self.edges{i,self.num_nodes}=mdl_edge(0,i,self.num_nodes,self.nodes);
            end
                
        end
        
        % update the nodes frequency in the model
        function updateNodeFrequency(obj,frequencies)
            for i =1:obj.num_nodes
                obj.nodes{i}.updateFrequency(frequencies(i));
            end
        end
        
        % delete nodes in the model according to the given indexes
        function modifyStructure(obj,deletingNodes)
            obj.nodes(deletingNodes)=[];
            obj.edges(deletingNodes,:)=[];
            obj.edges(:,deletingNodes)=[];
            obj.num_nodes=obj.num_nodes-length(find(deletingNodes));
        end
        
        % return a vector of nodes frequency
        function frequencies = getNodeFrequency(obj)
           getFrequency = @(node)node.frequency;
           frequencies=cellfun(getFrequency,obj.nodes);
        end
        
        % show the model ARG in matrix
        function model_struct = showARG(obj)
            % get the nodes frequencies
            nodes_frequence = obj.getNodeFrequency();
            
            % get the nodes attributes
            getNodeAttributes = @(node)node.atrs;
            nodes_attributes = cellfun(getNodeAttributes,obj.nodes);
            % build the matrix
            getEdgeAttributes = @(edge)edge.atrs;
            M = cellfun(getEdgeAttributes,obj.edges);
            
            % draw it out
            bg = biograph(triu(M(1:end-1,1:end-1)),[],'ShowArrows','off','ShowWeights','on');

            model_struct = struct(  'Nf',nodes_frequence,... % the node frequency
                                    'Na', nodes_attributes, ... % the node attributes
                                    'M', M, ... % the matrix
                                    'bg', bg...% the graph
                                    );
        end
            
    end
    
end

