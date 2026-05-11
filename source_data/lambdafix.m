function [bcheck, acheck, Qzhat, Qbcheck, bfixed, afixed] = lambdafix(bhat, ahat, Qbb, Qahat, Qba)

% SYNTAX:
%   [bcheck, acheck, Qzhat, Qbcheck, bfixed, afixed] = lambdafix(bhat, ahat, Qbb, Qahat, Qba)
%
% INPUT:
%   bhat  = position coordinates (float solution)
%   ahat  = ambiguities (float solution)
%   Qbb   = VCV-matrix (position block)
%   Qahat = VCV-matrix (ambiguity block)
%   Qba   = VCV-matrix (position-ambiguity covariance block)
%
% OUTPUT:
%   bcheck  = output baseline (fixed or float depending on method and ratio test)
%   acheck  = output ambiguities (fixed or float depending on method and ratio test)
%   Qzhat   = variance-covariance matrix of decorrelated ambiguities
%   Qbcheck = variance-covariance matrix of the baseline
%   bfixed  = output baseline (fixed or float depending on method)
%   afixed  = output ambiguities (fixed or float depending on method)
%
% DESCRIPTION:
%   A wrapper for LAMBDA function to be used in Breva.

%  Software version 1.0.1
%-------------------------------------------------------------------------------
%  Copyright (C) 2024 Geomatics Research & Development srl (GReD)
%  Written by:       Andrea Nardo
%  Contributors:     Eugenio Realini and Hendy F. Suhandri
%
%  The licence of this file can be found in source/licence.md
%-------------------------------------------------------------------------------

global ratiotest mutest succ_rate fixed_solution IAR_method P0 mu flag_auto_mu flag_default_P0

Qbcheck=[];

if (flag_auto_mu)
    mu = [];
end

if (flag_default_P0)
    if (IAR_method == 5)
        P0 = 0.995;
    else
        P0 = 0.001;
    end
end

try
    bfixed = [];
    % perform ambiguity resolution
    if (IAR_method == 0)
        %ILS enumeration (LAMBDA2)
        [U] = chol(Qahat); %compute cholesky decomposition
        Qahat = U'*U; %find back the vcm, now the off diag. comp. are identical
        [afixed,sqnorm,Qzhat,Z,D,L] = lambda_routine2(ahat,Qahat);
        % compute the fixed solution
        bcheck = bhat - Qba*cholinv(Qahat)*(ahat-afixed(:,1));
        Qbcheck = Qbb  - Qba*cholinv(Qahat)*Qba';
        acheck = afixed(:,1);
        % success rate
        Ps = prod(2*normcdf(0.5./sqrt(D))-1);
        %[up_bound, lo_bound] = success_rate(D,L,zeros(length(D)));

    elseif (IAR_method == 1 || IAR_method == 2)
        % ILS shrinking, method 1
        % ILS enumeration, method 2
        [afixed,sqnorm,Ps,Qzhat,Z]=LAMBDA(ahat,Qahat,IAR_method,'P0',P0,'mu',mu);
        % compute the fixed solution
        bfixed = repmat(bhat, 1, size(afixed, 2)) - Qba*cholinv(Qahat) * (repmat(ahat, 1, size(afixed, 2)) - afixed);
        bcheck = bfixed(:,1);
        acheck = afixed(:,1);
        Qbcheck = Qbb  - Qba*cholinv(Qahat)*Qba';

    elseif (IAR_method == 3 || IAR_method == 4)
        % Integer rounding, method 3
        % Integer bootstrapping, method 4
        [afixed,sqnorm,Ps,Qzhat,Z]=LAMBDA(ahat,Qahat,IAR_method,'P0',P0,'mu',mu);
        % compute the fixed solution
        bcheck = bhat - Qba*cholinv(Qahat)*(ahat-afixed(:,1));
        acheck = afixed(:,1);
        Qbcheck = Qbb  - Qba*cholinv(Qahat)*Qba';

    elseif (IAR_method == 5)
        % Partial Ambiguity Resolution, method 5
        %[afixed,sqnorm,Ps,Qahat,Z,nfx]=LAMBDA(ahat,Qahat,IAR_method,'P0',P0,'mu',mu);
        [afixed,sqnorm,Ps,Qzhat,Z,nfx]=LAMBDA(ahat,Qahat,IAR_method,'P0',P0,'mu',mu);
        %nfx = size(afixed, 1);
        %Z   = Z(:, 1:nfx);
        % in case of PAR afixed contains the decorrelated ambiguities
        if (nfx > 0)
            Qbz = Qba*Z;

            try
                %bcheck = bhat - Qbz *cholinv(Z'*Qahat*Z) * (Z'*ahat-afixed(:,1));
                bcheck = bhat - Qba *cholinv(Qahat) * (ahat-afixed(:,1));
                bfixed = repmat(bhat, 1, size(afixed, 2)) - Qba*cholinv(Qahat) * (repmat(ahat, 1, size(afixed, 2)) - afixed);
                bcheck = bfixed(:,1);
                acheck = afixed(:,1);
                Qbcheck = Qbb  - Qba*cholinv(Qahat)*Qba';
            catch ME
                disp('Problems in PAR (lambdafix.m)');
                % anyway we store the float ambiguities and their vcv-matrix... (to be improved)
                acheck = ahat;
                Qzhat = Qahat;
            end

        else
            % keep float solution
            bcheck = bhat;
            acheck = ahat;
            Qzhat = Qahat;
        end
    end
catch
    % keep float solution
    bcheck = bhat;
    acheck = ahat;
    Qzhat = Qahat;

    fixed_solution = [fixed_solution 0];
    ratiotest = [ratiotest NaN];
    mutest    = [mutest NaN];
    succ_rate = [succ_rate NaN];

    return
end

if isempty(bfixed)
    bfixed = bcheck;
end

% If IAR_method = 0 or IAR_method = 1 or IAR_method = 2 perform ambiguity validation through ratio test
if (IAR_method == 0 || IAR_method == 1 || IAR_method == 2)

    if (flag_auto_mu)
        if (1-Ps > P0)
            mu = ratioinv(P0,1-Ps,length(acheck));
        else
            mu = 1;
        end
    end

    ratio = sqnorm(1)/sqnorm(2);

    if ratio > mu
        % rejection; keep float baseline solution
        bcheck = bhat;
        acheck = ahat;

        fixed_solution = [fixed_solution 0];
    else
        fixed_solution = [fixed_solution 1];
    end

    ratiotest = [ratiotest ratio];
    mutest    = [mutest mu];

elseif (IAR_method == 5)
    if (nfx > 0)
        fixed_solution = [fixed_solution 1];
    else
        fixed_solution = [fixed_solution 0];
    end
else
    ratiotest = [ratiotest NaN];
    mutest    = [mutest NaN];

    fixed_solution = [fixed_solution 0];
end

succ_rate = [succ_rate Ps];