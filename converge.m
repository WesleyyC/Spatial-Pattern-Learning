function [ tf ] = converge( M1,M2,e )
%   CONVERGE is a function checking if a matrix is a doubly stochastic
%   matrix

    diff = 0;
    matrix_size = size(M1);
    A=matrix_size(1);
    I=matrix_size(2);
    
    for a=1:A
        for i=1:I
            diff = diff+abs(M1(a,i)-M2(a,i));
        end
    end
    
    tf = diff<e;

end

