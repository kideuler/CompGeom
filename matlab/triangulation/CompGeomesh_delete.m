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

ntris = int32(0);
sz2e = int32(size(mesh.elemtables(1).conn,2));
sz2s = int32(size(mesh.sibhfs,2));
idx_ = zeros(mesh.ntris,1,'int32');
for ii = 1:mesh.ntris
    if ~mesh.delete(ii)
        ntris = ntris + 1;
        for jj = 1:sz2e
            mesh.elemtables(1).conn(ntris,jj) = mesh.elemtables(1).conn(ii,jj);
        end
        for jj = 1:sz2s
            mesh.sibhfs(ntris,jj) = mesh.sibhfs(ii,jj);
        end
        mesh.delete(ntris) = false; 
        idx_(ii) = ntris;
    end
end
mesh.ntris = ntris;

for ii = 1:ntris
    for jj = 1:sz2s
        if mesh.sibhfs(ii,jj)
            hfid = mesh.sibhfs(ii,jj);
            eid = sfemesh_hfid2eid(hfid);
            lid = sfemesh_hfid2lid(hfid);
            mesh.sibhfs(ii,jj) = sfemesh_elids2hfid(idx_(eid),lid);
        end
    end
end
end