classdef mdl_node < node
    % mdl_node is a subclass of node which will be used in the mdl_ARG
    
    properties (GetAccess=public,SetAccess=private)
        cov=NaN;
        frequency = NaN;
    end
    
    methods
        % Constructor for the class
        function  obj = mdl_node(ID,atrs,frequency)
            % Throw error if not enough argument
            if nargin < 2
                error "NotEnoughArgument";
            end
            
            % Passing original value
            obj=obj@node(ID,atrs);
            
            % Initial covariance matrix as an identtiy matrix
            obj.cov = eye(length(atrs));
            
            % Initial frequency
            obj.frequency = frequency;
        end
    end
    
    % Update Mean
        
    % Update Covariance Matrix
    
end

