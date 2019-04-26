clear;
close all;
clc;
disp('Test Data');
disp('==== ====');
load(load_m_file);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
ph_vel_fig_handle=axes;
figure(2);
gr_vel_fig_handle=axes;
vel_fig_title='Modes: ';
mode_colors='ymcrgbkymcrgbkymcrgbkymcrgbkymcrgbk';
mode_indices=[8 10];
for mode_count=1:length(mode_indices);
   mode_index=mode_indices(mode_count);
	start_index=data_mode_start_indices(mode_index);
	end_index=data_mode_start_indices(mode_index+1)-1;
	self_dps=zeros((end_index-start_index),data_no_nodes);
   dps=zeros((end_index-start_index),1);
   for freq_count=start_index:end_index;
   	first_point=start_index;
   	second_point=freq_count;
      for node_count=1:data_no_nodes
         first_vector=[data_ms_x(node_count,first_point) data_ms_y(node_count,first_point) data_ms_z(node_count,first_point)];
   		second_vector=[data_ms_x(node_count,second_point) data_ms_y(node_count,second_point) data_ms_z(node_count,second_point)];
         self_dps(freq_count-start_index+1,node_count)=abs(dot(first_vector,second_vector)/(norm(first_vector)*norm(second_vector)));
      end;
      dps(freq_count-start_index+1)=sum(self_dps(freq_count-start_index+1,:))/data_no_nodes;
   end;
	vel_fig_title=strcat(vel_fig_title,num2str(mode_index),',',' ');
	%plot phase velocity
	axes(ph_vel_fig_handle);
	hold on;
	plot(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,strcat(mode_colors(mode_index),'.-'));
	axis([0 30 0 10]);
	title(vel_fig_title);
	xlabel('Freqency(kHz)');
	ylabel('Phase Velocity(m/ms)')
	%plot group velocity
	axes(gr_vel_fig_handle);
	hold on;
	plot(data_freq(start_index:end_index)/1000,data_gr_vel(start_index:end_index)/1000,strcat(mode_colors(mode_index),'.-'));
	axis([0 30 0 6]);
	title(vel_fig_title);
	xlabel('Freqency(kHz)');
	ylabel('Group Velocity(m/ms)')
	%plot dot products
	figure;
	plot(data_freq(start_index:end_index)/1000,dps,strcat(mode_colors(mode_index),'.-'));
  	%plot(all_dps',strcat(mode_colors(mode_index),'.-'));
   axis([0 30 0 1]);
	title(strcat('mode  ',num2str(mode_index)));
	xlabel('Freqency(kHz)');
	ylabel('Dot Product')
end;
