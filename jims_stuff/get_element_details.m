function element_details = get_element_details(mesh) 
% specifically for a triangular element 
% mean size of elements edge 
% std size of elements edge 
% number of elements
% number of nodes

edge_and_node_props                 =   get_edge_and_node_props(mesh,0);
edge_list                           = edge_and_node_props.edge_list          ;

element_details.number_of_elements  =   size(mesh.el.nds,1);
element_details.number_of_nodes     =   size(mesh.nd.pos,1);
element_details.number_of_edges     =     size(edge_list,1);

edge_lengths = zeros(1,element_details.number_of_edges);

for edge_index = 1:element_details.number_of_edges
  
edge_lengths(edge_index) = abs(sqrt((mesh.nd.pos(edge_list(edge_index,2),2)-mesh.nd.pos(edge_list(edge_index,1),2))^2+(mesh.nd.pos(edge_list(edge_index,2),1)-mesh.nd.pos(edge_list(edge_index,1),1))^2)) ;
%First node
%x
%mesh.nd.pos(edge_list(edge_index,1),1)   %x1
%y
%mesh.nd.pos(edge_list(edge_index,1),2)   %y1
%2nd node
%x
%mesh.nd.pos(edge_list(edge_index,2),1)    %x2
%y
%mesh.nd.pos(edge_list(edge_index,2),2)    %y2
% for each edge get the length    
% (1 or 2 for x or y) 
end % for edge_index = 1:number_of_edges

element_details.edge_lengths      = edge_lengths;
element_details.mean_edge_length  = mean(edge_lengths);
element_details.std_edge_length   = std(edge_lengths);


end %function element_details = get_element_details(mesh) 