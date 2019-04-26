function matching_node_lookup=find_matching_nodes_xy(node_nos_2d,node_coords_2d,node_nos_3d,node_coords_3d,tolerances)
no_of_nodes=length(node_nos_2d);
if no_of_nodes~=size(node_coords_2d,1)
   disp('Error1, Number of 2D nodes and coordinates do not match')
   return;
end
if length(node_nos_3d)~=size(node_coords_3d,1)
   disp('Error2, Number of 3D nodes and coordinates do not match')
   return;
end
if no_of_nodes~=size(node_coords_3d,1)
   disp('Error3, 2D and 3D node selections do not match')
   %return;
end
matching_node_lookup=zeros([no_of_nodes,2]);
for current_2d_node=1:no_of_nodes
   matching_node_lookup(current_2d_node,1)=node_nos_2d(current_2d_node);
   specified_location=node_coords_2d(current_2d_node,:);
   for current_3d_node=1:no_of_nodes
      if (node_coords_3d(current_3d_node,1)<=(specified_location(1)+tolerances(1))...
         &node_coords_3d(current_3d_node,1)>=(specified_location(1)-tolerances(1)));
         if (node_coords_3d(current_3d_node,2)<=(specified_location(2)+tolerances(2))...
               &node_coords_3d(current_3d_node,2)>=(specified_location(2)-tolerances(2)));
            matching_node_lookup(current_2d_node,2)=node_nos_3d(current_3d_node);
         end;
      end;
   end;
end;

