classdef mdl_edge < edge
    % mdl_edge is a subclass of edge which will be used in the mdl_ARG
    
    properties (GetAccess=public,SetAccess=protected)
        cov=NaN;
        cov_inv = NaN;
    end
    
    methods
        % Constructor for the class
        function  obj = mdl_edge(atrs,node1ID,node2ID,sortedNodes)
            % Throw error if not enough argument
            if nargin < 4
                error "NotEnoughArgument";
            end
            
            % Passing original value
            obj=obj@edge(atrs,node1ID,node2ID,sortedNodes);
            
            % Initial covariance matrix as an identtiy matrix
            obj.cov = eye(length(atrs));
            obj.cov_inv=inv(obj.cov);
        end
        
        % Update Mean
        
        % Update Covariance Matrix
    end
    
end

