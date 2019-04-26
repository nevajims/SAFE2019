function draw_vgr(data_freq,data_gr_vel,mode_index,data_no_modes,data_mode_start_indices,freq,freq_lims,handle);
legend_text=cell(data_no_modes,1);
mode_colors='ymcrgbkymcrgbkymcrgbkymcrgbkymcrgbk';
axes(handle);
cla;
hold on;
view(2);
for mode_count=1:data_no_modes;
   start_index=data_mode_start_indices(mode_count);
   end_index=data_mode_start_indices(mode_count+1)-1;
   if mode_index<0;
      col=strcat(mode_colors(mode_count),'.-');
      legend_text(mode_count)={strcat('Mode  ',num2str(mode_count))};
  else
      if mode_count==mode_index;
         col='r-';
      else
         col='b-';
      end;
   end;
   plot(data_freq(start_index:end_index)/1000,data_gr_vel(start_index:end_index)/1000,col);
end;
axis([0 max(data_freq)/1000 0 10]);
xlabel('Frequency (kHz)');
ylabel('Group velocity (m/ms)');
if mode_index<0
    legend(legend_text);
end
if freq>0;
   start_index=data_mode_start_indices(mode_index);
	end_index=data_mode_start_indices(mode_index+1)-1;
   %find the maximum monotonic range of f for the range using wilco's function
	[monoton_start_index,monoton_end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
	%reset the start and end according to results
	end_index=start_index+monoton_end_index-1;
	start_index=start_index+monoton_start_index-1;
	%do the interpolation
   
   while start_index<end_index;
		if min(data_freq(start_index+1:end_index))>data_freq(start_index)
   		break;
		end;
   	start_index=start_index+1;
	end;
	vgr=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index),freq);
   plot(freq/1000,vgr/1000,'ro');
end;
axis([freq_lims(1)/1000 freq_lims(2)/1000 0 6]);



