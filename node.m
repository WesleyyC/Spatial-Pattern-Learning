classdef node
    %	node is a class representing the point in a graph
    %   node will have edge (also class) connected to it and its own
    %   attributes value represented with a vector
    
    properties (GetAccess=public,SetAccess=private)
        % The attributes
        atrs=[];        
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
        
        function [tf] = hasAtrs(node)
            tf = ~isempty(node.atrs);
        end
        
    end
    
end

