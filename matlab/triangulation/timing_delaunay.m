
szs = 100:50:2000;
nn = length(szs);
ts = zeros(1,nn);
for i = 1:nn
    for j = 1:5
        tic;
        CompGeomesh_delaunay_triangulation(rand(szs(i),2));
        t = toc;
        ts(i) = ts(i) + t;
    end
    ts(i) = ts(i)/5;
end

plot(szs,(ts))
conv = log2(ts(nn)/ts(2)) / log2(szs(nn)/szs(2))