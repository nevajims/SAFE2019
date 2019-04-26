function disp_shape=draw_perim_mode_shape(data_nodes,data_ms_x,data_ms_y,data_ms_z,data_mode_start_indices,data_perimeter_node_list,data_freq,mode_index,freq,scale,fig_no);
figure(fig_no);
%interpolate
start_index=data_mode_start_indices(mode_index);
end_index=data_mode_start_indices(mode_index+1)-1;
while start_index<end_index;
	if min(data_freq(start_index+1:end_index))>data_freq(start_index)
   	break;
	end;
   start_index=start_index+1;
end;

ms_x=interp1(data_freq(start_index:end_index),data_ms_x(:,start_index:end_index)',freq)';
ms_y=interp1(data_freq(start_index:end_index),data_ms_y(:,start_index:end_index)',freq)';
ms_z=interp1(data_freq(start_index:end_index),data_ms_z(:,start_index:end_index)',freq)';
 
disp_shape=[ms_x,ms_y,ms_z]*scale*32;
disp_shape=disp_shape(data_perimeter_node_list,:);

clf;
hold on;
plot(disp_shape(:,1),'r');
plot(disp_shape(:,2),'b');
plot(disp_shape(:,3),'g');
axis([1 size(disp_shape,1) -1 1]);

return;
