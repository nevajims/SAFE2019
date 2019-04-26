function nearest_point_index=find_nearest_point(data_mode_start_indices,data_freq,mode_no,freq)

	start_index=data_mode_start_indices(mode_no);
	end_index=data_mode_start_indices(mode_no+1)-1;
	%find the maximum monotonic range of f for the range using wilco's function
	[start_index,end_index]=get_good_mode_indices(mode_no,data_freq,data_mode_start_indices);
	%find the nearest point
	nearest_point_index=round(interp1(data_freq(start_index:end_index),(start_index:end_index),freq))-start_index;
    if freq>max(data_freq)
        nearest_point_index=end_index;
    elseif isnan(nearest_point_index)
       nearest_point_index=start_index;
    end
    nearest_point_index=nearest_point_index-1+start_index;
    if nearest_point_index==0
        nearest_point_index=1
    end
