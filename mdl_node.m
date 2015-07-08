classdef mdl_node < node
    % mdl_node is a subclass of node which will be used in the mdl_ARG
    
    properties (GetAccess=public,SetAccess=protected)
        cov=NaN;
        cov_inv = NaN;
        frequency = NaN;
    end
    
    properties(Constant)
        e_inv = 0.2;
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
            obj.cov_inv=inv(obj.cov);
            
            % Initial frequency
            obj.frequency = frequency;
        end
        
        function updateFrequency(obj,freq)
            obj.frequency = freq;
        end
    
        % Update Mean
        function updateAtrs(obj,atrs)
            obj.atrs = atrs;
        end

        % Update Covariance Matrix
        function updateCov(obj,cov)
            obj.cov = cov;
            obj.cov_inv = mdl_node.inverse(obj.cov);
        end
    end
    
    methods(Static)
        function cov_inv = inverse(mat)
            if rcond(mat) < mdl_node.e_inv
                mat=mat+eye(size(mat));
                cov_inv = mdl_node.inverse(mat);
            else
                cov_inv = inv(mat);
            end 
        end
    end
end

