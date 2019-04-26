function [start_index,end_index]=get_good_mode_indices(mode_index,data_freq,data_mode_start_indices);
	start_index=data_mode_start_indices(mode_index);
	end_index=data_mode_start_indices(mode_index+1)-1;
	temp=start_index;
   [start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
	start_index=temp+start_index-1;
	end_index=temp+end_index-1;
