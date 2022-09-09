function data = resize_numdata2(data, m, n)
% resize numeric 2D data arrays

coder.inline('always');

m_old = cast(size(data, 1), 'like', m);
n_old = cast(size(data, 2), 'like', n);
if m_old == 0 || n_old == 0
    data = m2cNullcopy(zeros(m2cIgnoreRange(m), m2cIgnoreRange(n), 'like', data));
    return;
end

if n ~= n_old
    buf_ = m2cNullcopy(zeros(m2cIgnoreRange(m), m2cIgnoreRange(n), 'like', data));
    mm = min(m, m_old);
    nn = min(n, n_old);
    for i = 1:mm
        for j = 1:nn
            buf_(i, j) = data(i, j);
        end
    end
    data = buf_;
end
end
