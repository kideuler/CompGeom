function mesh = CompGeomesh_delaunay_triangulation(xs)
%CompGeomesh_delaunay_triangulation - mesh created using delaunay
%triangulation
%
% Parameter
% ---------
%   xs: 2D coordinates (size nv-by-2)
%
% Returns
% -------
%   mesh: the delaunay triangulation in CompGeoMesh data structure
%
% Notes
% -----
%
% Using Bowyer-Watson method for point insertion of triangulation

%#codegen -args {coder.typeof(0, [inf 2])}

if nargin < 1
    xs = rand(30,2);
end
assert(size(xs,2) == 2);
nv = int32(size(xs,1));
upper_bound = nv*nv*3;
mesh = CompGeomesh_create(int32(2),nv+3,upper_bound);
for i = 1:nv
    for j = int32(1):2
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
mesh.coords(nv+2,1) = a(1) + 2*delta(1);
mesh.coords(nv+2,2) = a(2);
mesh.coords(nv+3,1) = a(1);
mesh.coords(nv+3,2) = a(2) + 2*delta(2);

mesh.elemtables(1).conn(1,1) = nv+1;
mesh.elemtables(1).conn(1,2) = nv+2;
mesh.elemtables(1).conn(1,3) = nv+3;
mesh.sibhfs(1,1) = 0;
mesh.sibhfs(1,2) = 0;
mesh.sibhfs(1,3) = 0;
mesh.nelems = int32(1);


tri = int32(0);
for n = 1:nv
    for ii = 1:mesh.nelems
        if ~mesh.delete(ii)
            if inside_tri(mesh,ii,n)
                tri = ii;
                break;
            end
        end
    end

    mesh = CompGeomesh_BowyerWatson_insert_2d(mesh, n, tri);
end


for ii = 1:mesh.nelems
    if ~mesh.delete(ii)
        for jj = int32(1):3
            if mesh.elemtables(1).conn(ii,jj) > nv
                mesh.delete(ii) = true;
                for kk = int32(1):3
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
end