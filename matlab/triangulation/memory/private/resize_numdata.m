function data = resize_numdata(data, n)
% resize numeric 2D data arrays, where the second dimension is specified in
% data already

coder.inline('always');

m = cast(size(data, 1), 'like', n);
if m == 0
    data = m2cNullcopy(zeros(m2cIgnoreRange(n), size(data, 2), 'like', data));
    return;
end

if n ~= m
    buf_ = m2cNullcopy(zeros(m2cIgnoreRange(n), size(data, 2), 'like', data));
    nn = min(n, m);
    for i = 1:nn
        for j = 1:int32(size(data, 2))
            buf_(i, j) = data(i, j);
        end
    end
    data = buf_;
end

m2cNowarnBuf('data')
end
