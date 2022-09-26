function draw_delaunay_mesh3d(mesh)
figure;
hold on
edges = int32([1,2;2,3;3,1;1,4;2,4;3,4]);
faces = int32([1,3,2;1,2,4;2,3,4;3,1,4]);
scatter3(mesh.coords(:,1),mesh.coords(:,2),mesh.coords(:,3),10,'b')
for i = 1:mesh.nelems
    if ~mesh.delete(i) && ~mesh.on_boundary(i)
        for j = int32(1):6
        line([mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),1),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),1)], ...
            [mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),2),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),2)],...
            [mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),3),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),3)],'Color','k');
        end
    end
end

for i = 1:mesh.nelems
    if ~mesh.delete(i)
        C = (mesh.coords(mesh.elemtables(1).conn(i,1),1:3) + ...
        mesh.coords(mesh.elemtables(1).conn(i,2),1:3) + ...
        mesh.coords(mesh.elemtables(1).conn(i,3),1:3) + ...
        mesh.coords(mesh.elemtables(1).conn(i,4),1:3))./4;
        scatter3(C(1),C(2),C(3),'r')
        for j = 1:4
            if mesh.sibhfs(i,j)
                mid = (mesh.coords(mesh.elemtables(1).conn(i,faces(j,1)),:) + mesh.coords(mesh.elemtables(1).conn(i,faces(j,2)),:) + ...
                    mesh.coords(mesh.elemtables(1).conn(i,faces(j,3)),:))./3;
                
                line([mid(1),C(1)],[mid(2), C(2)],[mid(3), C(3)],'Color','r','Linestyle',':');
            end
        end
    end
end

view(45,45);
end