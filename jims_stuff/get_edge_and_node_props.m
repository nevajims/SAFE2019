function edge_and_node_props   =   get_edge_and_node_props(mesh,do_plot)

% ordered inside nodes-  the nodes appear to be duplicated
 
element_nodes    =  mesh.el.nds;
nodes_           =  mesh.nd.pos;

edge_list = get_edge_list(element_nodes);
[outside_edge_list , inside_edge_list] = get_inside_and_outside_edges(edge_list,element_nodes);
[ordered_outside_edge , ordered_outside_nodes] = order_outside_edge(outside_edge_list , nodes_);

edge_and_node_props.edge_list         =  edge_list       ; 
edge_and_node_props.outside_edge_list = outside_edge_list;
edge_and_node_props.inside_edge_list = inside_edge_list; 
edge_and_node_props.ordered_outside_edge = ordered_outside_edge; 
edge_and_node_props.ordered_outside_nodes = ordered_outside_nodes; 
edge_and_node_props.mesh_coa  = round(mean(nodes_)*1E3)/1E3     ; 
edge_and_node_props.ordered_outside_node_co_ord = nodes_(edge_and_node_props.ordered_outside_nodes,:);

plot_edge_properties(edge_and_node_props,do_plot);

end %function
%-------------------------------------------------------------------------------------------------------
%-------------------------------------------------------------------------------------------------------

function edge_list = get_edge_list(element_nodes)
edge_list        =  zeros(size(element_nodes,1)*size(element_nodes,2),2); 

for index = 1 : size(element_nodes,1)
for edge_index = 1:size(element_nodes,2)    
    
if  edge_index ~= size(element_nodes,2)    
temp_edge = [element_nodes(index,edge_index),element_nodes(index,edge_index+1)];
else
temp_edge = [element_nodes(index,edge_index),element_nodes(index,1)];    
end
edge_list((index-1)*size(element_nodes,2)+edge_index,:) = temp_edge ;  

end %for edge_index = 1:size(element_nodes,1)    
end %for index = 1 : size(element_nodes,2)
end %function edge_list = get_edge_list(element_nodes)


function [outside_edge_list,inside_edge_list] = get_inside_and_outside_edges(edge_list,element_nodes)
edge_list_c = [ edge_list(:,1)+ 1i*edge_list(:,2)];
edge_list_c_reversed = [ edge_list(:,2)+ 1i*edge_list(:,1)];
inside_edge_list = zeros(size(element_nodes,1)*size(element_nodes,2),2) ;
inside_edge_counter = 0;
outside_edge_list = zeros(size(element_nodes,1)*size(element_nodes,2),2) ;
outside_edge_counter = 0;

for index = 1: size(edge_list_c,1)
%length(find (edge_list_c_reversed == edge_list_c(index)))

if length(find (edge_list_c_reversed == edge_list_c(index)))==1  % its either 1 or 0
inside_edge_counter = inside_edge_counter   + 1 ;
inside_edge_list(inside_edge_counter,:)     = [real(edge_list_c(index)),imag(edge_list_c(index))];
% its an inside edge
else    
% its an outside edge
outside_edge_counter = outside_edge_counter + 1 ;
outside_edge_list(outside_edge_counter,:)   = [real(edge_list_c(index)),imag(edge_list_c(index))];
end %if length(find (edge_list_c_reversed == edge_list_c(index)))==1    
end %for index = 1 size(edge_list_c,1)

outside_edge_list = outside_edge_list(find(outside_edge_list(:,1)~=0),:);  % remove extra zeros
inside_edge_list = inside_edge_list(find(inside_edge_list(:,1)~=0),:);     % remove extra zeros
end %function [outside_edge_list,inside_edge_list] = get_inside_and_outside_edges(edge_list);



%--------------------------------------------------------------------------------------
function [ordered_outside_edge,ordered_outside_nodes] = order_outside_edge(outside_edge_list , nodes_)
% need a list of the nodes in the outide edge and their positions
% find (edge_props.ordered_outside_edge(:,1)==edge_props.ordered_outside_edge(1,1))
% why is it going round twice?

outside_node_indices   =  outside_edge_list(:,1);
outside_node_positions =  nodes_(outside_node_indices,:);
%  work out the starting node as minimum x and mean y

min_x  = min (outside_node_positions(:,1));
mean_y = mean(outside_node_positions(:,2));

% subtract these from the node positions and then find the min of the sum and x and y
nodes_temp_2 = abs([outside_node_positions(:,1)-min_x + outside_node_positions(:,2)-mean_y]); 

[junk , first_node_index] =  min(nodes_temp_2);
ordered_outside_edge = zeros(size(outside_edge_list));
old_edge =    outside_edge_list(find(outside_edge_list(:,1) == outside_node_indices(first_node_index)),:);
ordered_outside_edge(1,:) = old_edge;

for index = 2:size(ordered_outside_edge,1)
new_edge = outside_edge_list(find(outside_edge_list(:,1)==old_edge(2)),:);    
ordered_outside_edge(index,:) = new_edge;
old_edge = new_edge;
    
end %for index = 2:size(ordered_outside_edge,1)    
ordered_outside_nodes = ordered_outside_edge(:,1);
end %function [order_outside_edge,order_outside_nodes] = order_outside_edge(outside_edge_list)
%--------------------------------------------------------------------------------------




function plot_edge_properties(edge_and_node_props,do_plot);

if do_plot ==1
outside_n = [edge_and_node_props.ordered_outside_node_co_ord ; edge_and_node_props.ordered_outside_node_co_ord(1,:)]; % complete the loop
figure
axis equal 
hold on
plot(outside_n(:,1),outside_n(:,2),'-')
plot(outside_n(:,1),outside_n(:,2),'c.','markersize', 5)

plot(outside_n(1,1),outside_n(1,2),'rx','markersize', 20)                                   % first node in order
plot(outside_n(3,1),outside_n(3,2),'gx','markersize', 20)                                   % Third node in order (to give direction of rotation)

plot(edge_and_node_props.mesh_coa(1),edge_and_node_props.mesh_coa(2),'r+','markersize', 20) % mesh COA

legend('Lines through nodes','Node points','First node','Third Node','Mesh COA','location','EastOutside')
end %if do_plot ==1
end %function plot_edge_properties(edge_and_node_props,do_plot);

