function mesh = CompGeomesh_BowyerWatson_insert_2d(mesh, n, tri_starting)
%CompGeomesh_BowyerWatson_insert_2d - Bowyer-Watson point insertion
%
% Parameter
% ---------
%   mesh: CompGeoMesh data structure of triangulation
%   n:    Point in mesh.coords which is being inserted
%   tri_starting: Starting triangle for the bad triangle search
%
% Returns
% -------
%   mesh: the delaunay triangulation in CompGeoMesh data structure
%
% Notes
% -----
%
% Using Bowyer-Watson method for point insertion of triangulation

%#codegen -args {CompGeoMesh, int32(0), int32(0)}

edges = int32([1,2;2,3;3,1]);
nbad = int32(0);
[mesh,nbad] = recurse_tri_find(mesh,tri_starting,nbad,n);

% finding unique segments in the polygon hole
nsegs = int32(0);
for ii = 1:nbad
    for jj = int32(1):3
        nsegs = nsegs + 1;
        mesh.facets(nsegs,1) = mesh.elemtables(1).conn(mesh.badtris(ii),edges(jj,1));
        mesh.facets(nsegs,2) = mesh.elemtables(1).conn(mesh.badtris(ii),edges(jj,2));
        mesh.vedge(nsegs) = mesh.sibhfs(mesh.badtris(ii),jj);
    end
end
[mesh, nsegs, order_] = unique_edge_reorder(mesh,nsegs); 

% adding the new triangles from unique segments
ntri_b = mesh.ntris;
for ii = 1:nsegs
    mesh.ntris = mesh.ntris + 1;
    mesh.elemtables(1).conn(mesh.ntris,1) = mesh.facets(order_(ii),1);
    mesh.elemtables(1).conn(mesh.ntris,2) = mesh.facets(order_(ii),2);
    mesh.elemtables(1).conn(mesh.ntris,3) = n;
    mesh.sibhfs(mesh.ntris,1) = mesh.vedge(order_(ii));
    if mesh.vedge(order_(ii))
        hfid = mesh.vedge(order_(ii));
        mesh.sibhfs(sfemesh_hfid2eid(hfid),sfemesh_hfid2lid(hfid)) = ...
            sfemesh_elids2hfid(mesh.ntris,1);
    else
        mesh.on_boundary(mesh.ntris) = true;
    end
    mesh.sibhfs(mesh.ntris,2) = sfemesh_elids2hfid(ntri_b + modi(ii,nsegs) + 1,3);
    mesh.sibhfs(mesh.ntris,3) = sfemesh_elids2hfid(ntri_b + modi(ii-2,nsegs) + 1,2);
end

end

function z = modi(a,b)
coder.inline('always')
z = a - b*idivide(a,b);
if z < 0
    z = z + b;
end
end

function [mesh, nsegs, order] = unique_edge_reorder(mesh,nsegs)
nsegs2 = int32(0);
segs2_ = zeros(nsegs,2);
vedge2_ = zeros(nsegs,1);
mesh.bwork1(1:nsegs) = true;
for ii = 1:nsegs
    if mesh.bwork1(ii)
        for jj = ii+1:nsegs
            if (mesh.facets(ii,1) == mesh.facets(jj,1) && ...
                    mesh.facets(ii,2) == mesh.facets(jj,2)) || ...
                (mesh.facets(ii,1) == mesh.facets(jj,2) && ...
                    mesh.facets(ii,2) == mesh.facets(jj,1))

                mesh.bwork1(ii) = false;
                mesh.bwork1(jj) = false;
                break
            end
        end
    end

    if mesh.bwork1(ii)
        nsegs2 = nsegs2 + 1;
        segs2_(nsegs2,1:2) = mesh.facets(ii,1:2);
        vedge2_(nsegs2) = mesh.vedge(ii);
    end
end

nsegs = nsegs2;
mesh.facets(1:nsegs,1:2) = segs2_(1:nsegs,1:2);
mesh.vedge(1:nsegs) = vedge2_(1:nsegs);

order = zeros(nsegs,1,'int32');
mesh.bwork1(1:nsegs) = false;
order(1) = 1;
for ii = 2:nsegs
    vid = mesh.facets(order(ii-1),2);
    for jj = 1:nsegs
        if vid == mesh.facets(jj,1)
            order(ii) = jj;
            break;
        end
    end
end
end

function [mesh,nbad] = recurse_tri_find(mesh,tri,nbad,n)
xs_ = mesh.coords(mesh.elemtables(1).conn(tri,1:3),1:2);
if inside_circum(xs_,mesh.coords(n,1:2))
    mesh.delete(tri) = true;
    nbad = nbad + 1;
    mesh.badtris(nbad) = tri;
    for ii = int32(1):3
        eid = sfemesh_hfid2eid(mesh.sibhfs(tri,ii));
        if eid && ~mesh.delete(eid)
            [mesh, nbad] = recurse_tri_find(mesh, eid, nbad, n);
        end
    end
else
    return;
end
end

function bool = inside_circum(ps,center)
coder.inline('always');
D = zeros(3,3);
D(1:3,1:2) = ps-center;
D(1,3) = (ps(1,1:2)-center)*(ps(1,1:2)-center)';
D(2,3) = (ps(2,1:2)-center)*(ps(2,1:2)-center)';
D(3,3) = (ps(3,1:2)-center)*(ps(3,1:2)-center)';
bool = det3(D) > 0;
end

function d = det3(J)
%det3 - Compute determinant of 3x3 matrix.

coder.inline('always');

d = J(1, 3) * (J(2, 1) * J(3, 2) - J(3, 1) * J(2, 2)) + ...
    J(2, 3) * (J(3, 1) * J(1, 2) - J(1, 1) * J(3, 2)) + ...
    J(3, 3) * (J(1, 1) * J(2, 2) - J(2, 1) * J(1, 2));
end