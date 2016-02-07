function [c] = edge_compatibility(edge, mdl_edge)
    % node_compatibility function is used to calculate the similarity
    % between node1 and node2
    
    c=0;
    
    if ~isa(edge,'edge') || ~isa(mdl_edge,'mdl_edge')
        error 'ArgumentTypeNotFit';
    elseif ~edge.exist()||~mdl_edge.exist()
        return;  % if either of the edge does not exist or has NaN attribute
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
        mdl_edge_cov_inv = mdl_edge.cov_inv;
        
        % calculate the score
        c=exp(-0.5*(edge_atrs-mdl_edge_atrs)*mdl_edge_cov_inv*(edge_atrs-mdl_edge_atrs)')/...
            ((2*pi)^(num_atrs/2)*sqrt(det(mdl_edge_cov)));
    end
end

