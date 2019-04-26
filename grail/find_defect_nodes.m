function defect_node_list=find_defect_nodes(nodes,specified_limits)
no_nodes=size(nodes,1);
location_is=ones([no_nodes,3]);
defect_node_list=0;
for count=1:no_nodes
   for coord=1:3
         if (nodes(count,coord)<=(specified_limits(coord,1))) | ...
               (nodes(count,coord)>=(specified_limits(coord,2)))
	         location_is(count,coord)=0;
	      end;
   end;
   if sum(location_is(count,1).*location_is(count,2).*location_is(count,3))
	    if defect_node_list(1)==0
	       defect_node_list(1)=count;
	    else
	       defect_node_list=[defect_node_list,count];
	    end;
	end;   
end;
%check that all the defect nodes are in the same plane
average_z_coordinate=mean(nodes(defect_node_list(:),3));
for count=1:length(defect_node_list)
    if (nodes(defect_node_list(count),3)-average_z_coordinate)>1e-12
        disp('defect nodes are not on one plane only, the tolerances are too slack');
        break
    end
end