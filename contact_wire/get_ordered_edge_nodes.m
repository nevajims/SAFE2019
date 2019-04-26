%  get plot a line down the length
%  generate a series of discrete lines along the edge
%  go throgh the forst sheet
%  find the edge nodes in that
%  POGO_mesh_2.nodePos
%  order the edge nodes in a clockwise direction starting from 9 oclock
% next plot lines alon the side f the mesh (starting point)

function mesh_ = get_ordered_edge_nodes(mesh_,do_plot) 

for index = 1 : length (mesh_.nd.pos)
lens(index) =  length(find(mesh_.el.nds == index));
end %for index = 1 : length (mesh_.nd.pos)

edge_node_nos = find (lens <= 4);

for index = 1:length(edge_node_nos)
[elements_temp,~] = find(mesh_.el.nds == edge_node_nos(index));

if length(elements_temp)==2
elements_temp = [elements_temp;NaN;NaN];
end %if length(elements_temp)==2

if length(elements_temp)==3
elements_temp = [elements_temp;NaN];
end %if length(elements_temp)==2

elements_on_node(index,:) = elements_temp'  ;

end %for index = 1:length(mesh_.el.nds)

[~,f_index] = min(mesh_.nd.pos(edge_node_nos))      ;
[~,node_node_index] = min(mesh_.nd.pos(edge_node_nos,1));
first_node = edge_node_nos(node_node_index)                 ;

% find the elements that have a line on the edge
unique_elements_on_edge = unique(elements_on_node(~isnan(elements_on_node)));

% now how to find the first element with lin on the edge
for index = 1 : length(unique_elements_on_edge)
no_nodes_per_element(index) =  length(find( elements_on_node == unique_elements_on_edge(index)));
end %for index = 1 : length(elements_on_edge)

elements_with_line_on_edge  = unique_elements_on_edge(find(no_nodes_per_element ==2))  ;
elements_on_first_node =  elements_on_node(first_node,find(~isnan(elements_on_node(first_node,:))==1));

if length(elements_on_first_node)==3

count_ = 0;    
for index = 1:3
if length(find(elements_with_line_on_edge == elements_on_first_node(index)))
count_ = count_+1;
line_elements_on_first_node(count_) = elements_on_first_node(index);
end %if length(find(elements_with_line_on_edge == elements_on_first_node(index)))
end %for index = 1:3
elseif length(elements_on_first_node) == 2
line_elements_on_first_node = elements_on_first_node;
else
disp('shouldnt get here')    
end

% now find the two connected nodes

[node_nos_1,~] = find(elements_on_node == line_elements_on_first_node(1));
[node_nos_2,~] = find(elements_on_node == line_elements_on_first_node(2));
node_list  = [node_nos_1;node_nos_2];
connected_nodes =  node_list(find(node_list~=first_node ));

[~,second_node_index] = max(mesh_.nd.pos(connected_nodes,2));

second_node = connected_nodes(second_node_index);

ordered_node_list = [first_node;second_node];  
% elements_with_line_on_edge


for index = 3 : length(edge_node_nos)
% find elements inprevios node
prev_element_possibilities =  elements_on_node(ordered_node_list(index-2),:) ;
prev_element_possibilities =  prev_element_possibilities(find(~isnan(prev_element_possibilities)));

%keyboard
next_element_possibilities =  elements_on_node(ordered_node_list(index-1),:) ;
next_element_possibilities =  next_element_possibilities(find(~isnan(next_element_possibilities)));


for index_2 = 1:length(next_element_possibilities)
% must be an edge line element and not a prev element
 
if  ~sum(prev_element_possibilities == next_element_possibilities(index_2))==1  && length (find(elements_with_line_on_edge == next_element_possibilities(index_2))) == 1
[new_node_pos,~] = find(elements_on_node== next_element_possibilities(index_2));    
ordered_node_list(index) =  new_node_pos(find(new_node_pos~=ordered_node_list(index-1)));

end % if  ~sum(prev_element_possibilities == next_element_possibilities(index_2))==1  && length (find(elements_with_line_on_edge == next_element_possibilities(index_2))) == 1

end %for index_2 = 1:length(next_element_possibilities)
end % for index = 3 : length(edge_node_nos)

mesh_.ordered_edge_nodes = edge_node_nos(ordered_node_list)                            ;

if do_plot ==1
% added in the fist node at the end so that the line goes all the way round

plot(  mesh_.nd.pos([mesh_.ordered_edge_nodes,mesh_.ordered_edge_nodes(1)],1)   ,mesh_.nd.pos([mesh_.ordered_edge_nodes,mesh_.ordered_edge_nodes(1)],2)  , 'x-')

hold on
plot(mesh_.nd.pos(first_node,1),mesh_.nd.pos(first_node,2)  ,'rx', 'MarkerSize',15)

axis equal
end % if do_plot ==1

end %function ordered_edge_node = get_mesh_.ordered_edge_nodes(mesh_,do_plot) 

















