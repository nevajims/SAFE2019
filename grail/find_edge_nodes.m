function edge_nodes=find_edge_nodes(data_nodes,data_els)
no_nodes=size(data_nodes,1);
no_nodes_per_element=size(data_els,2);
no_els=size(data_els,1);
%first find all the edge/corner and surface nodes
node_occurances=zeros([no_nodes,1]);
for element_no=1:no_els
   for local_node_no=1:no_nodes_per_element
      node_occurances(data_els(element_no,local_node_no))=node_occurances(data_els(element_no,local_node_no))+1;
   end;
end;
edge_nodes=0;
for node_no=1:no_nodes;
   if node_occurances(node_no)<=3|node_occurances(node_no)==6
      if edge_nodes==0
         edge_nodes=node_no;
      else
         edge_nodes=[edge_nodes,node_no];
      end
   end
end
