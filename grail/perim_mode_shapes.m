clear;
close all;
load 'n:\mark\GUL\Rail\matlab\data\rail_fine_mesh\result1';

%put this in a menu
mode_index=8;
freq=17e3;
disp_dir=3;

%plot dispersion curves with mode and frequency point highlighted
%figure;hold on;
no_pts=size(data_freq,1);
for mode_count=1:size(data_mode_start_indices,1);
   start_index=data_mode_start_indices(mode_count);
   if mode_count<size(data_mode_start_indices,1);
      end_index=data_mode_start_indices(mode_count+1)-1;
   else
      end_index=no_pts;
   end;
   col='b';
%   plot(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,col);
end;



start_index=data_mode_start_indices(mode_index);
if mode_index<size(data_mode_start_indices,1);
	end_index=data_mode_start_indices(mode_index+1)-1;
else
   end_index=no_pts;
end;
col='r';
%plot(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,col);
%axis([0 max(data_freq)/1000 0 10]);

%increase start index until remainder of mode increaes monotonically in frequency
%this is nesc for next bit where interp1 function requires monotonically increasing function

while start_index<end_index;
   if min(data_freq(start_index+1:end_index))>data_freq(start_index)
      break;
   end;
   start_index=start_index+1;
end;

if (freq>min(data_freq(start_index:end_index)))&(freq<max(data_freq(start_index:end_index)))

	%plot vph point on dispersion curves
	%vph=interp1(data_freq(start_index:end_index),data_ph_vel(start_index:end_index),freq);
	%plot(freq/1000,vph/1000,'ro');

	%now interpolate the mode shape
	ms_x=interp1(data_freq(start_index:end_index),data_ms_x(:,start_index:end_index)',freq)';
	ms_y=interp1(data_freq(start_index:end_index),data_ms_y(:,start_index:end_index)',freq)';
	ms_z=interp1(data_freq(start_index:end_index),data_ms_z(:,start_index:end_index)',freq)';

	%plot the 3D mode shape
	disp_shape=data_nodes+[ms_x,ms_y,ms_z]/3;

	figure;
	plot3(data_nodes(data_perimeter_node_list,1),data_nodes(data_perimeter_node_list,2),data_nodes(data_perimeter_node_list,3),'b');
	hold on;
	plot3(disp_shape(data_perimeter_node_list,1),disp_shape(data_perimeter_node_list,2),disp_shape(data_perimeter_node_list,3),'r');
	

	%figure;plot(ms_z(data_perimeter_node_list));

	end;
end;
