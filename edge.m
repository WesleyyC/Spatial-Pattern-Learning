classdef edge
    %   edge is the connection between node and 
    %   it will have some assigned weight and two end points (nodes)
    
    properties (GetAccess=public,SetAccess=private)
        % The attributes
        weight=NaN;
        node1
    end
    
    methods
        % Constructor for the class
        function  self = node(arg)
            % Return empty if no arguments
            if nargin == 0
                return;
            end
            
            % Copy constructor if arg is node
            if isa(arg,'node')
                self.atrs = arg.atrs;
                return;
            end
            
            % Otherwise, arg is the atrributes value
            self.atrs = arg;
        end
    end
    
end

