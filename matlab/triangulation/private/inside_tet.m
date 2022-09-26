function [mesh, bool] = inside_tet(mesh,tet,n)
%% NEEDS REWORK
faces = int32([1,3,2;1,2,4;2,3,4;3,1,4]);
oppn = int32([4;3;1;2]);
C = mesh.coords(n,1:3);
bool = true;
for ii = 1:4
    txs = mesh.coords(mesh.elemtables(1).conn(tet,faces(ii,1:3)),1:3);
    opp = mesh.coords(mesh.elemtables(1).conn(tet,oppn(ii)),1:3);
    bool = bool && on_side(txs,C, opp);
end

end

function bool = on_side(txs,center, opp)
nrm = comp_normal(txs);
v1 = opp - txs(1,1:3);
v2 = center - txs(1,1:3);
bool = sign(v1*nrm') == sign(v2*nrm');
end

function nrm = comp_normal(xs)
v1 = [xs(2, 1) - xs(1, 1), xs(2, 2) - xs(1, 2), xs(2, 3) - xs(1, 3)];
v3 = [xs(1, 1) - xs(3, 1), xs(1, 2) - xs(3, 2), xs(1, 3) - xs(3, 3)];
nrm = [v1(2) * -v3(3) - v1(3) * -v3(2), v1(3) * -v3(1) - v1(1) * -v3(3), v1(1) * -v3(2) - v1(2) * -v3(1)];
end