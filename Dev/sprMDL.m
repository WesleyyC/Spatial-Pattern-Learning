classdef sprMDL < handle & matlab.mixin.Copyable
    %   SpatialPatternMDL is a generalization model of a kind of spatail
    %   pattern providing by a set of sample ARGs   
    
    %   assume null value is 0
    
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
        
        % threshold score for confirming pattern
        thredshold_score = NaN;
        z_test_mean = 0;
        z_test_sigma = 0;
        
    end
    
    properties (Constant)
        % Maximum EM rounds
        iteration_EM = 30;
        
        % Converging epsilon
        e_mdl_converge = 1e-4;
        
        % Node deleting threshold
        % We don't want to delete nodes in early stage
        % so choose such number carefully
        % e_delete_base - e_delete_iter^iter
        e_delete_base = 1;
        e_delete_iter = 0.85;

        % z_test properties
        z_test_alpha = 0.001;
        z_test_sample_number = 50;
    end
    
    methods
        % Constructor for the class
        function  obj = sprMDL(sampleARGs,number_of_components)
            
            % Throw error if not enough argument
            if nargin < 1
                error "NotEnoughArgument";
            elseif length(sampleARGs)<number_of_components
                error "NotEnoughSample"
            end
            
            % Pass sample ARGs
            obj.sampleARGs=sampleARGs;
            
            % Get the number of components
            obj.number_of_components = number_of_components;
            obj.number_of_sample=length(sampleARGs);
            obj.mdl_ARGs = cell(1,number_of_components);
            
            % Assigning Weight to 1
            obj.weight = ones([1,number_of_components])/number_of_components;
            
            % Randoming pick component from sampleARGs
            idx = randperm(length(sampleARGs)); % we first permutate the index for randomness
            idx = idx(1:number_of_components);  % take what we need
            comp_ARG = sampleARGs(idx);
            
            % Now convert it to model ARG
            generate_mdl_ARG=@(A)mdl_ARG(A.edges_matrix, A.nodes_vector);
            obj.mdl_ARGs=cellfun(generate_mdl_ARG,comp_ARG,'UniformOutput',false); 
            
            % Train the model with the sample
            obj.trainModel();
        end
            
        % Train the model with the sample
        function trainModel(obj)
            % Set up variable
            converge = false;
            iter = 0;
            % EM iteration
            while ~converge && iter<obj.iteration_EM
                % increment the iter
                iter = iter+1;
                % get the old obj before iteration for testing converging
                old_obj = obj.copy();
                % go through one EM iteration
                obj.EM(iter);
                % check converging condition
                converge = sprMDL.mdl_converge(old_obj,obj,obj.e_mdl_converge);
            end
            % get the thredshold minimum score
            obj.getThredsholdScore();
        end
        
        % The EM-alogirthem procedure
        function EM(obj,iter)    
            trainRound=tic();
            
            % get the node matching score
            obj.graphMatching(true);
            
            % get the sample-component matching score and probability
            obj.getMatchingProbs();
            
            % update the weight for each component
            obj.updateComponentWeight();
            
            % update the frequency for each component node
            obj.updateComponentNodeFrequency();
            
            % update the atrs for each component node
            obj.updateComponentNodeAtrs();
            
            % update the covariance matrix for each component node
            obj.updateComponentNodeCov();
            
            % update the atrs for each component edge
            obj.updateComponentEdgeAtrs();
            
            % update the covariance matrix for each component edge
            obj.updateComponentEdgeCov();
            
            % update the component structure depends on the node frequency
            obj.updateComponentStructure(iter);
            
            toc(trainRound)
        end
        
        % get the graph matching score for each sample-componennt pair
        function graphMatching(obj,train)
            obj.node_match_scores = cell([obj.number_of_sample,obj.number_of_components]);
            obj.node_compatibilities = cell(size(obj.node_match_scores));
            obj.edge_compatibilities = cell(size(obj.node_match_scores));
            
            for i=1:obj.number_of_sample
                for j = 1:obj.number_of_components
                    [node_match_score,node_compatibility,edge_compatibility] = graph_matching(obj.sampleARGs{i},obj.mdl_ARGs{j},train);
                    obj.node_match_scores{i,j}=node_match_score;
                    obj.node_compatibilities{i,j}=node_compatibility;
                    obj.edge_compatibilities{i,j}=edge_compatibility;
                end
            end
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
        
        % update the weight for each component
        function updateComponentWeight(obj)
            % sum up the samples-component probabilities and divide by
            % sample number
            obj.weight = sum(obj.sample_component_matching_probs)/obj.number_of_sample;
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
                obj.mdl_ARGs{i}.nodes_freq = frequency/sample_node_sum;
            end    
        end
        
        % update the atrs for each component node
        function updateComponentNodeAtrs(obj)
            % for each component
            for h = 1:obj.number_of_components
                % for each node
                for n = 1:obj.mdl_ARGs{h}.num_nodes
                    if any(obj.mdl_ARGs{h}.nodes_vector(n))
                        atrs = 0;
                        denominator=0;
                        % we go over the sample
                        for i = 1:obj.number_of_sample
                            current_sample_atrs = obj.sampleARGs{i}.nodes_vector.*obj.node_match_scores{i,h}(:,n)';
                            current_sample_denominator = (obj.sampleARGs{i}.nodes_vector~=0).*obj.node_match_scores{i,h}(:,n)';
                            
                            current_sample_atrs = sum(current_sample_atrs);
                            current_sample_denominator = sum(current_sample_denominator);
                            
                            atrs = atrs + current_sample_atrs*obj.sample_component_matching_probs(i,h);
                            denominator = denominator + current_sample_denominator*obj.sample_component_matching_probs(i,h);
                        end
                        % udpate the value
                        obj.mdl_ARGs{h}.nodes_vector(n)=atrs/denominator;
                    end
                end
            end       
        end
        
        % update the covariance matrix for each component node
        function updateComponentNodeCov(obj)
            % for each component
            for h = 1:obj.number_of_components
                % for each node
                for n = 1:obj.mdl_ARGs{h}.num_nodes
                    if any(obj.mdl_ARGs{h}.nodes_vector(n))
                        cov = 0;
                        denominator=0;
                        % we go over the sample
                        for i = 1:obj.number_of_sample
                            x_atrs = obj.sampleARGs{i}.nodes_vector-obj.mdl_ARGs{h}.nodes_vector(n);
                            current_sample_cov = (obj.sampleARGs{i}.nodes_vector~=0).*x_atrs.*x_atrs.*obj.node_match_scores{i,h}(:,n)';
                            current_sample_denominator = (obj.sampleARGs{i}.nodes_vector~=0).*obj.node_match_scores{i,h}(:,n)';
                            
                            current_sample_cov = sum(current_sample_cov);
                            current_sample_denominator = sum(current_sample_denominator);
                            
                            cov = cov + current_sample_cov*obj.sample_component_matching_probs(i,h);
                            denominator = denominator + current_sample_denominator*obj.sample_component_matching_probs(i,h);
                        end
                        % udpate the value
                        obj.mdl_ARGs{h}.nodes_cov(n) = cov/denominator;
                    end
                end
            end       
        end
        
        % update the atrs for each component edge
        function updateComponentEdgeAtrs(obj)
            %for each component
            for h = 1:obj.number_of_components
                %for each edge 
                for o = 1:obj.mdl_ARGs{h}.num_nodes
                    for t = o+1:obj.mdl_ARGs{h}.num_nodes
                        if any(obj.mdl_ARGs{h}.edges_matrix(o,t))
                            atrs = 0;
                            denominator=0;
                            %for each sample
                            for i = 1:obj.number_of_sample
                                current_sample_atrs = obj.sampleARGs{i}.edges_matrix.*(obj.node_match_scores{i,h}(:,o)*obj.node_match_scores{i,h}(:,t)');
                                current_sample_denominator = (obj.sampleARGs{i}.edges_matrix~=0).*(obj.node_match_scores{i,h}(:,o)*obj.node_match_scores{i,h}(:,t)');
                                
                                current_sample_atrs = sum(sum(current_sample_atrs));
                                current_sample_denominator = sum(sum(current_sample_denominator));
                                
                                atrs=atrs+current_sample_atrs*obj.sample_component_matching_probs(i,h);
                                denominator = denominator + current_sample_denominator*obj.sample_component_matching_probs(i,h);
                            end
                            % update the value
                            new_atr = atrs/denominator;
                            obj.mdl_ARGs{h}.edges_matrix(o,t) = new_atr;
                            obj.mdl_ARGs{h}.edges_matrix(t,o) = new_atr;
                        end
                    end
                end
            end                     
        end
        
        % update the covariance matrix for each component edge
        function updateComponentEdgeCov(obj)
            %for each component
            for h = 1:obj.number_of_components
                %for each edge 
                for o = 1:obj.mdl_ARGs{h}.num_nodes
                    for t = o+1:obj.mdl_ARGs{h}.num_nodes
                        if any(obj.mdl_ARGs{h}.edges_matrix(o,t))
                            cov = 0;
                            denominator=0;
                            %for each sample
                            for i = 1:obj.number_of_sample
                                z_atrs = obj.sampleARGs{i}.edges_matrix-obj.mdl_ARGs{h}.edges_matrix(o,t);
                                current_sample_cov = (obj.sampleARGs{i}.edges_matrix~=0).*z_atrs.*z_atrs.*(obj.node_match_scores{i,h}(:,o)*obj.node_match_scores{i,h}(:,t)');
                                current_sample_denominator = (obj.sampleARGs{i}.edges_matrix~=0).*(obj.node_match_scores{i,h}(:,o)*obj.node_match_scores{i,h}(:,t)');
                                
                                current_sample_cov = sum(sum(current_sample_cov));
                                current_sample_denominator = sum(sum(current_sample_denominator));
                                
                                cov=cov+current_sample_cov*obj.sample_component_matching_probs(i,h);
                                denominator = denominator + current_sample_denominator*obj.sample_component_matching_probs(i,h);
                            end
                            % update the value
                            obj.mdl_ARGs{h}.edges_cov(o,t) = cov/denominator;
                            obj.mdl_ARGs{h}.edges_cov(t,o) = cov/denominator;
                        end
                    end
                end
            end     
        end
        
        % update the component structure depends on the node frequency
        function updateComponentStructure(obj,iter)
            % for each component
            for w = 1:obj.number_of_components
                av_frequency=0;
                prob_sum = 0;
                % for each sample
                for j = 1:obj.number_of_sample
                    % we calculate the component node frequency in this
                    % specific sample
                    current_freq =sum(obj.node_match_scores{j,w});
                    av_frequency=av_frequency+current_freq*obj.sample_component_matching_probs(j,w);
                    prob_sum=prob_sum+obj.sample_component_matching_probs(j,w);
                end
                % get the average matching probability
                av_matching_prob = av_frequency/prob_sum;
                % delet the node that is less tha the threshold 1-e^iter
                deleteIdx = av_matching_prob < obj.e_delete_base-obj.e_delete_iter^iter;
                deleteIdx(end)=0; % the null node will always be remained
                obj.mdl_ARGs{w}.modifyStructure(deleteIdx);
            end
        end
                
        % Get the thredshold score for confimrming pattern
        function getThredsholdScore(obj)            
            size = 0;
            for i = 1:obj.number_of_sample
                size = size + obj.sampleARGs{i}.num_nodes;
            end
            size = ceil(size / obj.number_of_sample);
            
            edge_atrs = [];
            for i = 1:obj.number_of_sample
                edge_atrs = [edge_atrs, obj.sampleARGs{i}.edges_matrix(:)'];
            end
            
            weight_range = ceil(max(edge_atrs));
            
            connected_rate = length(find(edge_atrs))/length(edge_atrs);
            
            number_of_random_samples = obj.z_test_sample_number;
            random_sample_scores=zeros([1,number_of_random_samples]);

            for i = 1:number_of_random_samples
                % setup sample
                M1_size = round((1+rand*0.2)*size);
                M1 = triu((rand(M1_size)*2-1)*weight_range,1);    %  upper left part of a random matrix with weight_range
                connected_nodes = triu(rand(M1_size)<connected_rate,1);    % how many are connected
                M1 = M1.*connected_nodes;
                M1 = M1 + M1'; % make it symmetric
                V1 = (rand([1,M1_size])*2-1)*weight_range;
                % Create the sample
                random_sample_scores(i) = obj.scorePattern(ARG(M1, V1));
            end
            
            obj.z_test_mean = mean(random_sample_scores);
            obj.z_test_sigma = std(random_sample_scores);
            obj.thredshold_score = obj.z_test_mean + 3 * obj.z_test_sigma;
            
        end
        
        % Detect if a ARG has the same pattern
        function [tf, score] = checkPattern(obj, ARG)
            score = obj.scorePattern(ARG);
            tf = ztest(score, obj.z_test_mean,obj.z_test_sigma,'Alpha',obj.z_test_alpha, 'Tail','Right');
        end
        
        % Detect if a ARG has the same pattern
        function score = scorePattern(obj, ARG)
            score = 0;
            for i = 1:obj.number_of_components
               [node_match_score,node_compatibility,edge_compatibility]=graph_matching(ARG,obj.mdl_ARGs{i},false);
                score = score + ...
                    sprMDL.component_score(node_match_score,node_compatibility,edge_compatibility) * obj.weight(i);
            end
        end
    end
    
    methods(Static)
        % scoring for each sample-component pair
        function score = component_score(node_match_score,node_compatibility,edge_compatibility)
            
            % get the size
            [A, I] = size(node_match_score);
           
            % no null node
            node_match_score(:,end)=0;
            
            % edge score
            Q = zeros(A, I);
            for a = 1:A
                for i = 1:I
                    Q(a,i)=sum(sum(edge_compatibility(((a-1)*A+1):((a-1)*A+A),((i-1)*I+1):((i-1)*I+I)).*node_match_score));
                end
            end
            
            % node score
            Q = Q + node_compatibility;
            
            % consider probability
            Q = Q .* node_match_score;
            
            % sum up the score
            score = sum(sum(Q));
        end
        
        % mdl_converge judges if the model is converged
        function converge = mdl_converge( old_mdl, new_mdl, e )
            if length(old_mdl.weight)==length(new_mdl.weight)
                diff = sum(abs(old_mdl.weight-new_mdl.weight))/length(new_mdl.weight);
                converge = diff<e;
            else
                converge = false;
            end
        end
       
    end
end

