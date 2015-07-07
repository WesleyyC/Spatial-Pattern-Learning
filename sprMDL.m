classdef sprMDL < handle
    %   SpatialPatternMDL is a generalization model of a kind of spatail
    %   pattern providing by a set of sample ARGs.
    
    
    properties
        number_of_components = NaN;
        weight = NaN;
        mdl_ARGs={};
        sampleARGs = NaN;
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
        
        function updateWeight(obj)
            % first update component weight alpha
            sample_prob_array = @(sample)sprMDL.sample_components_probabilities(sample,obj.mdl_ARGs);
            each_weight = cellfun(sample_prob_array,obj.sampleARGs,'UniformOutput',false);
            sample_number = length(each_weight);
            obj.weight = zeros([1,obj.number_of_components]);
            for i = 1:sample_number
                obj.weight = obj.weight+each_weight{i};
            end
            obj.weight = obj.weight/sample_number;
            
            % then update nodes frequency beta
            for i = 1:obj.number_of_components
                obj.mdl_ARGs{i}.updateNodeWeight(sprMDL.component_node_frequency(obj.sampleARGs,obj.mdl_ARGs{i},num2cell(cell2mat(each_weight(i)))));
            end 
        end
       
    end
    
    methods(Static)
        function frequencies = component_node_frequency(samples,component,weights)
            single_sample_handle=@(sample,weight)sprMDL.component_node_frequency_in_sample(sample,component)*weight;
            each_frequencies=cellfun(single_sample_handle,samples,weights,'UniformOutput',false);
            frequencies = zeros([1,component.num_nodes]);
            sample_number = length(each_frequencies);
            for i = 1:sample_number
                frequencies=frequencies+each_frequencies{i};
            end
        end
        
        function frequencies = component_node_frequency_in_sample(sample,component)
            node_match_score = graph_matching(sample,component);
            frequencies = sum(node_match_score)/sample.num_nodes;
        end
        
        % sample matching probability arrays
        function probs = sample_components_probabilities(sample,components)
            % calculate the score for each component
            score_handle=@(component)sprMDL.component_score(sample,component);
            % return the array of score
            probs = cellfun(score_handle,components);
            % normalize
            probs = probs/sum(probs);
        end
        
        % scoring for each sample-component pair
        function score = component_score(sample,component)
           % run a matching on two graphs and get the scoring etc
           [node_match_score,node_compatibility,edge_compatibility] = graph_matching(sample,component);
           % calculate the prob from the nodes part
           score = sum(sum(bsxfun(@times,node_match_score,node_compatibility)));
           % calculate the prob from the edges part
           edge_times_handle = @(mat)sum(sum(bsxfun(@times,node_match_score,mat)));
           first_time = cellfun(edge_times_handle,edge_compatibility);
           score = score + sum(sum(bsxfun(@times,first_time,node_match_score)));         
        end
       
    end
end

