function mesh = CompGeomesh_delete(mesh)
%CompGeomesh_delete - Remove all deleted triangles in triangulation
%
% Parameter
% ---------
%   mesh: CompGeoMesh data structure of triangulation
%
% Returns
% -------
%   mesh: CompGeoMesh data structure pass by reference

%#codegen -args {CompGeoMesh}

nelems = int32(0);
sz2e = int32(size(mesh.elemtables(1).conn,2));
sz2s = int32(size(mesh.sibhfs,2));
idx_ = zeros(mesh.nelems,1,'int32');

for ii = 1:mesh.nelems
    if ~mesh.delete(ii)
        nelems = nelems + 1;
        for jj = 1:sz2e
            mesh.elemtables(1).conn(nelems,jj) = mesh.elemtables(1).conn(ii,jj);
        end
        for jj = 1:sz2s
            mesh.sibhfs(nelems,jj) = mesh.sibhfs(ii,jj);
        end
        mesh.delete(nelems) = false; 
        idx_(ii) = nelems;
    end
end
mesh.nelems = nelems;

for ii = 1:nelems
    nside = int32(0);
    for jj = 1:sz2s
        if mesh.sibhfs(ii,jj)
            hfid = mesh.sibhfs(ii,jj);
            eid = sfemesh_hfid2eid(hfid);
            lid = sfemesh_hfid2lid(hfid);
            mesh.sibhfs(ii,jj) = sfemesh_elids2hfid(idx_(eid),lid);
            nside = nside + 1;
        end
    end
    if nside == sz2s
        mesh.on_boundary(ii) = false;
    else
        mesh.on_boundary(ii) = true;
    end
end

mesh.delete(1:end) = false;
end