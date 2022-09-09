function mesh = CompGeomesh_create(geom_ndims, n, upper_bound)
%CompGeomesh_create - Create an CompGeoMesh instance
%
%   mesh = CompGeomesh_create(geom_ndims)
%   mesh = CompGeomesh_create(geom_ndims, n, upper_bound)
%
% Parameters
% ----------
%   geom_ndims: Geometric dimension of the mesh
%   n:          Number of coordinates
%   upper_bound: size of number of elements. must be large enough to
%   contain buffers
%
% Return
% ------
%   mesh:       An instance of `CompGeoMesh`
%
% Notes
% -----
% Note that `n` is optional, i.e., the coordinate array can be resized later
% after calling CompGeomesh_create
%
% See also CompGeoMesh, CompGeomesh_resize_coords, CompGeomesh_append_econntable,
%          CompGeomesh_append_entset

%#codegen -args {int32(0), int32(0), int32(0)}
%#codegen -args {int32(0), int32(0)}
%#codegen -args {int32(0)}

coder.inline('always');

if nargin < 3; upper_bound = int32(0); end
if nargin < 2; n = int32(0); end

mesh = CompGeoMesh(geom_ndims);
mesh = CompGeomesh_resize_coords(mesh, n);
if geom_ndims == 2
    mesh = sfemesh_append_econntable(mesh, SFE_TRI_3);
else
    assert(geom_ndims == 3);
    mesh = sfemesh_append_econntable(mesh, SFE_TET_4);
end
mesh = CompGeomesh_resize_econn(mesh, int32(1), upper_bound);

for ii = 1:upper_bound
    mesh.delete(ii) = false;
end
end