function mesh = CompGeomesh_resize_coords(mesh, newsize)
%CompGeomesh_resize_coords - Resize the coordinate array
%
%   mesh = CompGeomesh_resize_coords(mesh, newsize)
%
% Parameter
% ---------
%   newsize:        New number of coordinates
%
% Notes
% -----
% The already-set points will be preserved if `newsize` is larger than the
% current size.
%
% See also CompGeomesh_resize_elems

%#codegen -args {CompGeoMesh, int32(0)}

coder.inline('always');

mesh = resize_CompGeomesh_coords(mesh, newsize);

end

function mesh = resize_CompGeomesh_coords(mesh, newsize)

coder.inline('never');

mesh.coords = resize_numdata(mesh.coords, newsize);
mesh.vedge = resize_numdata(mesh.vedge, newsize);
mesh.bwork1 = resize_numdata(mesh.bwork1, newsize);
mesh.facets = resize_numdata(mesh.facets, newsize);
end

function test %#ok<DEFNU>
%!test
%!  data = rand(2);
%!  n = randi(100); if n < 2; n = n+2; end
%!  mesh = CompGeomesh_create(int32(2), int32(n));
%!  mesh.coords(1:2,:) = data;
%!  for i = 1:10
%!      n = randi(100); if n < 2; n = n+2; end
%!      mesh = CompGeomesh_resize_coords(mesh, int32(n));
%!      assert(all(all(mesh.coords(1:2,:)==data)));
%!  end
%
%!test
%!  data = rand(2,1);
%!  n = randi(100); if n < 2; n = n+2; end
%!  mesh = CompGeomesh_create(int32(1), int32(n));
%!  mesh.coords(1:2,:) = data;
%!  for i = 1:10
%!      n = randi(100); if n < 2; n = n+2; end
%!      mesh = CompGeomesh_resize_coords(mesh, int32(n));
%!      assert(all(all(mesh.coords(1:2,:)==data)));
%!  end
end
