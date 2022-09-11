function [mesh, Center] = center_circumcircle(mesh,tri)
xs_ = mesh.coords(mesh.elemtables(1).conn(tri,1:3),1:2);
ax = mesh.coords(mesh.elemtables(1).conn(tri,1),1);
ay = mesh.coords(mesh.elemtables(1).conn(tri,1),2);
bx = mesh.coords(mesh.elemtables(1).conn(tri,2),1);
by = mesh.coords(mesh.elemtables(1).conn(tri,2),2);
cx = mesh.coords(mesh.elemtables(1).conn(tri,3),1);
cy = mesh.coords(mesh.elemtables(1).conn(tri,3),2);
D = 2*(ax*(by-cy) + bx*(cy-ay) + cx*(ay-by));
ux = (ax*ax + ay*ay)*(by-cy) + ...
    (bx*bx + by*by)*(cy-ay) + ...
    (cx*cx + cy*cy)*(ay-by);
uy = (ax*ax + ay*ay)*(cx-bx) + ...
    (bx*bx + by*by)*(ax-cx) + ...
    (cx*cx + cy*cy)*(bx-ax);
Center = [ux/D, uy/D];
end