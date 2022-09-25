function mesh = CompGeomesh_BowyerWatson_insert_3d(mesh, n, tet_starting)
%CompGeomesh_BowyerWatson_insert_2d - Bowyer-Watson point insertion
%
% Parameter
% ---------
%   mesh: CompGeoMesh data structure of triangulation
%   n:    Point in mesh.coords which is being inserted
%   tet_starting: Starting tet for the bad tet search
%
% Returns
% -------
%   mesh: the delaunay triangulation in CompGeoMesh data structure
%
% Notes
% -----
%
% Using Bowyer-Watson method for point insertion of triangulation

faces = int32([1,3,2;1,2,4;2,3,4;3,1,4]);
nbad = int32(0);
[mesh,nbad] = recurse_tet_find(mesh,tet_starting,nbad,n);

% alg is mostly the same as in 2d major difference lies in the fact that
% the new tets are created from a surface hole which cannot be ordered.
% thus we need an ahf for the surface hole to get ahf for the tetmesh
% (this may be able to be computed dynamically but i am not sure) 
% then insertion looks like:
%   mesh.sibhfs(mesh.nelems,jj) = sfemesh_elids2hfid(tri of opp edge + ntet_b,
% local edge of opp edge + 1);

% finding unique faces in the polygon hole
nfaces = int32(0);
for ii = 1:nbad
    for jj = int32(1):4
        nfaces = nfaces + 1;
        mesh.facets(nfaces,1) = mesh.elemtables(1).conn(mesh.badtris(ii),faces(jj,1));
        mesh.facets(nfaces,2) = mesh.elemtables(1).conn(mesh.badtris(ii),faces(jj,2));
        mesh.facets(nfaces,3) = mesh.elemtables(1).conn(mesh.badtris(ii),faces(jj,3));
        mesh.vedge(nfaces) = mesh.sibhfs(mesh.badtris(ii),jj);
    end
end
[mesh, nfaces, sibedges_] = unique_face_reorder(mesh,nfaces);

% adding new tets from unique tris
ntet_b = mesh.nelems;
for ii = 1:nfaces
    mesh.nelems = mesh.nelems + 1;
    mesh.elemtables(1).conn(mesh.nelems,1) = mesh.facets(ii,1);
    mesh.elemtables(1).conn(mesh.nelems,2) = mesh.facets(ii,2);
    mesh.elemtables(1).conn(mesh.nelems,3) = mesh.facets(ii,3);
    mesh.elemtables(1).conn(mesh.nelems,4) = n;
    mesh.sibhfs(mesh.nelems,1) = mesh.vedge(ii);
    if mesh.vedge(ii)
        hfid = mesh.vedge(ii);
        mesh.sibhfs(sfemesh_hfid2eid(hfid),sfemesh_hfid2lid(hfid)) = ...
            sfemesh_elids2hfid(mesh.nelems,1);
    else
        mesh.on_boundary(mesh.nelems) = true;
    end
    for jj = int32(1):3
        hfid = sibedges_(ii,jj);
        mesh.sibhfs(mesh.nelems,jj+1) = sfemesh_elids2hfid(...
            sfemesh_hfid2eid(hfid)+ntet_b, sfemesh_hfid2lid(hfid)+1);
    end
end

end

function [mesh, nfaces, sibedges] = unique_face_reorder(mesh,nfaces)
nfaces2 = int32(0);
faces2_ = zeros(nfaces,3,'int32');
vedge2_ = zeros(nfaces,1);
mesh.bwork1(1:nfaces) = true;
for ii = 1:nfaces
    if mesh.bwork1(ii)
        for jj = ii+1:nfaces
            if all(sort(mesh.facets(ii,1:3)) == sort(mesh.facets(jj,1:3)))

                mesh.bwork1(ii) = false;
                mesh.bwork1(jj) = false;
                break
            end
        end
    end

    if mesh.bwork1(ii)
        nfaces2 = nfaces2 + 1;
        faces2_(nfaces2,1:3) = mesh.facets(ii,1:3);
        vedge2_(nfaces2) = mesh.vedge(ii);
    end
end

nfaces = nfaces2;
mesh.facets(1:nfaces,1:3) = faces2_(1:nfaces,1:3);
mesh.vedge(1:nfaces) = vedge2_(1:nfaces);

sibedges = zeros(nfaces,3,'int32');
mesh.bwork1(1:nfaces) = false;
% need ahf for surface (using quadratic complexity for now)
edges = int32([1,2;2,3;3,1]);
for ii = 1:nfaces
    for jj = int32(1):3
        if ~sibedges(ii,jj)
            for ii_2 = ii:nfaces
                for jj_2 = int32(1):3
                    if (mesh.facets(ii,edges(jj,1)) == mesh.facets(ii_2,edges(jj_2,1)) && ...
                            mesh.facets(ii,edges(jj,2)) == mesh.facets(ii_2,edges(jj_2,2))) || ...
                            (mesh.facets(ii,edges(jj,1)) == mesh.facets(ii_2,edges(jj_2,2)) && ...
                            mesh.facets(ii,edges(jj,2)) == mesh.facets(ii_2,edges(jj_2,1)))
                        sibedges(ii,jj) = sfemesh_elids2hfid(ii_2,jj_2);
                        sibedges(ii_2,jj_2) = sfemesh_elids2hfid(ii,jj);
                    end
                end
            end
        end
    end
end
end

function [mesh,nbad] = recurse_tet_find(mesh,tet,nbad,n)
xs_ = mesh.coords(mesh.elemtables(1).conn(tet,1:4),1:3);
if inside_circum(xs_,mesh.coords(n,1:3))
    mesh.delete(tet) = true;
    nbad = nbad + 1;
    mesh.badtris(nbad) = tet;
    for ii = int32(1):4
        eid = sfemesh_hfid2eid(mesh.sibhfs(tet,ii));
        if eid && ~mesh.delete(eid)
            [mesh, nbad] = recurse_tet_find(mesh, eid, nbad, n);
        end
    end
else
    if nbad == 0
        1;
    end
    return;
end
end

function bool = inside_circum(ps,center)
coder.inline('always');
A = zeros(3,3);
b = zeros(3,1);
A(1:3,1) = ps(2,1:3)' - ps(1,1:3)';
A(1:3,2) = ps(3,1:3)' - ps(1,1:3)';
A(1:3,3) = ps(4,1:3)' - ps(1,1:3)';
b(1) = 0.5*(ps(2,1:3)*ps(2,1:3)' - ps(1,1:3)*ps(1,1:3)');
b(2) = 0.5*(ps(3,1:3)*ps(3,1:3)' - ps(1,1:3)*ps(1,1:3)');
b(3) = 0.5*(ps(4,1:3)*ps(4,1:3)' - ps(1,1:3)*ps(1,1:3)');
c = (A\b)';
radius = norm(c - ps(1,1:3));
bool  = norm(center - c) < radius;
end


function d = det4(J)
%det3 - Compute determinant of 4x4 matrix.

coder.inline('always');

d = J(1,1)*J(2,2)*J(3,3)*J(4,4) - J(1,1)*J(2,2)*J(3,4)*J(4,3) - J(1,1)*J(2,3)*J(3,2)*J(4,4) +...
    J(1,1)*J(2,3)*J(3,4)*J(4,2) + J(1,1)*J(2,4)*J(3,2)*J(4,3) - J(1,1)*J(2,4)*J(3,3)*J(4,2) - ...
    J(1,2)*J(2,1)*J(3,3)*J(4,4) + J(1,2)*J(2,1)*J(3,4)*J(4,3) + J(1,2)*J(2,3)*J(3,1)*J(4,4) - ...
    J(1,2)*J(2,3)*J(3,4)*J(4,1) - J(1,2)*J(2,4)*J(3,1)*J(4,3) + J(1,2)*J(2,4)*J(3,3)*J(4,1) +...
    J(1,3)*J(2,1)*J(3,2)*J(4,4) - J(1,3)*J(2,1)*J(3,4)*J(4,2) - J(1,3)*J(2,2)*J(3,1)*J(4,4) +...
    J(1,3)*J(2,2)*J(3,4)*J(4,1) + J(1,3)*J(2,4)*J(3,1)*J(4,2) - J(1,3)*J(2,4)*J(3,2)*J(4,1) -...
    J(1,4)*J(2,1)*J(3,2)*J(4,3) + J(1,4)*J(2,1)*J(3,3)*J(4,2) + J(1,4)*J(2,2)*J(3,1)*J(4,3) -...
    J(1,4)*J(2,2)*J(3,3)*J(4,1) - J(1,4)*J(2,3)*J(3,1)*J(4,2) + J(1,4)*J(2,3)*J(3,2)*J(4,1);
end