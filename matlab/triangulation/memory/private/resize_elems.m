function mesh = resize_elems(mesh, nelemtypes)
%resize_elems - Resize the element type table size
%
%   mesh = sfemesh_resize_elems(mesh, nelemtypes)
%
% Parameters
% ----------
%   mesh:       An already-initialized SfeMesh instance
%   nelemtypes: Number of element table types
%
% Notes
% -----
% Already-set data will be preserved if `nelemtypes` is larger than the
% current size of `mesh.elemtables`

coder.inline('always');

k = cast(size(mesh.elemtables, 1), 'int32');

nelemtypes = m2cIgnoreRange(nelemtypes);

if k == 0
    mesh.elemtables = m2cNullcopy(repmat(ConnData(0), nelemtypes, 1));
elseif k ~= nelemtypes
    if coder.target('MATLAB')
        if k < nelemtypes
            mesh.elemtables = [mesh.elemtables; repmat(ConnData(0), nelemtypes - k, 1)];
        else
            mesh.elemtables = mesh.elemtables(1:nelemtypes);
        end
    else
        mesh.elemtables = m2cNullcopy(repmat(ConnData(0), nelemtypes, 1));
    end
end

% initialize some essential attributes
for i = k + 1:nelemtypes
    mesh.elemtables(i).etype = int32(0);
    mesh.elemtables(i).istart = cast(1, 'like', mesh.elemtables(i).istart);
end

end
