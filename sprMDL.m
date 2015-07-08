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
            % get the node matching score
            obj.graphMatching();
            % get the sample-component matching score and probability
            obj.getMatchingProbs();
            % update the weight for each component
            obj.updateComponentWeight();
            % update the frequency for each component node
            obj.updateComponentNodeFrequency();
            % update the atrs for each component node
            obj.updateComponentNodeAtrs();
        end
        
        % update the atrs for each component node
        % # this function can be easier, but I can think of a better way to
        % do this yet since atrs can be vector and cell operation is not
        % fast/easy
        function updateComponentNodeAtrs(obj)
            % for each component
            for i = 1:obj.number_of_components
                % for each node
                for n = 1:obj.mdl_ARGs{i}.num_nodes
                    atrs = 0;
                    denominator=0;
                    % we go over the sample
                    for j = 1:obj.number_of_sample
                        current_sample_atrs = 0;
                        current_sample_denominator = 0;
                        % and finds its matching node, calculate the
                        % average atrs
                        for v =  1:obj.sampleARGs{j}.num_nodes
                            current_sample_atrs=current_sample_atrs+obj.sampleARGs{j}.nodes{v}.atrs*obj.node_match_scores{j,i}(v,n);
                            current_sample_denominator = current_sample_denominator + obj.node_match_scores{j,i}(v,n);
                        end
                        atrs = atrs + current_sample_atrs*obj.sample_component_matching_probs(j,i);
                        denominator = denominator + current_sample_denominator*obj.sample_component_matching_probs(j,i);
                    end
                    % udpate the value
                    obj.mdl_ARGs{i}.nodes{n}.updateAtrs(atrs/denominator);
                end
            end       
        end
        
        % update the frequency for each component node
        function updateComponentNodeFrequency(obj)
            % for each component
            for i = 1:obj.number_of_components
                frequency=0;
                sample_node_sum = 0;
                % for each sample
                for j = 1:obj.number_of_sample
                    % we calculate the component node frequency in this
                    % specific sample
                    current_freq =sum(obj.node_match_scores{j,i});
                    frequency=frequency+current_freq*obj.sample_component_matching_probs(j,i);
                    sample_node_sum=sample_node_sum+obj.sampleARGs{j}.num_nodes*obj.sample_component_matching_probs(j,i);
                end
                % update the frequency for all the nodes in the model in
                % the same time
                obj.mdl_ARGs{i}.updateNodeFrequency(frequency/sample_node_sum);
            end    
        end
        
        % update the weight for each component
        function updateComponentWeight(obj)
            % sum up the samples-component probabilities and divide by
            % sample number
            obj.weight = sum(obj.sample_component_matching_probs)/obj.number_of_sample;
        end
        
        % get the sample-component matching score and probability
        function getMatchingProbs(obj)
            % Use the graphMatching() data calculate the sample-componennt
            % matching score & probability
            handle=@(node_match_score,node_compatibility,edge_compatibility)sprMDL.component_score(node_match_score,node_compatibility,edge_compatibility);
            obj.component_scores=cellfun(handle,obj.node_match_scores,obj.node_compatibilities,obj.edge_compatibilities);
            s=sum(obj.component_scores,2);
            n=repmat(s,1,obj.number_of_components);
            obj. sample_component_matching_probs=obj.component_scores./n;
        end
        
        % get the graph matching score for each sample-componennt pair
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

