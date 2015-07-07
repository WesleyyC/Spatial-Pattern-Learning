function [c] = node_compatibility(node, mdl_node)
    % node_compatibility function is used to calculate the similarity
    % between node1 and node2
    
    c=0;
    if ~isa(node,'node') || ~isa(mdl_node,'mdl_node')
        error 'ArgumentTypeNotFit';
    elseif ~node.hasAtrs()||~mdl_node.hasAtrs()
        return;  % if either of the nodes has NaN attribute, set similarity to 0
    elseif node.numberOfAtrs() ~= mdl_node.numberOfAtrs()    
        return;  % if the nodes have different number of attributes, set similarity to 0
    else
        
        % get number of attributes
        num_atrs = mdl_node.numberOfAtrs();
        
        % get the mean of attributes
        node_atrs = node.atrs;
        mdl_node_atrs = mdl_node.atrs;
        % get the covariance matrix of model node
        mdl_node_cov = mdl_node.cov;
        
        % calculate the score
        c=exp(-(node_atrs-mdl_node_atrs)*inv(mdl_node_cov)*(node_atrs-mdl_node_atrs)')/...
            ((2*pi)^(num_atrs/2)*sqrt(det(mdl_node_cov)));
    end
end

