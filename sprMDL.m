classdef sprMDL < handle
    %   SpatialPatternMDL is a generalization model of a kind of spatail
    %   pattern providing by a set of sample ARGs.
    
    
    properties
        % Important number in model
        number_of_components = NaN;
        number_of_sample = NaN;
        
        % alpha, weight for each model
        weight = NaN;
        
        % the components
        mdl_ARGs={};
        
        % the sample
        sampleARGs = NaN;
        
        % graph matching return
        node_match_scores={};
        node_compatibilities={};
        edge_compatibilities={};
        
        % sample-component matching score
        component_scores = NaN;
        sample_component_matching_probs=NaN;
        
    end
    
    methods
        % Constructor for the class
        function  obj = sprMDL(sampleARGs,number_of_components)
            
            % Throw error if not enough argument
            if nargin < 1
                error "NotEnoughArgument";
            elseif length(sampleARGs)>number_of_components
                error "NotEnoughSample"
            end
            
            % Pass sample ARGs
            obj.sampleARGs=sampleARGs;
            
            % Get the number of components
            obj.number_of_components = number_of_components;
            obj.number_of_sample=length(sampleARGs);
            obj.mdl_ARGs = cell(1,number_of_components);
            
            % Assigning Weight to 1
            obj.weight = ones([1,number_of_components]);
            
            % Randoming pick component from sampleARGs
            idx = randperm(length(sampleARGs)); % we first permutate the index for randomness
            idx = idx(1:number_of_components);  % take what we need
            comp_ARG = sampleARGs(idx);
            % Now convert it to model ARG
            obj.mdl_ARGs=cellfun(@mdl_ARG,comp_ARG,'UniformOutput',false); 
        end
        
        function EM(obj)
            obj.graphMatching();
            obj.getMatchingProbs();
            obj.updateComponentWeight();
            obj.updateComponentNodeFrequency();
        end
        
        function updateComponentWeight(obj)
            obj.weight = sum(obj.sample_component_matching_probs)/obj.number_of_sample;
        end
        
        function updateComponentNodeFrequency(obj)
            for i = 1:obj.number_of_components
                frequency=zeros([1,obj.mdl_ARGs{i}.num_nodes]);
                sample_node_sum = 0;
                for j = 1:obj.number_of_sample
                    current_freq =sum(obj.node_match_scores{j,i});
                    frequency=frequency+current_freq*obj.sample_component_matching_probs(j,i);
                    sample_node_sum=sample_node_sum+obj.sampleARGs{j}.num_nodes*obj.sample_component_matching_probs(j,i);
                end
                obj.mdl_ARGs{i}.updateNodeFrequency(frequency/sample_node_sum);
            end    
        end
        
        function getMatchingProbs(obj)
            obj.graphMatching();
            handle=@(node_match_score,node_compatibility,edge_compatibility)sprMDL.component_score(node_match_score,node_compatibility,edge_compatibility);
            obj.component_scores=cellfun(handle,obj.node_match_scores,obj.node_compatibilities,obj.edge_compatibilities);
            s=sum(obj.component_scores,2);
            n=repmat(s,1,obj.number_of_components);
            obj. sample_component_matching_probs=obj.component_scores./n;
        end
        
        function graphMatching(obj)
            obj.node_match_scores = cell([obj.number_of_sample,obj.number_of_components]);
            obj.node_compatibilities = cell(size(obj.node_match_scores));
            obj.edge_compatibilities = cell(size(obj.node_match_scores));
            
            for i=1:obj.number_of_sample
                for j = 1:obj.number_of_components
                    [node_match_score,node_compatibility,edge_compatibility] = graph_matching(obj.sampleARGs{i},obj.mdl_ARGs{j});
                    obj.node_match_scores{i,j}=node_match_score;
                    obj.node_compatibilities{i,j}=node_compatibility;
                    obj.edge_compatibilities{i,j}=edge_compatibility;
                end
            end
        end
    end
    
    methods(Static)
        % scoring for each sample-component pair
        function score = component_score(node_match_score,node_compatibility,edge_compatibility)
           % calculate the prob from the nodes part
           score = sum(sum(bsxfun(@times,node_match_score,node_compatibility)));
           
           % calculate the prob from the edges part
           % #this only feels right, but might need a fresh eye to check on
           % it
           edge_times_handle = @(mat)sum(sum(bsxfun(@times,node_match_score,mat)));
           first_time = cellfun(edge_times_handle,edge_compatibility);
           score = score + sum(sum(bsxfun(@times,first_time,node_match_score)));         
        end
       
    end
end

