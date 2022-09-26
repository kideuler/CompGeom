function mesh = CompGeomesh_delaunay_tetrihedrization(xs)
%CompGeomesh_delaunay_triangulation - mesh created using delaunay
%triangulation
%
% Parameter
% ---------
%   xs: 2D coordinates (size nv-by-3)
%
% Returns
% -------
%   mesh: the delaunay triangulation in CompGeoMesh data structure
%
% Notes
% -----
%
% Using Bowyer-Watson method for point insertion of triangulation

%#codegen -args {coder.typeof(0, [inf 3])}

if nargin < 1
    xs = rand(125,3);
    bar = linspace(0,1,5);
    l = 0;
    for i = 1:5
        for j = 1:5
            for k = 1:5
                l=l+1;
                xs(l,1:3) = [bar(i),bar(j),bar(k)];
            end
        end
    end
    xs = rand(20,3);
    xs = [0,0,0;1,0,0;1,1,0;0,1,0;0,0,1;1,0,1;1,1,1;0,1,1];
end
assert(size(xs,2) == 3);

nv = int32(size(xs,1));
upper_bound = nv*nv*nv;
mesh = CompGeomesh_create(int32(3),nv+4,upper_bound);
for i = 1:nv
    for j = int32(1):3
        mesh.coords(i,j) = xs(i,j);
    end
end

% creating super triangle
a = min(xs);
b = max(xs);delta = b-a;
a = a-delta/10;
b = b+delta/10;
delta = b-a;
mesh.coords(nv+1,1) = a(1);
mesh.coords(nv+1,2) = a(2);
mesh.coords(nv+1,3) = a(3);

mesh.coords(nv+2,1) = a(1) + 2*delta(1);
mesh.coords(nv+2,2) = a(2);
mesh.coords(nv+2,3) = a(3);

mesh.coords(nv+3,1) = a(1);
mesh.coords(nv+3,2) = a(2) + 2*delta(2);
mesh.coords(nv+3,3) = a(3);

mesh.coords(nv+4,1) = a(1);
mesh.coords(nv+4,2) = a(2);
mesh.coords(nv+4,3) = a(3) + 2*delta(3);

mesh.elemtables(1).conn(1,1) = nv+1;
mesh.elemtables(1).conn(1,2) = nv+2;
mesh.elemtables(1).conn(1,3) = nv+3;
mesh.elemtables(1).conn(1,4) = nv+4;
mesh.sibhfs(1,1) = 0;
mesh.sibhfs(1,2) = 0;
mesh.sibhfs(1,3) = 0;
mesh.sibhfs(1,4) = 0;
mesh.nelems = int32(1);

tet = int32(0);
for n = 1:nv
    for ii = 1:mesh.nelems
        if ~mesh.delete(ii)
            [mesh, bool] = inside_tet(mesh,ii,n);
            if bool
                tet = ii;
                break;
            end
        end
    end

    % bowyer watson insertion
    mesh = CompGeomesh_BowyerWatson_insert_3d(mesh, n, tet);
end

for ii = 1:mesh.nelems
    if ~mesh.delete(ii)
        for jj = int32(1):4
            if mesh.elemtables(1).conn(ii,jj) > nv
                mesh.delete(ii) = true;
                for kk = int32(1):4
                    hfid = mesh.sibhfs(ii,kk);
                    eid = sfemesh_hfid2eid(hfid);
                    lid = sfemesh_hfid2lid(hfid);
                    if eid~=0 && lid~=0
                        mesh.sibhfs(eid,lid) = 0;
                    end
                end
                break;
            end
        end
    end
end
mesh = CompGeomesh_resize_coords(mesh, nv);

mesh = CompGeomesh_delete(mesh);
draw_delaunay_mesh3d(mesh)
end