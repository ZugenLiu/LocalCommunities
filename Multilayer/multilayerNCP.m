function [conductance_con,communities_con,conductance_dis,communities_dis,assoc_mat]=multilayerNCP(A,cut_function,varargin)
% Convenience wrapper around NCP for multiplex networks
%
% Input:
%           A: cell array of adjacency matrices for each layer of the
%           network (all layers need to be the same size)
%
%           cut_function: 'ACL','MOV','EGO' to select algorithm to identify
%           communities
%
%           options:
%                       walktype: 'classical' or 'relaxed'
%
%                       layercoupling: strength of interlayer edges for
%                       'classical' walk or relax rate for 'relaxed' walk
%
%                       teleportation: teleportation rate (useful for
%                       directed networks) for unrecorded link
%                       teleportation
%
%                       + all options for NCP
%
%                       Note about 'local' option for NCP:
%                       nodes can be specified either using the state-node
%                       id (single number form 1:#nodes*#layers) or as a
%                       pair of node id and layer id. If providing to state
%                       indeces make sure they are provided as a column
%                       vector (otherwise it's treated as a node-layer
%                       pair). Node-layer pairs need to be provided as a
%                       nx2 matrix, where each row is a node-layer pair.
%

options=OptionStruct('walktype','classical','layercoupling',1,'teleportation',0);
NCPoptions=OptionStruct('nodes',length(A)*length(A{1}),'local',[],'alpha',[],'truncation',[],...
    'viscount',10,'aggressive',true,'transitionmatrix',false,'stationarydistribution',[],'teleportation',[]);
ncpopts=options.setvalid(varargin);
NCPoptions.set(ncpopts);

N=length(A{1});


switch options.walktype
    case 'classical'
        A=supra_adjacency(A,options.layercoupling);
        if options.teleportation>0
            kin=sum(A,2);
            kout=sum(A,1);
            A=A*diag(kout.^-1);
            p=page_rank(A,options.teleportation,kin);
            NCPoptions.stationarydistribution=p;
            NCPoptions.transitionmatrix=true;
        end
    case 'relaxed'
        P=relax_rate_walk(A);
        A=spblkdiag(A{:});
        kin=sum(A,2);
        A=P(options.layercoupling);
        p=page_rank(A,options.teleportation,kin);
        NCPoptions.stationarydistribution=p;
        NCPoptions.transitionmatrix=true;
end

% convert 'local' option given as nodelayer index to state index
if NCPoptions.isset('local')
    NCPoptions.local=nodelayer2state(N,NCPoptions.local);
end

% Call NCP with appropriate number of outputs for efficiency
switch nargout
    case {0,1}
        [conductance_con]=NCP(A,cut_function,NCPoptions);
    case 2
        [conductance_con,communities_con]=NCP(A,cut_function,NCPoptions);
        communities_con=state2nodelayer(N,communities_con);
    case 3
        [conductance_con,communities_con,conductance_dis]=NCP(A,cut_function,NCPoptions);
        communities_con=state2nodelayer(N,communities_con);
    case 4
        [conductance_con,communities_con,conductance_dis,communities_dis]=NCP(A,cut_function,NCPoptions);
        communities_con=state2nodelayer(N,communities_con);
        communities_dis=state2nodelayer(N,communities_dis);
    case 5
        [conductance_con,communities_con,conductance_dis,communities_dis,assoc_mat]=NCP(A,cut_function,NCPoptions);
        communities_con=state2nodelayer(N,communities_con);
        communities_dis=state2nodelayer(N,communities_dis);
end



    

end


