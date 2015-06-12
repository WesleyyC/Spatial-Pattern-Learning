% Testing Sinkhorn's Result

% Set up testing matrix
m_Head=ones(3);
m_Head=m_Head+rand(size(m_Head));

% Terminal flag
converge_C=0;

% Size
augment_size = length(m_Head);

% epsilion
e_C=0.001;

% track iteration
i=0;

m_One = zeros(size(m_Head));

while m_One~=m_Head
    i=i+1;
    m_Previous = m_Head;
    
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


    converge_C = converge(m_Head,m_Previous,e_C);
end

            