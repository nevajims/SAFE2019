function cross_section_node_list=find_cross_section_nodes(data_nodes,specified_location,coord,tolerance)
no_nodes=size(data_nodes,1);
location_is=ones([no_nodes,1]);
cross_section_node_list=0;
for count=1:no_nodes
    if (data_nodes(count,coord)<(specified_location-tolerance)) | ...
            (data_nodes(count,coord)>(specified_location+tolerance));
        location_is(count)=0;
    end;
    if location_is(count)
        if cross_section_node_list(1)==0
            cross_section_node_list(1)=count;
        else
            cross_section_node_list=[cross_section_node_list,count];
        end;
    end;   
end;
