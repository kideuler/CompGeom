function data = resize_numdata1(data, n)
% resize numeric data for 1D arrays

coder.inline('always');

m = cast(size(data, 1), 'like', n);
if m == 0 || (m ~= n && ~coder.target('MATLAB'))
    data = m2cNullcopy(zeros(m2cIgnoreRange(n), 1, 'like', data));
elseif coder.target('MATLAB')
    if n < m
        data = data(1:n);
    else
        data = [data; zeros(m2cIgnoreRange(n - m), 1, 'like', data)];
    end
end

end
