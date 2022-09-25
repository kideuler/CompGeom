function bool = inside_tet(mesh,tet,n)
%% NEEDS REWORK
xs_ = mesh.coords(mesh.elemtables(1).conn(tet,1:4),1:3);
[~,leid] = obtain_facets(SFE_TET_4,int8(1));
n1 = comp_normal(xs_(leid,1:3));
[~,leid] = obtain_facets(SFE_TET_4,int8(2));
n2 = comp_normal(xs_(leid,1:3));
[~,leid] = obtain_facets(SFE_TET_4,int8(3));
n3 = comp_normal(xs_(leid,1:3));
[~,leid] = obtain_facets(SFE_TET_4,int8(4));
n4 = comp_normal(xs_(leid,1:3));

b1 = (mesh.coords(n,1:3) - xs_(1,1:3))*n1';
b2 = (mesh.coords(n,1:3) - xs_(1,1:3))*n2';
b3 = (mesh.coords(n,1:3) - xs_(2,1:3))*n3';
b4 = (mesh.coords(n,1:3) - xs_(1,1:3))*n4';

bool = b1 < 0 || b2 < 0 || b3 < 0 || b4 < 0;
end

function nrm = comp_normal(xs)
v1 = [xs(2, 1) - xs(1, 1), xs(2, 2) - xs(1, 2), xs(2, 3) - xs(1, 3)];
v3 = [xs(1, 1) - xs(3, 1), xs(1, 2) - xs(3, 2), xs(1, 3) - xs(3, 3)];
nrm = [v1(2) * -v3(3) - v1(3) * -v3(2), v1(3) * -v3(1) - v1(1) * -v3(3), v1(1) * -v3(2) - v1(2) * -v3(1)];
end