function [ converge ] = mdl_converge( old_mdl,new_mdl,e )
    % mdl_converge judges if the model is converged
    
    if length(old_mdl.weight)==length(new_mdl.weight)
        diff = sum(abs(old_mdl.weight-new_mdl.weight))/length(new_mdl.weight);
        converge = diff<e;
    else
        converge = false;
    end
end

