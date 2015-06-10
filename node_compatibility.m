function [c] = node_compatibility(node1, node2)
    % node_compatibility function is used to calculate the similarity
    % between node1 and node2
    
    % the score is between [0,1]
    
    % the higher the score, the more similiarity are there between node1
    % and node2
    
    % this function can be define by the user, but in our case is
    % c(N,n)=1-3|N-n|;
    
    % assume node1 and node2 are node object
    
    if ~obj.hasAtrs()||~obj2.hasAtrs()
        c = 0;  % if either of the nodes has NaN attribute, set similarity to 0
    elseif obj.numberOfAtrs() ~= obj2.numberOfAtrs()    
        c = 0;  % if the nodes have different number of attributes, set similarity to 0
    else
        % get number of attributes
        no_atrs = node1.numberOfAtrs();
    
        % get the attributes
        node1_atrs = node1.atrs;
        node2_atrs = node2.atrs;
        
        % sum up the score for each attributes
        for i =1:no_atrs
            current_atr_score = 1-3*abs(node1_atrs(i)-node2_atrs(u));
            c = c+current_atr_score;
        end
        
        % normalize the score
        c = c/no_atrs;
    end

    

end

