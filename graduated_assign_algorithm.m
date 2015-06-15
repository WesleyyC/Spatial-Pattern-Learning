function [ match_matrix ] = graduated_assign_algorithm( ARG1,ARG2 )
%   GRADUATED_ASSIGN_ALGORITHM is a function that compute the best match
%   matrix with two ARGs

    % set up condition and variable
    % beta is the converging for getting the maximize number
    beta_0 = 0.5;
    beta_f = 10;
    beta_r = 1.075;
    % I control the iteration number for each round
    I_0 = 4;
    I_1 = 30;
    % e control a range
    e_B = 0.5;
    e_C=0.05;    
    % node attriubute compatability weight
    alpha = 1;
    
    % make sure ARG1 is always the smaller graph
    if ARG1.num_nodes>ARG2.num_nodes
        tmp = ARG1;
        ARG1 = ARG2;
        ARG2 = tmp;
    end
    % the size of the real matchin matrix
    A=ARG1.num_nodes;
    I=ARG2.num_nodes;
    real_size = [A,I];
    % the size of the matrix with slacks
    augment_size = max(real_size);
    
    % set up the matrix
    % init a guest m_Head with 1+e
    m_Init = rand(augment_size)*10;
    m_Head = m_Init;
    % initial beta to beta_0
    beta = beta_0;
    
    while beta<beta_f   % do A until beta is less than beta_f
        converge_B = 0; % a flag for terminating process B
        I_B = 0;    % counting the iteration of B
        while ~converge_B && I_B <= I_0 % do B until B is converge or iteration exceeds
            old_B=m_Head;   % get the old matrix
            I_B = I_B+1;    % increment the iteration counting
            % Build the partial derivative matrix Q
            Q = zeros(size(m_Head));
            for a = 1:A
                for i = 1:I
                    % Sum from A and I and get M_bj*c(edge_ab,edge_ij)
                    Q_ai = 0;
                    for b = 1:A
                         for j = 1:I
                             edge1=ARG1.edges{a,b};
                             edge2=ARG2.edges{i,j};
                             % +=M_bj*c(g_ab,g_ij)
                             Q_ai=Q_ai+m_Head(b,j)*edge1.compatibility(edge2);
                         end
                    end
                    % Get the Nodes
                    node1=ARG1.nodes{a};
                    node2=ARG2.nodes{i};
                    % Add the attribute compatibility to Q
                    Q_ai=Q_ai+alpha*node1.compatibility(node2);
                    Q(a,i)=Q_ai;
                end
            end
            
            % Build M
            m_Head=exp(beta*Q);
            
            converge_C = 0; % a flag for terminating process B
            I_C = 0;    % counting the iteration of C
            m_One = zeros(size(m_Head));    % a middleware for doing normalization
            while ~converge_C && I_C <= I_1    % Begin C
                I_C=I_C+1;  % increment C
                old_C=m_Head;   % get the m_Head before processing to determine convergence
                for a = 1:augment_size
                    for i = 1:augment_size
                        % normalization by the row
                        m_One(a,i)=m_Head(a,i)/sum(m_Head(a,:));
                    end
                end
                
                for a = 1:augment_size
                    for i = 1:augment_size
                        % normalization by the column
                        m_Head(a,i)=m_One(a,i)/sum(m_One(:,i));
                    end
                end
                % check convergence
                converge_C = converge(m_Head,old_C,e_C);
            end
            % check convergence
            converge_B = converge(m_Head(1:A,1:I),old_B(1:A,1:I),e_B);
        end
        % increment beta
        beta=beta_r*beta;
    end
    
    % get the match_matrix in real size
    match_matrix = heuristic(m_Head,A,I);

end

