function [ M ] = heuristic( M )
%   HEURISTIC is a function that will make a matrix into a permuation
%   matrix according to some rules.

%   In this version, the cleanM will make the largest number in each row 1
%   and the others to 0.

    % get the number of row in M
    row = length(M(:,1));

    % clean up
    for i = 1:row
        % get the index
        [~,index] = max(M(i,:));
        % set the index row and colum to zero
        M(i,:)=zeros(size(M(i,:)));
        M(:,index)=zeros(size(M(:,index)));
        M(i,index)=1;
    end
        


end

