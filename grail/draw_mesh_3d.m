function draw_mesh_3D(data_nodes,data_els,nodes_to_plot,els_to_plot,forcing_nodes,monitoring_nodes,numbered_nodes,scale,handle,view_pos,chart_title);
axes(handle);
axis auto;
zoom on;
hold on;
view(view_pos);
plot_nodes=1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
axis equal;
if plot_nodes
   plot3(data_nodes(nodes_to_plot(:),1),data_nodes(nodes_to_plot(:),2),data_nodes(nodes_to_plot(:),3),'b.');
end   
%plot the forcing nodes in red
if forcing_nodes(1)
   plot3(data_nodes(forcing_nodes(:),1),data_nodes(forcing_nodes(:),2),data_nodes(forcing_nodes(:),3),'ro');
end;
%plot the monitoring nodes in green
if monitoring_nodes(1)
   plot3(data_nodes(monitoring_nodes(:),1),data_nodes(monitoring_nodes(:),2),data_nodes(monitoring_nodes(:),3),'go');
end;
%number the nodes
if numbered_nodes(1)
   plot3(data_nodes(numbered_nodes(:),1),data_nodes(numbered_nodes(:),2),data_nodes(numbered_nodes(:),3),'ko');
   for count=1:length(numbered_nodes)
	   text(data_nodes(numbered_nodes(count),1),data_nodes(numbered_nodes(count),2),data_nodes(numbered_nodes(count),3),num2str(numbered_nodes(count)));
   end;
end;
xlabel('X');
ylabel('Y');
zlabel('Z');
title(chart_title);
return;