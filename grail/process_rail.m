clear;
close all;

%inputs
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';

exp_fname='n:\grail\matlab\exp-data\corus-march01\test-17khz-4cycles-to-20ms';
%exp_fname='n:\grail\matlab\exp-data\corus-march01\long-test-17khz-4cycles-to-1000ms';
%exp_fname='n:\grail\matlab\exp-data\corus-march01\test-34khz-4cycles-to-20ms.mat';

%exp_fname='n:\grail\matlab\simul-data\all-modes-17khz-4cycle';
%exp_fname='n:\grail\matlab\simul-data\all-modes-17khz-4cycle';

%exp_fname='n:\grail\matlab\exp-data\connington-april01\20m-sep-15khz-4cycles-to-20ms';
%exp_fname='n:\grail\matlab\exp-data\connington-april01\30m-sep-15khz-4cycles-to-30ms-head-only';
%exp_fname='n:\grail\matlab\exp-data\connington-april01\20m-sep-15khz-4cycles-to-20ms-axial';%axial receivers at positons 5 and 8 only
%exp_fname='n:\grail\matlab\exp-data\connington-april01\20m-sep-15khz-4cycles-to-20ms-circum';%circum transducer tdc
%exp_fname='n:\grail\matlab\exp-data\connington-april01\20m-sep-15khz-4cycles-to-20ms-web-comp';%web only comp
%exp_fname='n:\grail\matlab\exp-data\connington-april01\20m-sep-15khz-4cycles-to-20ms-web-axial';%web only axial

load(fe_fname);
load(exp_fname);
exp_cent_freq=15e3;
exp_cycles=4;
%trans_node_list=[223 9 27 230 261 288 384 412 374 146 137 341];
trans_node_list=[63 53 306 72 107 139 251 279 241 409 151 197];%, ones(1,11)*197, 367];

%plot rail and trans locations
figure;
hold on;
plot(data_nodes(:,1),data_nodes(:,2),'b.');
plot(data_nodes(trans_node_list,1),data_nodes(trans_node_list,2),'ro');
text(data_nodes(trans_node_list(:),1),data_nodes(trans_node_list(:),2),num2str(trans_node_list(:)));
%desired_mode=10;
%normalise
normalise=1;
normalise_mode=8;
normalise_time=4.4e-3;%use for 4.6 for Corrington (20m), 6.6 for Corrington 30m and 4.4 for Workington

%dispersion compensation
disp_comp=1;
over_sample=4;
min_wavelength=0.1;
min_pts_per_wavelength=8;
range=50; %range in metres to display on * vs. distance graphs
%frequency filtering
filter_on=1;
desired_cycles=20;
desired_cent_freq=15e3;
%simple weighted summation -  positive number is number to do
simple_sum=0;
simple_sum_weights=[	1 0 0 0 0 0 0 0 0 0 0 1; 
   						0 1 0 0 0 0 0 0 0 0 1 0; 
   						0 0 1 0 0 0 0 0 0 1 0 0; 
   						0 0 0 1 0 0 0 0 1 0 0 0; 
   						0 0 0 0 1 0 0 1 0 0 0 0; 
                     0 0 0 0 0 1 1 0 0 0 0 0];
simple_sum_mode_indices=[3];
%sum based on mode shapes
ms_sum=1;
ms_sum_mode_indices=[3;5;7;8;10];%[1;2;3;4;5;6;8;9;10;11;12;13;21];%[1;2;3;4;8;10];%
ms_sum_mask=[0 1 1 1 1 1 1 1 1 1 1 0];%[1 1 1 1 1 1 1 1 1 1 1 1];%
%ms_sum_mask=[0 1 1 1 1 1 1 1 1 1 1 0];
ms_sum_cent_freq_only=1;

%subtraction based on mode shapes
ms_sub=0;
ms_sub_mode_indices=[3;7;5;8;10];%[8;10];%[1;2;3;4;5;6;8;9;10;11;12;21];%

%calculation will be based on number of modes here and will try and extract each one assuming only others are present
ms_sub_mask=[0 1 1 1 0 1 1 0 1 1 1 0];%[1 1 1 1 1 1 1 1 1 1 1 1];%
ms_sub_cent_freq_only=1;
%display options
show_real=1;
show_abs=0;
title_on=0;
log_plot=0;
db_range=40;
norm_mode=1;%1 to normalise of individual signals, 2 to normalise off all signals, 3 for a specific value (norm_amp)
norm_val=3.1000e-018;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[path,data_fname,ext,ver] = fileparts(exp_fname);
basic_title=strcat('File: ',data_fname);
basic_title=strvcat(basic_title,strcat('Signal: ',num2str(desired_cycles),'cycles,',num2str(round(desired_cent_freq/1000)),' kHz'));

%initial frequency filtering of all time traces
if filter_on;
	fft_pts=2^nextpow2(exp_no_pts);
	time=0:exp_no_pts-1;
	time=time*exp_time_step;
	input_signal=zeros(exp_no_pts,1);
	for count=1:round(exp_cycles/exp_cent_freq/exp_time_step);
   	input_signal(count)=sin(2*pi*exp_cent_freq*time(count))*(1-cos(2*pi*time(count)/(exp_cycles/exp_cent_freq)));
	end;
	input_signal_spec=fft(input_signal,fft_pts);
	desired_signal=zeros(exp_no_pts,1);
	for count=1:round(desired_cycles/desired_cent_freq/exp_time_step);
   	desired_signal(count)=sin(2*pi*desired_cent_freq*time(count))*(1-cos(2*pi*time(count)/(desired_cycles/desired_cent_freq)));
	end;
	desired_signal_spec=fft(desired_signal,fft_pts);
   freq_step=1.0/(exp_time_step*fft_pts);
   freq=1:fft_pts;
   freq=(freq-1)*freq_step;

	%work out usable freq bandwidth based on -40 dB pts
	max_val=0.0;
	for count=1:fft_pts/2;
   	if abs(desired_signal_spec(count,1))>max_val
      	max_val=abs(desired_signal_spec(count,1));
	   end;
	end;
	freq_start_index=1;
	while freq_start_index<fft_pts/2;
   	if abs(desired_signal_spec(freq_start_index,1))>max_val/100
      	break;
	   end
   	freq_start_index=freq_start_index+1;
	end;
	freq_end_index=fft_pts/2;
	while freq_end_index>0;
   	if abs(desired_signal_spec(freq_end_index,1))>max_val/100
      	break;
	   end
   	freq_end_index=freq_end_index-1;
	end;

	%fft and filter the lot and back propagate to get origin at centre of toneburst
   exp_specs=fft(exp_values,fft_pts);
   time_shift=exp_cycles/exp_cent_freq/2;
	for count=1:exp_no_files
   	exp_specs(:,count)=exp_specs(:,count) .* exp(i*2*pi*freq*time_shift)' .* abs(desired_signal_spec ./ input_signal_spec);
   end;
   exp_specs=exp_specs(1:fft_pts/2+1,:);
end;

%normalisation
if normalise
   %work out time to do normalisation at - point where sum of all time traces crosses threshold
   normalise_index=round(normalise_time/exp_time_step);
   [start_index,end_index]=get_good_mode_indices(normalise_mode,data_freq,data_mode_start_indices);
	ms=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',desired_cent_freq)';
   for count=1:exp_no_files
      sig=ifft(exp_specs(:,count),fft_pts);
      measured_amp=abs(sig(normalise_index));
      target_amp=abs(ms(exp_trans(1,count))*ms(exp_trans(2,count)));
      fac=measured_amp/target_amp;
      exp_specs(:,count)=exp_specs(:,count)/fac;
   end;
end;

%simple sums
if simple_sum>0
   basic_title=strcat(basic_title,', manual weighting');
   mode_indices=simple_sum_mode_indices;
   modes=size(simple_sum_weights,1);
   result=zeros(fft_pts,modes);
   weight_matrix=zeros(modes,size(trans_node_list,2));
   for mode_count=1:modes;
      weight_matrix(mode_count,:)=simple_sum_weights(mode_count,:);
      for count=1:exp_no_files;
         weight=simple_sum_weights(mode_count,exp_trans(1,count))*simple_sum_weights(mode_count,exp_trans(2,count));
         result(1:fft_pts/2+1,mode_count)=result(1:fft_pts/2+1,mode_count)+exp_specs(1:fft_pts/2+1,count)*weight;
      end;
   end;
	result=ifft(result(1:fft_pts/2+1,:),fft_pts);
   result=result(1:exp_no_pts,:);
end;

%sums based on mode shapes
if ms_sum>0;
   basic_title=strvcat(basic_title,'Weighting: addition');
   mode_indices=ms_sum_mode_indices;
   modes=length(mode_indices);
   result=zeros(fft_pts,modes);
	if ms_sum_cent_freq_only;
      weight_matrix=zeros(modes,size(trans_node_list,2));
   else
      weight_matrix=[];
   end;
   for mode_count=1:modes;
      start_index=data_mode_start_indices(mode_indices(mode_count));
		end_index=data_mode_start_indices(mode_indices(mode_count)+1)-1;
		      temp=start_index;
      		[start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
		      start_index=temp+start_index-1;
		      end_index=temp+end_index-1;
		if ms_sum_cent_freq_only
      	%get the mode shape at the centre freq
         current_ms=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',desired_cent_freq)' .* ms_sum_mask';
         weight_matrix(mode_count,:)=current_ms';
	      for count=1:exp_no_files;
   	      weight=current_ms(exp_trans(1,count))*current_ms(exp_trans(2,count));
      	   result(1:fft_pts/2+1,mode_count)=result(1:fft_pts/2+1,mode_count)+exp_specs(1:fft_pts/2+1,count)*weight;
	      end;
      end;
   	if ~ms_sum_cent_freq_only
         %get the mode shape at each freq - not sure about this as scaling of mode shapes between freqs is not known?
         for freq_count=freq_start_index:freq_end_index
            
            freq=(freq_count-1)*freq_step;
            current_ms=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',freq)' .* ms_sum_mask';
		      for count=1:exp_no_files;
   		      weight=current_ms(exp_trans(1,count))*current_ms(exp_trans(2,count));
      		   result(freq_count,mode_count)=result(freq_count,mode_count)+exp_specs(freq_count,count)*weight;
            end;
         end;
      end;
   end;
	result=ifft(result(1:fft_pts/2+1,:),fft_pts);
   result=result(1:exp_no_pts,:);
end;

%subtraction based on mode shapes
if ms_sub>0;
   basic_title=strvcat(basic_title,'Weighting: subtraction');
   mode_indices=ms_sub_mode_indices;
   modes=length(mode_indices);
   result=zeros(fft_pts,modes);
	if ms_sub_cent_freq_only;
      weight_matrix=zeros(modes,size(trans_node_list,2));
	else
      weight_matrix=[];
   end;
   for freq_count=freq_start_index:freq_end_index;
      %build matrix of mode shapes at each freq or just centre freq
   	ms_sub_ms=zeros(size(trans_node_list,2),ms_sub);
      if ((freq_count==freq_start_index)&(ms_sub_cent_freq_only))|~ms_sub_cent_freq_only;
         if ms_sub_cent_freq_only;
            freq=desired_cent_freq;
         else
            freq=(freq_count-1)*freq_step;
         end;
         for mode_count=1:modes;
            [start_index,end_index]=get_good_mode_indices(mode_indices(mode_count),data_freq,data_mode_start_indices);
	      	ms_sub_ms(:,mode_count)=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list,start_index:end_index)',freq)' .* ms_sub_mask';
	   	end;
			%set any NaNs to zero
			ms_sub_ms(find(isnan(ms_sub_ms)))=0;
   		%compute moore-penrose inverse of mode shapes matrix (minimise least squares error of over determined problem)
         inv_ms_sub_ms=pinv(ms_sub_ms);
         if ms_sub_cent_freq_only;
            weight_matrix=inv_ms_sub_ms;
         end;
      end;
      
	   %now extract the modes
   	for mode_count=1:modes;
		   for count=1:exp_no_files;
   			weight=inv_ms_sub_ms(mode_count,exp_trans(1,count))*inv_ms_sub_ms(mode_count,exp_trans(2,count));
      		result(freq_count,mode_count)=result(freq_count,mode_count)+exp_specs(freq_count,count)*weight;
			end;
   	end;
   end;
   %go back to time domain
	result=ifft(result(1:fft_pts/2+1,:),fft_pts);
   result=result(1:exp_no_pts,:);
end;

%dispersion compensation
if disp_comp;
   for mode_count=1:modes;
      desired_mode=mode_indices(mode_count);
		freq_min=freq_start_index*freq_step;
		freq_max=freq_end_index*freq_step;
		start_index=data_mode_start_indices(desired_mode);
      end_index=data_mode_start_indices(desired_mode+1)-1;
      temp=start_index;
      [start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
      start_index=temp+start_index-1;
      end_index=temp+end_index-1;
		waveno_min=interp1(data_freq(start_index:end_index), data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),freq_min,'linear');
   	waveno_max=interp1(data_freq(start_index:end_index), data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),freq_max,'linear');
	   %if mode ends within frequency range set waveno limits to cut-off freq
		if isnan(waveno_min)
   		waveno_min=min(data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index));
		end;
		if isnan(waveno_max)
   		waveno_max=max(data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index));
		end;

		waveno_step=1.0/range;
		waveno_start_index=round(waveno_min/waveno_step)+1;
		waveno_end_index=round(waveno_max/waveno_step)+1;
		waveno_index=[waveno_start_index:waveno_end_index];
		waveno=(waveno_index-1) * waveno_step;
      freq_at_waveno=interp1(data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),data_freq(start_index:end_index),waveno);
      freq_at_waveno(find(isnan(freq_at_waveno)))=0;
		freq_index2=[0:fft_pts*over_sample-1];
		freq_step2=1.0/(exp_time_step*fft_pts*over_sample);
		freq2=freq_index2*freq_step2;
		temp_spec=fft(real(result(:,mode_count)), fft_pts*over_sample);
      comp_result_spec=interp1(freq2,temp_spec,freq_at_waveno,'linear');
      if mode_count==1;
         dist_step=min_wavelength/min_pts_per_wavelength;
         spac_fft_pts=2^nextpow2(round(range/dist_step));
			dist=1:spac_fft_pts;
			dist_step=1.0/(waveno_step*(spac_fft_pts-2));
         dist_pts=round(range/dist_step)+1;
			dist=(dist-1)*dist_step;
		   comp_result=zeros(spac_fft_pts,simple_sum);
      end;
      comp_result_spec=[zeros(1,waveno_start_index-1) comp_result_spec zeros(1,spac_fft_pts-waveno_end_index)];
		comp_result(:,mode_count)=ifft(comp_result_spec,spac_fft_pts)';
   end;
end;

%plot pre-dispersion compensated result
figure;
hold on;
zoom on;
text_x=1.05*max(time(1:exp_no_pts))*1e3;
for mode_count=1:modes;
   if title_on;
      position=[0.1,(mode_count-1)/(modes)*0.8+0.11,0.8,1/(modes+1)*0.8*0.8];
   else
      position=[0.1,(mode_count-1)/modes*0.8+0.11,0.8,1/modes*0.8*0.8];
   end;      
   subplot('position',position);
	if norm_mode==1;
   	max_val=max(abs(result(:,mode_count)));
	end;
   if norm_mode==2;
   	max_val=max(max(abs(result)))
   end;
   if norm_mode==3;
      max_val=norm_val;
   end;
   if ~log_plot;
		temp=result(:,mode_count)/max_val*0.8;
		if show_real;
      	plot(time(1:exp_no_pts)*1e3,real(temp(1:exp_no_pts)),'b');
	   end;
		if show_abs;
      	plot(time(1:exp_no_pts)*1e3,abs(temp(1:exp_no_pts)),'r');
      end;
   	text(text_x,0,num2str(mode_indices(mode_count)));
		axis([0 max(time(1:exp_no_pts)*1e3) -1 1]);
   end;
   if log_plot;
      temp=db_range+20*log10(abs(result(:,mode_count))/max_val);
      temp=temp .* (temp>0);
      plot(time(1:exp_no_pts)*1e3,abs(temp(1:exp_no_pts)),'r');
	   text(text_x,db_range/2,num2str(mode_indices(mode_count)));
		axis([0 max(time(1:exp_no_pts)*1e3) 0 db_range]);
   end;
	if (mode_count==modes)&title_on;
   	title(basic_title);
	end;
	if mode_count==1;
   	xlabel('Time (ms)');
	end;
end;

%plot as function of distance
figure;
hold on;
zoom on;
text_x=1.05*range;
for mode_count=1:modes;
   if title_on;
      position=[0.1,(mode_count-1)/(modes)*0.8+0.11,0.8,1/(modes+1)*0.8*0.8];
   else
      position=[0.1,(mode_count-1)/modes*0.8+0.11,0.8,1/modes*0.8*0.8];
   end;      
   subplot('position',position);
   if disp_comp
      x=dist(1:dist_pts);
      if norm_mode==1;
         max_val=max(abs(comp_result(:,mode_count)));
      end;
      if norm_mode==2;
         max_val=max(max(abs(comp_result)));
      end;
	   if norm_mode==3;
   	   max_val=norm_val;
	   end;
      y=comp_result(:,mode_count)/max_val*0.8;
      y=y(1:dist_pts);
   else
      desired_mode=mode_indices(mode_count,1);
		start_index=data_mode_start_indices(desired_mode);
   	end_index=data_mode_start_indices(desired_mode+1)-1;
		while start_index<end_index;
			if min(data_freq(start_index+1:end_index))>data_freq(start_index)
      		break;
			end;
   		start_index=start_index+1;
		end;
      vgr=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index),desired_cent_freq);
      x=time(1:exp_no_pts)*vgr;
      if ~isempty(min(find(x>range)))
         pts=min(find(x>range));
      else
         pts=exp_no_pts;
      end;
      x=x(1:pts);
      if norm_mode==1;
         max_val=max(abs(comp_result(:,mode_count)));
      end;
      if norm_mode==2;
         max_val=max(max(abs(comp_result)));
      end;
	   if norm_mode==3;
   	   max_val=norm_val;
	   end;
      y=result(:,mode_count)/max_val;
      y=y(1:pts);
   end;
   if ~log_plot;
	   if show_real;
   		plot(x,real(y),'b');
		end;
   	if show_abs;
   		plot(x,abs(y),'r');
		end;
   	text(text_x,0,num2str(mode_indices(mode_count)));
      axis([0 range -1 1]);
   end;
   if log_plot;
      temp=20*log10(abs(y)/max_val);
      temp=temp+db_range;
      temp=temp .*(temp>0);
      plot(x,temp);
   	text(text_x,db_range/2,num2str(mode_indices(mode_count)));
      axis([0 range 0 db_range]);
   end;
	if (mode_count==modes)&title_on;
   	title(basic_title);
	end;
	if mode_count==1;
   	xlabel('Distance (m)');
	end;
end;

%plot weightings
if ~isempty(weight_matrix);
	figure;
	hold on;
	zoom on;
	for count=1:modes;
   	subplot(modes,1,count);
	   bar(weight_matrix(count,:)/max(max(abs(weight_matrix(count,:)))),'grouped');
   	axis([0.5 size(trans_node_list,2)+0.5 -1.05 1.05]);
	   title(strcat('Mode number ',num2str(mode_indices(count))));
		xlabel('Transducer position');
	   ylabel('Weighting (linear)');
	end;
end;
