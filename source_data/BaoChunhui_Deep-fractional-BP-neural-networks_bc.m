function delta = bc(w, z, delta_next)
    % define the activation function
    f = @(s) 1 ./ (1 + exp(-s)); 
    % define the derivative of activation function
    df = @(s) f(s) .* (1 - f(s)); 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Your code BELOW
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % backward computing (either component or vector form)
    temp = w' * delta_next;
    delta = temp(1:size(z,1),:) .* df(z);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Your code ABOVE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end