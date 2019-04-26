function disp_shape=draw_mode_shape(data_nodes,data_els,data_ms_x,data_ms_y,data_ms_z,data_mode_start_indices,data_freq,mode_index,freq,scale,handle,view_pos);
axes(handle);
axis auto;
axis equal;
zoom on;
animate=0;
draw_displaced_modeshape=1;
%interpololate
start_index=data_mode_start_indices(mode_index);
end_index=data_mode_start_indices(mode_index+1)-1;
%find the maximum monotonic range of f for the range using wilco's function
[monoton_start_index,monoton_end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
%reset the start and end according to results
end_index=start_index+monoton_end_index-1;
start_index=start_index+monoton_start_index-1;
%do the interpolation

ms_x=interp1(data_freq(start_index:end_index),data_ms_x(:,start_index:end_index)',freq)';
ms_y=interp1(data_freq(start_index:end_index),data_ms_y(:,start_index:end_index)',freq)';
ms_z=interp1(data_freq(start_index:end_index),data_ms_z(:,start_index:end_index)',freq)';

if animate;
   frames=8;
else
   frames=1;
end;
for frame_count=1:frames;
   if animate
      xysc=sin(frame_count/frames*2*pi);
      zsc=cos(frame_count/frames*2*pi);
   else
      xysc=1;
      zsc=1;
   end;
   
      
	disp_shape=data_nodes+[ms_x*xysc,ms_y*xysc,ms_z*zsc]*scale;
	cla;
	hold on;
	view(view_pos);
	axis equal;
	no_data_els=size(data_els,1);
	for count=1:no_data_els;
		temp=[	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3);
   			data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),data_nodes(data_els(count,2),3);
            data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),data_nodes(data_els(count,4),3);
            data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2),data_nodes(data_els(count,3),3);
         	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3)];   
	   plot3(temp(:,1),temp(:,2),temp(:,3),'b');%'b:');
   	temp=[	disp_shape(data_els(count,1),1),disp_shape(data_els(count,1),2),disp_shape(data_els(count,1),3);
   			disp_shape(data_els(count,2),1),disp_shape(data_els(count,2),2),disp_shape(data_els(count,2),3);
            disp_shape(data_els(count,4),1),disp_shape(data_els(count,4),2),disp_shape(data_els(count,4),3);
            disp_shape(data_els(count,3),1),disp_shape(data_els(count,3),2),disp_shape(data_els(count,3),3);
         	disp_shape(data_els(count,1),1),disp_shape(data_els(count,1),2),disp_shape(data_els(count,1),3)];   
	   if draw_displaced_modeshape
           plot3(temp(:,1),temp(:,2),temp(:,3),'r'); %'k');
       end
	end;
   axis equal;
   if frame_count==1;
      axis manual;
   end;
   
	xlabel('X');
	ylabel('Y');
	zlabel('Z');
    %xlabel('');
    %ylabel('');
    %set(handle,'xtick',-1);
    %set(handle,'ytick',-1);
    %axis([5.95 6.2 -0.08 0.08]);
	title(strcat('Mode ',num2str(mode_index),' at ',num2str(freq/1000),' kHz'));
	%title(strcat('Mode ',num2str(mode_index)));
	if animate;
   	m(frame_count)=getframe;
	end;
end;

return;