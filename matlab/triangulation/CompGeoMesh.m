function mesh = CompGeoMesh(geom_ndims)
%CompGeoMesh - Mesh structure for CompGeolib
%
%   CompGeoMesh()  returns a declaration of CompGeoMesh for Coder
%   mesh = CompGeoMesh(geom_ndims)
%
%
% Parameter
% ---------
%   geom_ndims:  Geometric dimension (1,2,3) of the mesh.
%
% Attributes
% ----------
%   coords:         Physical coordinates
%   elemtables:     Array of `ElemData` in case we need meshes with mixed etypes
%   teids:          Unique global tuple element IDs for all elements in `elemtables`
%   facetsets:      Facet entity sets
%   elemparts:      A recursive partitioning structure for OpenMP
%   sibhfs:  AHF data structure
%   bwork1:         Work buffer for Dirichlet nodes
%
% Notes
% -----
% As to the element IDs, there are three ways to represent them in CompGeoMesh:
%
%   1. First, all elements have unique global element IDs ranging from one
%   to the last one.
%   2. A tuple of (conntableidx,leid), where `conntableidx` is the index to
%   the element connectivity tables, i.e., `elemtables`, and `leid` is the local
%   element IDs in that table, ranging from one to the last one in the
%   table. This tuple is given implicitly in that we don't store them.
%   3. Encoded global tuple element ID teids, which are stored explicitly
%   in the array `teids` with 64-bit integer. we use the lowest eight bits to
%   indicate `conntableidx`. Hence, there are 255 (or 256 with 0-based) total
%   number of element types allowed. The rest 56 bits are used for the indices
%   for each `conn` in `elemtables`, i.e., `leid`.
%
% In general, one can easily obtain the global IDs, i.e., geids, which can
% be used in `teids` array to obtain the encoded tuple element IDs, which
% can then be used to decode the explicit tuple indices using some utility
% routines in `CompGeomeshutils`. Therefore, for element IDs used in entity
% sets, node-to-element adjacency, and recursive partitions, we use the
% global element IDs (1:size(teids,1)).
%
% See also CompGeomesh_create, NodeSet, ElementSet, FacetSet, EdgeSet, isCompGeoMesh

if nargin == 0
    mesh = struct( ...
        'coords', coder.typeof(0, [inf 3], [1 1]), ...
        'elemtables', coder.typeof(ConnData, [inf 1]), ...
        'ntris', int32(0), ...
        'facets', coder.typeof(int32(0), [inf 3], [1 1]), ...
        'badtris', coder.typeof(int32(0), [inf 1]), ...
        'vedge', coder.typeof(int32(0), [inf 1]), ...
        'facetsets', coder.typeof(FacetSet, [inf 1]), ...
        'sibhfs', coder.typeof(int32(0), [inf 6], [1 1]), ...
        'delete', coder.typeof(false, [inf 1]), ...
        'bwork1', coder.typeof(false, [inf 1]), ...
        'on_boundary', coder.typeof(false, [inf 1]));
    if nargout < 2
        mesh = coder.cstructname(mesh, 'CompGeoMesh');
    end
else
    coder.inline('always');
    m2cAssert(geom_ndims >= 1 && geom_ndims <= 3, ...
        'Geometric dimension must be between 1 and 3.');
    mesh.('coords') = m2cNullcopy(zeros(m2cZero, m2cIgnoreRange(geom_ndims)));
    mesh.('elemtables') = m2cNullcopy(repmat(ConnData(0), m2cZero, 1));
    mesh.('ntris') = m2cZero;
    mesh.('facets') = m2cNullcopy(zeros(m2cZero, m2cIgnoreRange(geom_ndims), 'int32'));
    mesh.('badtris') = m2cNullcopy(zeros(m2cZero, 1, 'int32'));
    mesh.('vedge') = m2cNullcopy(zeros(m2cZero, 1, 'int32'));
    mesh.('facetsets') = m2cNullcopy(repmat(FacetSet(char(zeros(1, m2cZero))), m2cZero, 1));
    mesh.('sibhfs') = m2cNullcopy(zeros(m2cZero, m2cIgnoreRange(geom_ndims+1), 'int32'));
    mesh.('delete') = m2cNullcopy(false(m2cZero, 1));
    mesh.('bwork1') = m2cNullcopy(false(m2cZero, 1));
    mesh.('on_boundary') = m2cNullcopy(false(m2cZero, 1));
    if nargout < 2
        coder.cstructname(mesh, 'CompGeoMesh');
    end
    coder.varsize('mesh.coords', [inf 3], [1 1]);
    coder.varsize('mesh.sibhfs', [inf 6], [1 1]);
    coder.varsize('mesh.facets', [inf 3], [1 1]);
end

end
