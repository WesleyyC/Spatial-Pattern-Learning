function [ M ] = heuristic( M, A, I, train )
%   HEURISTIC is a function that will make a matrix into a permuation
%   matrix according to some rules.

%   In this version, the cleanM will make the largest number in each row 1
%   and the others to 0.

    % Heuristic
%     M = double(bsxfun(@eq, M, max(M, [], 1)));
    
    if train
        M = M + (2*rand(size(M))-1)*(1/A);
    end

    M(1:A,:)=normr(M(1:A,:)).*normr(M(1:A,:));

    % get the right size
    M=M(1:A,:);
        
end

