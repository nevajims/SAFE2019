% make the COA the centre of the external node list
function [ordered_node_lists, COA] = get_ordered_external_nodes(mesh) 
edge_list            = get_edge_list(mesh.el.nds)    ;  
external_edge_list   =  get_inside_and_outside_edges(edge_list , mesh.el.nds);  
node_lists           =  find_connected_lists(external_edge_list);
ordered_node_lists   =  organise_node_list(node_lists,mesh.nd.pos);
COA = [mean(mesh.nd.pos(ordered_node_lists{1},1)) mean(mesh.nd.pos(ordered_node_lists{1},2))];

end %function results = get_ordered_external_nodes(mesh)

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

function [outside_edge_list] = get_inside_and_outside_edges(edge_list,element_nodes)
edge_list_c = [ edge_list(:,1)+ 1i*edge_list(:,2)];
edge_list_c_reversed = [edge_list(:,2)+ 1i*edge_list(:,1)];
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

function node_list =  find_connected_lists(external_edge_list)
total_node_count = 0;
total_length = length(external_edge_list);
current_external_edge_list = external_edge_list;
linked_edge_counter  =  0;

while total_node_count < total_length && linked_edge_counter <10  % to stop hanging
linked_edge_counter = linked_edge_counter + 1;
back_at_start = 0;
ordered_edge_list_t = zeros(size(current_external_edge_list)); %initialise then remove the zero rows when finished
ordered_edge_counter = 0;
ordered_edge_list_t(1,:) = current_external_edge_list(1,:);
in_index = [];

while back_at_start == 0
ordered_edge_counter = ordered_edge_counter + 1;
next_index_temp = find(current_external_edge_list(:,1) == ordered_edge_list_t(ordered_edge_counter,2));
in_index = [in_index ; next_index_temp];    
total_node_count = total_node_count  +1   ;

if  next_index_temp ~= 1        %should have a single value 
ordered_edge_list_t(ordered_edge_counter + 1,:) = current_external_edge_list(next_index_temp,:);
else    
back_at_start = 1;    
end %if  next_index_temp ~= 1

end %while back_at_start ==0
node_list{linked_edge_counter} = ordered_edge_list_t(find(ordered_edge_list_t(:,1)~=0),1);

current_external_edge_list(in_index,:) = [];  % removed the edges that have been used in this linked edge
end  %while total_node_count <= length(results.external_edge_list)
end %function

function [ordered_node_lists] =  organise_node_list(node_lists,node_pos)
for index = 1:size(node_lists,2)       %-------------------------
cx_list_temp = node_pos(node_lists{index},1) + 1i*node_pos(node_lists{index},2);
cx_list_temp = cx_list_temp - mean(cx_list_temp);
mean_rad(index) = mean(abs(cx_list_temp));
cx_list{index} = cx_list_temp;
end %for index = 1:size(aa,2)          %-------------------------
[~,outside_index] = max(mean_rad);     % this is the outside of the mesh linked node list
%----------------------------------------------------------------
for index = 1: size(cx_list,2)
% create an index    
temp__index  = ones(length(cx_list{index}),1).*(1:1:length(cx_list{index}))'            ; 
temp_pos_ang      = angle(cx_list{index}) +  abs(min(angle(cx_list{index})))            ;
[~,min_in]       = min(temp_pos_ang)                                                    ;
[~,max_in]       = max(temp_pos_ang)                                                    ;
switch (max_in - min_in) 
    case(1)
backwards = 1;        
    case(-1)         
backwards = 0;
    otherwise
if min_in ==1; backwards = 0;else backwards = 1;end;
end %switch (max_in - min_in)
if backwards == 1
temp_pos_ang = flipud(temp_pos_ang)  ;
temp__index = flipud(temp__index)    ;
[~,min_in]       = min(temp_pos_ang) ;  % will be in a diff pos
end %if backwars == 1    
if min_in~=1
node_order    = [temp__index(min_in:length(temp_pos_ang));temp__index(1:min_in-1)];
else
node_order    = [temp__index(min_in:length(temp_pos_ang  ))];
end %if min_in~=1
ordered_node_lists_temp{index} = node_lists{index}(node_order);
end %for index = 1: size(cx_list,2)
%  re-order the lists
ordered_node_lists{1} = ordered_node_lists_temp{outside_index};
counter_ = 1;
for index = 1: size(ordered_node_lists_temp,2)
if index ~= outside_index; counter_ = counter_ + 1 ;ordered_node_lists{counter_}= ordered_node_lists_temp{index};end;
end %for index = 1: size(ordered_node_lists_temp,2)
end %function  