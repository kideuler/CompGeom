function draw_delaunay_mesh(mesh)
figure;
hold on
edges = int32([1,2;2,3;3,1]);
for i = 1:mesh.ntris
    if ~mesh.delete(i) && ~mesh.on_boundary(i)
        for j = int32(1):3
        line([mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),1),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),1)], ...
            [mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),2),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),2)],'Color','k');
        end
    end
end
for i = 1:mesh.ntris
    if ~mesh.delete(i) && mesh.on_boundary(i)
        for j = int32(1):3
        line([mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),1),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),1)], ...
            [mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),2),mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),2)],'Color','r');
        end
    end
end

for i = 1:mesh.ntris
    if ~mesh.delete(i)
        C = (mesh.coords(mesh.elemtables(1).conn(i,1),1:2) + ...
        mesh.coords(mesh.elemtables(1).conn(i,2),1:2) + ...
        mesh.coords(mesh.elemtables(1).conn(i,3),1:2))./3;
        scatter(C(1),C(2),'r')
        for j = 1:3
            if mesh.sibhfs(i,j)
                mid = (mesh.coords(mesh.elemtables(1).conn(i,edges(j,1)),:) + mesh.coords(mesh.elemtables(1).conn(i,edges(j,2)),:))./2;
                
                line([mid(1),C(1)],[mid(2), C(2)],'Color','r','Linestyle',':');
            end
        end
    end
end
end