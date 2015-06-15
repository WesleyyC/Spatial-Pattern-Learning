function [ M ] = heuristic( M, A, I )
%   HEURISTIC is a function that will make a matrix into a permuation
%   matrix according to some rules.

%   In this version, the cleanM will make the largest number in each row 1
%   and the others to 0.

    % get the right size
    M=M(1:A,1:I);

    % get the number of row in M
    row = length(M(:,1));
    % get the thred
    thred = 1/row;

    % clean up
    for i = 1:row
        % get the index
        [maxin,index] = max(M(i,:));
        % set the row to zero
        M(i,:)=zeros(size(M(i,:)));
        % if the maxin is over the confidence thred, turn the column to
        % zero and assign the maxin to 1.
        if maxin>thred
            % set the column to zero
            M(:,index)=zeros(size(M(:,index)));
            % set the max to 1
            M(i,index)=1;
        end
    end
end

