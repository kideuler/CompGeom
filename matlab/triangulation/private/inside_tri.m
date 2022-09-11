function bool = inside_tri(mesh,tri,n)
xs_ = mesh.coords(mesh.elemtables(1).conn(tri,1:3),1:2);
v0 = xs_(1,1:2);
v1 = xs_(2,1:2) - xs_(1,1:2);
v2 = xs_(3,1:2) - xs_(1,1:2);
a = (detv(mesh.coords(n,1:2),v2) - detv(v0,v2))/detv(v1,v2);
b = -(detv(mesh.coords(n,1:2),v1) - detv(v0,v1))/detv(v1,v2);
bool = a>0 && b>0 && a+b < 1;
end

function d = detv(u,v)
coder.inline('always')
d = u(1)*v(2) - u(2)*v(1);
end