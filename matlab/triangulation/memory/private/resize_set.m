function entsets = resize_set(entsets, setype, name, newsize)
% private function to add a new entity set

coder.inline('always');

newsize = m2cIgnoreRange(newsize);

k = cast(size(entsets, 1), 'int32');

if coder.target('MATLAB')
    entsets = [entsets; repmat(setype(name), newsize - k, 1)];
else
    entsets = m2cNullcopy(repmat(setype(name), newsize, 1));
    for i = k + 1:newsize; entsets(i) = setype(name); end
end

end
