 function [ M ] = heuristic( M, A, I )
%   HEURISTIC is a function that will make a matrix into a permuation
%   matrix according to some rules.

%   In this version, the cleanM will make the largest number in each row 1
%   and the others to 0.

    % get the right size
    M=M(1:A,1:I);
    
     % clean up
    for i = 1:A
        % get the index
        [~,index] = max(M(i,:));
        % set the row to zero
        M(i,:)=zeros(size(M(i,:)));
        M(:,index)=zeros(size(M(:,index)));
        % set the max to 1
        M(i,index)=1;
    end
    
    % normalize to row
    s=sum(M,2);
    n=repmat(s,1,I);
    M=M./n;

end

