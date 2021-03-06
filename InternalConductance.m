function [int_cond]=InternalConductance(W,S)
% Compute internal conductance of communities
%
% Inputs:
%           W: adjacency matrix
%           S: cell array of communities. Each element of the cell array
%               should be a vector of node indeces, giving the nodes in the
%               community. This function also accepts a single community
%               given as a vector.
%
% Outputs:
%           int_cond: array of internal conductance values for the
%               communities. Internal conductance of empty communities is
%               is coded nan.
%
% see also NCP global_cut

% Version: 2.0
% Date: Mon 25 Jul 2016 17:06:57 BST
% Author: Lucas Jeub
% Email: jeub@maths.ox.ac.uk



if ~iscell(S)
    S={S};
end

if ~issparse(W)
    warning('Input adjacency matrix is full, converting to sparse')
    W=sparse(W);
end

int_cond=ones(size(S))*nan; %missing data will be coded nan;

randorder=randperm(length(S(:))); %used for load balancing
S=S(randorder);
parfor i=1:length(S(:))
    if ~isempty(S{i})
    disp(['community size =',num2str(length(S{i}))])
    if length(S{i})==1
        int_cond(i)=1;
    else
    A=W(S{i},S{i});
    
    c=components(A)
    
    if max(c)>1
        disp(['cluster disconnected, LCC = ',num2str(max(c))]);
       int_cond(i)=0;
    else
    
    [~,v]=laplace_eig(A);
    
    cond=sweep_cut(v,A,sum(A,2),inf);
    
    int_cond(i)=min(cond);
    end
    end
    end
end

int_cond(randorder)=int_cond;
end

