function mesh = CompGeomesh_refinement(mesh,h)

if nargin < 1
    n = 20;
    C = @(t) [0.5.*cos(t)+0.5, 0.5.*sin(t)+0.5];
    t = linspace(0,2*pi-(2*pi/n),n)';
    xs = C(t);
    mesh = CompGeomesh_delaunay_triangulation(xs);
    h = 1/sqrt(n)
end

r_ref = (sqrt(3)/3)*h;
upper = int32(size(mesh.elemtables(1).conn,1));
nv = int32(size(mesh.coords,1));
mesh = CompGeomesh_resize_coords(mesh,upper);
alphas_ = zeros(upper,1);
next_ = m2cNullcopy(zeros(upper,1,'int32'));
for ii = 1:mesh.ntris
    if ~mesh.delete(ii)
        [mesh,alphas_(ii)] = eval_alpha(mesh,ii,r_ref);
    end
end

[~,I_] = sort(alphas_(1:mesh.ntris),'descend');
start = int32(I_(1));
curr = start;
for ii = 2:mesh.ntris
    next_(curr) = I_(ii);
    curr = I_(ii);
end

iter = 0;
while max(alphas_(~mesh.delete)) > 1  && iter < 7
    iter = iter + 1;
    ntris = mesh.ntris;
    for ii = 1:ntris
        if ~mesh.delete(ii)
            if alphas_(ii) > 1
                [mesh, Center] = center_circumcircle(mesh,ii);
                mesh.coords(nv+1,:) = Center;
                go = false;
                if inside_tri(mesh,ii,nv+1)
                    go = true;
                else
                    if mesh.on_boundary(ii)
                        go = ;
                    else
                        go = true;
                    end
                end

                if go
                    nv = nv + 1;
                    mesh = CompGeomesh_BowyerWatson_insert_2d(mesh, nv, ii);
                end
            end
        end
    end

    for ii = 1:mesh.ntris
        if ~mesh.delete(ii)
            [mesh,alphas_(ii)] = eval_alpha(mesh,ii,r_ref);
        end
    end

    mesh = CompGeomesh_delete(mesh);
end

mesh = CompGeomesh_resize_coords(mesh,nv);

draw_delaunay_mesh(mesh)
end


function [mesh,alpha] = eval_alpha(mesh,tri,r_ref)
xs_ = mesh.coords(mesh.elemtables(1).conn(tri,1:3),1:2);
a = norm(xs_(2,1:2) - xs_(1,1:2));
b = norm(xs_(3,1:2) - xs_(2,1:2));
c = norm(xs_(3,1:2) - xs_(1,1:2));
s = 0.5*(a+b+c);
A = sqrt(s*(s-a)*(s-b)*(s-c));
r = a*b*c/(4*A);
alpha = r/r_ref;
end