function [ match_matrix ] = graduated_assign_algorithm( ARG1,ARG2 )
%   GRADUATED_ASSIGN_ALGORITHM is a function that compute the best match
%   matrix with two ARGs

    % set up condition and variable
    beta_0 = 0.5;
    beta_f = 10;
    beta_r = 1.075;
    I_0 = 4;
    I_1 = 30;
    e_B = 0.5;
    e_C=0.05;
    
    real_size = [ARG1.num_nodes,ARG2.num_nodes];
    A=real_size(1);
    I=real_size(2);
    augment_size = max(real_size);
    m_Head = eye(augment_size);
    beta = beta_0;
    
    while beta<beta_f   %Begin A
        converge_B = 0;
        I_B = 0;
        while ~converge_B && I_B <= I_0     % Begin B
            I_B = I_B+1;
            old_matrix_B = m_Head;
            %Qai and Mai
            for a = 1:A
                for i = 1:I
                    % get Qai
                    Q_ai = 0;
                    for b = 1:A
                         for j = 1:I
                             edge1=ARG1.edges{a,b};
                             edge2=ARG2.edges{i,j};
                             Q_ai=Q_ai+m_Head(b,j)*edge1.compatibility(edge2);
                         end
                    end
                    % get Mai
                    m_Head(a,i)=exp(beta*Q_ai);
                end
            end
            converge_C = 0;
            I_C = 0;
            while ~converge_C && I_C <= I_1     % Begin C
                I_C=I_C+1;
                old_matrix_C = m_Head;
                m_One = zeros(size(m_Head));
                for a = 1:augment_size
                    for i = 1:augment_size
                        m_One(a,i)=m_Head(a,i)/sum(m_Head(a,:));
                    end
                end
                
                for a = 1:augment_size
                    for i = 1:augment_size
                        m_Head(a,i)=m_One(a,i)/sum(m_One(:,i));
                    end
                end
%                 m_One = normr(m_Head);
%                 m_Head = normc(m_One);
                
                converge_C = converge(m_Head,old_matrix_C,e_C);
            end
            converge_B = converge(m_Head,old_matrix_B,e_B);
        end
        beta=beta_r*beta;
    end
                
    

    match_matrix = m_Head(1:A,1:I);

end

