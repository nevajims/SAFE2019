clear;
close all;
%get data
simul_data;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(model_fe_fname);
temp=who('data_*');
for count=1:length(temp);
   old_name=char(temp(count));
   new_name=['model_',old_name(6:length(old_name))];
   eval([new_name,'=',old_name,';']);
end;
load(actual_fe_fname);
temp=who('data_*');
for count=1:length(temp);
   old_name=char(temp(count));
   new_name=['actual_',old_name(6:length(old_name))];
   eval([new_name,'=',old_name,';']);
end;
clear('data_*');


if isempty(modes_of_interest)
   modes_of_interest=[1:model_no_modes];
end;

if ax_weight_type==3
   ax_sub_mode_indices=[extract_mode_indices',ax_sub_mode_indices];
end;

if xs_weight_type==3
	xs_sub_mode_indices=[extract_mode_indices',xs_sub_mode_indices];
end;
%work out spectrum of input signal
theta=linspace(0,2*pi,cycles*pts_per_cycle+1);
input_signal=sin(theta*cycles) .* (0.5*(1-cos(theta)));
fft_pts=2^nextpow2(length(input_signal))*16;
time_step=1/cent_freq/pts_per_cycle;
input_spec=fft(input_signal,fft_pts);
freq_step=1/(fft_pts*time_step);
%calc freq limits and set up freq vector
[freq_start_index,freq_end_index]=calc_bandwidth(input_spec(1:fft_pts/2+1),db_down);
freq=freq_start_index:freq_end_index;
freq=(freq-1)'*freq_step;
input_spec=input_spec(freq_start_index:freq_end_index);

result=zeros(freq_end_index-freq_start_index+1,length(modes_of_interest)*length(extract_mode_indices)*2);
%loop through the modes to extract
for extr_mode_count=1:length(extract_mode_indices);
   %work out the weighting functions for current mode to extract
   
   %around the rail weighting
   xs_weight=ones(length(freq),length(xs_pos));   
   %manual weighting
   if xs_weight_type==1;
	   for xs_count=1:length(xs_pos);
   	   xs_weight(:,xs_count)=ones(size(freq))*xs_manual_weights(extr_mode_count,xs_count);   
      end;
   end;
   %addition
   if xs_weight_type==2;
      [start_index,end_index]=get_good_mode_indices(extract_mode_indices(extr_mode_count),model_freq,model_mode_start_indices);
      %get mode shape at transducer location over all frequencies or just at centre freq
      for xs_count=1:length(xs_pos);
	      if xs_add_cent_freq_only
   	      m_shape_x=ones(size(freq))*interp1(model_freq(start_index:end_index),model_ms_x(trans_node_list(xs_pos(xs_count)),start_index:end_index),cent_freq,'cubic');
      	   m_shape_y=ones(size(freq))*interp1(model_freq(start_index:end_index),model_ms_y(trans_node_list(xs_pos(xs_count)),start_index:end_index),cent_freq,'cubic');
         	m_shape_z=ones(size(freq))*interp1(model_freq(start_index:end_index),model_ms_z(trans_node_list(xs_pos(xs_count)),start_index:end_index),cent_freq,'cubic');
	      else
			   m_shape_x=interp1(model_freq(start_index:end_index),model_ms_x(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
			   m_shape_y=interp1(model_freq(start_index:end_index),model_ms_y(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
		   	m_shape_z=interp1(model_freq(start_index:end_index),model_ms_z(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
	      end;
	      %displacement for normal transducer
			if xs_dir(xs_count)==1;
   	   	nor=model_surface_normal(find(model_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
      	   m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
	      end;
         %displacement for an in-plane torsional transducer
         if xs_dir(xs_count)==2;
            nor=model_surface_tangent(find(model_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
            m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
         end;
         %displacement for an in-plane axial transducer
         if xs_dir(xs_count)==3;
            m_shape=m_shape_z;
         end;
		xs_weight(:,xs_count)=m_shape;     
      end;
   end;
   %subtraction
   if xs_weight_type==3;
	   for freq_count=freq_start_index:freq_end_index;
	      if ((freq_count==freq_start_index)&xs_sub_cent_freq_only)|~xs_sub_cent_freq_only;
	         %build matrix of wavenumbers of modes
            weight=zeros(length(xs_pos),size(xs_sub_mode_indices,2));
            if xs_sub_cent_freq_only;
               fr=cent_freq;
            else
               fr=(freq_count-1)*freq_step;
            end;
      	   for mode_count=1:size(xs_sub_mode_indices,2);
               [start_index,end_index]=get_good_mode_indices(xs_sub_mode_indices(extr_mode_count,mode_count),model_freq,model_mode_start_indices);
               for xs_count=1:length(xs_pos);
					   m_shape_x=interp1(model_freq(start_index:end_index),model_ms_x(trans_node_list(xs_pos(xs_count)),start_index:end_index),fr,'cubic');
					   m_shape_y=interp1(model_freq(start_index:end_index),model_ms_y(trans_node_list(xs_pos(xs_count)),start_index:end_index),fr,'cubic');
      	         m_shape_z=interp1(model_freq(start_index:end_index),model_ms_z(trans_node_list(xs_pos(xs_count)),start_index:end_index),fr,'cubic');
		   		   %displacement for normal transducer
						if xs_dir(xs_count)==1;
   		   			nor=model_surface_normal(find(model_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
	      		   	m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
				      end;
			         %displacement for an in-plane torsional transducer
      			   if xs_dir(xs_count)==2;
		   	         nor=model_surface_tangent(find(model_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
      			      m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
		         	end;
	      		   %displacement for an in-plane axial transducer
			         if xs_dir(xs_count)==3;
      			      m_shape=m_shape_z;
		   	      end;
                  weight(xs_count,mode_count)=m_shape;               
               end;
      	   end;
         	%remove dud entries
	         weight(find(isnan(weight)))=0;
	         %invert
            inv_weight=pinv(weight);
	  	      %put relevant values into ax_weight
		   	for xs_count=1:length(xs_pos);
  			   	xs_weight(freq_count-freq_start_index+1,xs_count)=inv_weight(1,xs_count);   
           	end;
        	end;
      end;
   end;
   
   %axial weighting
   ax_weight=zeros(length(freq),length(ax_pos));
   %manual weighting along the rail
   if ax_weight_type==1;
	   for ax_count=1:length(ax_pos);
   	   ax_weight(:,ax_count)=ones(size(freq))*ax_manual_weights(extr_mode_count,ax_count);   
      end;
   end;
   %addition along the rail
   if ax_weight_type==2;
		[start_index,end_index]=get_good_mode_indices(extract_mode_indices(extr_mode_count),model_freq,model_mode_start_indices);
      if ax_add_cent_freq_only
         waveno=ones(size(freq))*interp1(model_freq(start_index:end_index),model_freq(start_index:end_index) ./ model_ph_vel(start_index:end_index),cent_freq,'cubic');
      else
         waveno=interp1(model_freq(start_index:end_index),model_freq(start_index:end_index) ./ model_ph_vel(start_index:end_index),freq,'cubic');
      end;
	   for ax_count=1:length(ax_pos);
   	   ax_weight(:,ax_count)=exp(-2*pi*i*waveno*trans_ax_pos(ax_pos(ax_count)));   
      end;
   end;
   %subtraction along the rail
   if ax_weight_type==3;
	   for freq_count=freq_start_index:freq_end_index;
	      if ((freq_count==freq_start_index)&ax_sub_cent_freq_only)|~ax_sub_cent_freq_only;
	         %build matrix of wavenumbers of modes
            weight=zeros(length(ax_pos),size(ax_sub_mode_indices,2));
            if ax_sub_cent_freq_only;
               fr=cent_freq;
            else
               fr=(freq_count-1)*freq_step;
            end;
      	   for mode_count=1:size(ax_sub_mode_indices,2);
         	   [start_index,end_index]=get_good_mode_indices(abs(ax_sub_mode_indices(extr_mode_count,mode_count)),model_freq,model_mode_start_indices);
            	waveno=interp1(model_freq(start_index:end_index),model_freq(start_index:end_index) ./ model_ph_vel(start_index:end_index),fr,'cubic');
	            waveno=waveno*sign(ax_sub_mode_indices(extr_mode_count,mode_count));
   	         weight(:,mode_count)=exp(2*pi*i*waveno*trans_ax_pos(ax_pos)');
      	   end;
         	%remove dud entries
	         weight(find(isnan(weight)))=0;
	         %invert
            inv_weight=pinv(weight);
         end;
  	      %put relevant values into ax_weight
	   	for ax_count=1:length(ax_pos);
  		   	ax_weight(freq_count-freq_start_index+1,ax_count)=inv_weight(1,ax_count);   
         end;
      end;
   end;
   
   %loop through all the modes to get amplitude of each
   for mode_count=1:length(modes_of_interest);
      res_index1=(extr_mode_count-1)*length(modes_of_interest)*2+mode_count;
      res_index2=(extr_mode_count-1)*length(modes_of_interest)*2+mode_count+length(modes_of_interest);
      disp(round(res_index1/size(result,2)*100));
      %loop through around rail positions
      for xs_count=1:length(xs_pos);
         %interpolate from finel data to get mode shape as a function of freq at around rail position
		   [start_index,end_index]=get_good_mode_indices(modes_of_interest(mode_count),actual_freq,actual_mode_start_indices);
	      m_shape_x=interp1(actual_freq(start_index:end_index),actual_ms_x(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
         m_shape_y=interp1(actual_freq(start_index:end_index),actual_ms_y(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
         m_shape_z=interp1(actual_freq(start_index:end_index),actual_ms_z(trans_node_list(xs_pos(xs_count)),start_index:end_index),freq,'cubic');
         %displacement for normal transducer
         if xs_dir(xs_count)==1;
            nor=actual_surface_normal(find(actual_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
            m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
         end;
         %displacement for an in-plane torsional transducer
         if xs_dir(xs_count)==2;
            nor=actual_surface_tangent(find(actual_perimeter_node_list==trans_node_list(xs_pos(xs_count))),:);
            m_shape=nor(1) * m_shape_x + nor(2) * m_shape_y;
         end;
         %displacement for an in-plane axial transducer
         if xs_dir(xs_count)==3;
            m_shape=m_shape_z;
         end;
         %remove NaNs
         m_shape(find(isnan(m_shape)))=0;
         exc=m_shape .* sqrt(freq); %note that this is the square root of normal excitability, effectively a measure of power?
			%interpolate from Finel data to find wavenumber of mode
         waveno=interp1(actual_freq(start_index:end_index),actual_freq(start_index:end_index) ./ actual_ph_vel(start_index:end_index),freq,'cubic');
			for ax_count=1:length(ax_pos);
            %add to result
		      result(:,res_index1)=result(:,res_index1)+ax_weight(:,ax_count) .* xs_weight(:,xs_count) .* exc .* exp(2*pi*i*waveno*trans_ax_pos(ax_pos(ax_count))) .* input_spec';
		      result(:,res_index2)=result(:,res_index2)+ax_weight(:,ax_count) .* xs_weight(:,xs_count) .* exc .* exp(-2*pi*i*waveno*trans_ax_pos(ax_pos(ax_count))) .* input_spec';
         end;
      end;
   end;
end;

%normalisation by peak value per block (i.e. not necs on extracted mode)
for extr_mode_count=1:length(extract_mode_indices);
   res_index1=(extr_mode_count-1)*length(modes_of_interest)*2+1;
   res_index2=(extr_mode_count-1)*length(modes_of_interest)*2+length(modes_of_interest)*2;
   max_val=max(max(abs(result(:,res_index1:res_index2))));
   result(:,res_index1:res_index2)=result(:,res_index1:res_index2)/max_val;
end;

result(find(abs(result)<1e-10))=1e-10;

%plot the phase and group velocity figures for reference
figure;
subplot(2,1,1);
hold on;
for mode_count=1:length(modes_of_interest);
	start_index=model_mode_start_indices(modes_of_interest(mode_count));
   end_index=model_mode_start_indices(modes_of_interest(mode_count)+1)-1;
   h=plot(model_freq(start_index:end_index)/1000,model_ph_vel(start_index:end_index)/1000,mode_colors(modes_of_interest(mode_count)));
	if ~isempty(find(extract_mode_indices==modes_of_interest(mode_count)));
   	set(h,'LineWidth',3);
   else
   	set(h,'LineWidth',0.5);
   end;
end;
axis([0 (freq_end_index-1)*freq_step*1.5/1000 0 10]);
subplot(2,1,2);
hold on;
for mode_count=1:length(modes_of_interest);
	start_index=model_mode_start_indices(modes_of_interest(mode_count));
   end_index=model_mode_start_indices(modes_of_interest(mode_count)+1)-1;
   h=plot(model_freq(start_index:end_index)/1000,model_gr_vel(start_index:end_index)/1000,mode_colors(modes_of_interest(mode_count)));
	if ~isempty(find(extract_mode_indices==modes_of_interest(mode_count)));
   	set(h,'LineWidth',3);
   else
   	set(h,'LineWidth',0.5);
   end;
end;
axis([0 (freq_end_index-1)*freq_step*1.5/1000 0 6]);

%plot the results
for extr_mode_count=1:length(extract_mode_indices);
   figure;
   for mode_count=1:length(modes_of_interest);
      res_index1=(extr_mode_count-1)*length(modes_of_interest)*2+mode_count;
      res_index2=(extr_mode_count-1)*length(modes_of_interest)*2+mode_count+length(modes_of_interest);
      subplot(2,1,1);
	   hold on;
      h=plot(freq/1000,20*log10(abs(result(:,res_index1))),mode_colors(modes_of_interest(mode_count)));
	   axis([(freq_start_index-1)*freq_step/1000 (freq_end_index-1)*freq_step/1000 -db_down 0]);
      if ~isempty(find(extract_mode_indices(extr_mode_count)==modes_of_interest(mode_count)));
         set(h,'LineWidth',3);
      else
         set(h,'LineWidth',0.5);
      end;
      subplot(2,1,2);
		hold on;
      plot(freq/1000,20*log10(abs(result(:,res_index2))),mode_colors(modes_of_interest(mode_count)));
	   axis([(freq_start_index-1)*freq_step/1000 (freq_end_index-1)*freq_step/1000 -db_down 0]);
   end;
end;

save([fname,'_result'],'result','extract_mode_indices','modes_of_interest');
clear;