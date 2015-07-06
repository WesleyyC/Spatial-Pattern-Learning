function [c] = edge_compatibility(edge, mdl_edge)
    % node_compatibility function is used to calculate the similarity
    % between node1 and node2
    
    c=0;
    
    if ~isa(edge,edge) || ~isa(mdl_edge,mdl_edge)
        error 'ArgumentTypeNotFit';
    elseif ~edge.hasAtrs()||~mdl_edge.hasAtrs()
        return;  % if either of the nodes has NaN attribute, set similarity to 0
    elseif edge.numberOfAtrs() ~= mdl_edge.numberOfAtrs()    
        return;  % if the nodes have different number of attributes, set similarity to 0
    else
        
        % get number of attributes
        num_atrs = mdl_edge.numberOfAtrs();
        
        % get the mean of attributes
        edge_atrs = edge.atrs;
        mdl_edge_atrs = mdl_edge.atrs;
        % get the covariance matrix of model node
        mdl_edge_cov = mdl_edge.cov;
        
        % calculate the score
        c=exp(-(edge_atrs-mdl_edge_atrs)*inv(mdl_edge_cov)*(edge_atrs-mdl_edge_atrs)')/...
            ((2*pi)^(num_atrs/2)*sqrt(det(mdl_edge_cov)));
    end
end

