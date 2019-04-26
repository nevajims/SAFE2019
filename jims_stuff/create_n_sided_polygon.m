function [nodes_,edge_] = create_n_sided_polygon(inner_pcd , thickness , no_vertices , no_points_between_vertices)

no_vertices = no_vertices+1;
% no_points_between_vertices -  these are in a straing line between each
% vertices
angle_ = linspace(0, 2 * pi, no_vertices);
angle_  = angle_(1:end - 1)';
inner_vertex_nodes  = [cos(angle_), sin(angle_)] * inner_pcd/2               ;
outer_vertex_nodes  = [cos(angle_), sin(angle_)] * (inner_pcd/2+thickness)   ;
inner_nodes = put_points_between(inner_vertex_nodes,no_points_between_vertices);
outer_nodes = put_points_between(outer_vertex_nodes,no_points_between_vertices);
nodes_ =  [ inner_nodes ; outer_nodes ];
n_inner_nodes = size(inner_nodes,1);
n_outer_nodes = size(outer_nodes,1);
c_inner_nodes = [(1:n_inner_nodes-1)', (2:n_inner_nodes)'; n_inner_nodes, 1] ;
c_outer_nodes = [(1:n_outer_nodes-1)', (2:n_outer_nodes)'; n_outer_nodes, 1] ;
edge_ = [c_inner_nodes ; c_outer_nodes + n_inner_nodes ] ;
end

%---------------------------------------------------------
function all_nodes  = put_points_between (vertex_nodes, no_points_between_vertices)
%first allocate the total size of all_nodes
all_nodes = zeros(size(vertex_nodes,1) + size(vertex_nodes,1) * no_points_between_vertices , 2);
current_all_node_index = 0;
for index = 1 : size(vertex_nodes,1) 
current_all_node_index = current_all_node_index +1;
% do x and y seperately
all_nodes (current_all_node_index,:) = vertex_nodes(index,:);    

if index ~= size(vertex_nodes,1) 
cur_x_length = (vertex_nodes(index+1,1)-vertex_nodes(index,1))/(no_points_between_vertices+1);
cur_y_length = (vertex_nodes(index+1,2)-vertex_nodes(index,2))/(no_points_between_vertices+1);
else
cur_x_length = (vertex_nodes(1,1)-vertex_nodes(index,1))/(no_points_between_vertices+1);
cur_y_length = (vertex_nodes(1,2)-vertex_nodes(index,2))/(no_points_between_vertices+1);
end
for index_2 = 1 : no_points_between_vertices 
current_all_node_index = current_all_node_index +1;
all_nodes (current_all_node_index,1) =  vertex_nodes(index,1)+ cur_x_length * index_2;
all_nodes (current_all_node_index,2) =  vertex_nodes(index,2)+ cur_y_length * index_2;
end %for index_2 = 1 : no_points_between_vertices    
end %for index = 1 : length(vertex_nodes)
end %function   put_points_between ()
