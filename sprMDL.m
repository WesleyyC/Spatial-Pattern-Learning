classdef sprMDL < handle
    %   SpatialPatternMDL is a generalization model of a kind of spatail
    %   pattern providing by a set of sample ARGs.
    
    
    %   algorithm current works with zeros instead of NaN
    properties
        number_of_components = NaN;
        weight = NaN;
        mdl_ARGs={};
    end
    
    methods
        % Constructor for the class
        function  obj = mdl_node(sampleARGs,number_of_components)
            
            % Throw error if not enough argument
            if nargin < 1
                error "NotEnoughArgument";
            elseif length(sampleARGs)>number_of_components
                error "NotEnoughSample"
            end
            
            % Get the number of components
            obj.number_of_components = number_of_components;
            obj.mdl_ARGs = cell(1,number_of_components);
            
            % Assigning Weight
            obj.weight = ones([1,number_of_components])/number_of_components;
            
            % Randoming pick component from sampleARGs
            idx = randperm(length(sampleARGs)); % we first permutate the index for randomness
            idx = idx(1:number_of_components);  % take what we need
            
            % Now convert it to model ARG
            obj.mdl_ARGs=cellfun(@mdl_ARG,sampleARGs{idx}); 
        end
        
    end
    
end

