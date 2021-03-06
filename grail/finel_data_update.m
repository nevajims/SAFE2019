fname='n:\grail\matlab\fe-data\excitability\disk_symmodel.mat';
load(fname);

%calculate nodal mass matrix
mass=zeros(size(data_nodes,1),1);
for count=1:data_no_els
   area=calc_area_quad(...
      data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),...
      data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),...
      data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),...
      data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2)...
      );
   for node_count=1:4;
      mass(data_els(count,node_count),1)=mass(data_els(count,node_count),1)+area/4;
   end;
end;

%calculate power flow for each point and normalise displacements - excitability is then disp^2*freq
for count=1:size(data_freq,1);
   %calc power flow
   power_flow=...
      abs((sum((...
   	data_ms_x(:,count).^2+...
      data_ms_y(:,count).^2+...
      data_ms_z(:,count).^2).*...
      mass(:))*...
      data_freq(count) ^ 2 * ...
      abs(data_gr_vel(count))) ^ 0.5);
   %normalise displacements
   data_ms_x(:,count)=data_ms_x(:,count)/power_flow;
   data_ms_y(:,count)=data_ms_y(:,count)/power_flow;
   data_ms_z(:,count)=data_ms_z(:,count)/power_flow;
end;

save(fname,'data_*');
