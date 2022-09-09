function mesh = CompGeomesh_resize_econn(mesh, conntableidx, n)
%CompGeomesh_resize_conn - Resize the conn data in an element table
%
%   mesh = CompGeomesh_resize_econn(mesh, conntableidx, n)
%
% Parameters
% ----------
%   mesh:           An CompGeoMesh instance
%   conntableidx:   Index to conn tables
%   n:              Size of element table
%
% See also CompGeomesh_append_econntable

%#codegen -args {CompGeoMesh, int32(0), int32(0)}

coder.inline('always');

if mesh.elemtables(conntableidx).etype <= 0 || ...
        size(mesh.elemtables(conntableidx).conn, 2) == 0
    error('CompGeomesh_resize_conn:uninitConn', ...
        'call CompGeomesh_init_conn for %d table first', conntableidx);
end

mesh = resize_CompGeomesh_econn(mesh, coder.ignoreConst(conntableidx), n);

end

function mesh = resize_CompGeomesh_econn(mesh, conntableidx, n)

coder.inline('never');

mesh.elemtables(conntableidx).conn = resize_numdata(mesh.elemtables(conntableidx).conn, n);
mesh.badtris = resize_numdata(mesh.badtris, n);
mesh.delete = resize_numdata(mesh.delete, n);
mesh.sibhfs = resize_numdata(mesh.sibhfs, n);
end