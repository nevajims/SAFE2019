clear;
close all;

exp_fname='n:\grail\matlab\simul-data\all-modes-17khz-4cycle';
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';
load(fe_fname);

exp_cent_freq=17e3;
exp_cycles=4;
exp_no_pts=5000;
exp_time_step=0.004e-3;
min_vgr=1000;%anything with vgr less than this will be ignored to prevent wrapping in signals
max_vgr=6000;%any feature starting to appear outside time signal will be ignored
db_down=40;

%still need setting
%exp_trans

%define possible transducer positions - don't all have to be used
trans_node_list=[63 53 306 72 107 139 251 279 241 409 151 197 63 53 306 72 107 139 251 279 241 409 151 197];
trans_dir_list=[3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3 3];%1=normal, 2=in-plane torsional, 3=axial
trans_axial_pos=[0 0 0 0 0 0 0 0 0 0 0 0 20 20 20 20 20 20 20 20 20 20 20 20];

%specify the transducer and recevier positions to simulate data for
tx_trans=[2,3,4,6,7,9,10,11];%[1,2,3,4,5,6,7,8,9,10,11,12]; 
rx_trans=tx_trans+12;%[1,2,3,4,5,6,7,8,9,10,11,12]; 

%specify the reflector positions and amplitude
refl_pos=[];%[30 40];%[-50.2 130];
refl_amp=[];%[1 1];

%specify the mode numbers to use
mode_indices=[1;2;3;4;5;6;7;8;9;10;11;12;13;21];

exp_no_files=length(tx_trans)*length(rx_trans);%transduer numbers will indicate block numbers in exp file

%set up input signal spec
time=1:round(exp_cycles/exp_cent_freq/exp_time_step);
time=(time-1)*exp_time_step;
input_signal=sin(2*pi*time*exp_cent_freq) .* (0.5*(1-cos(time/(exp_cycles/exp_cent_freq)*2*pi)));
if isempty(refl_pos)
   refls=0;
   max_dist=(max(trans_axial_pos)-min(trans_axial_pos))*2;%2 is for safety
else
   refls=length(refl_pos);
   max_dist=max(refl_pos)*2;
end;
time_pts=round(max_dist/min_vgr/exp_time_step);
fft_pts=2^nextpow2(time_pts);

%calc input spectrum and set up freq vector
input_spec=fft(input_signal,fft_pts);
freq_step=1/(fft_pts*exp_time_step);
freq=1:fft_pts;
freq=(freq-1)*freq_step;

%calc freq limits 
[freq_start_index,freq_end_index]=calc_bandwidth(input_spec(1:fft_pts/2+1),db_down);
%set up output matrix of spetrums
specs=zeros(fft_pts,exp_no_files);

%set up transducer xref matrix
exp_trans=zeros(2,length(tx_trans)*length(rx_trans));

%and fill it
tic;
for mode_count=1:length(mode_indices);
   %interpolate wavenumber data for mode to get wavenumber at frequency bins in b/w
	start_index=data_mode_start_indices(mode_indices(mode_count));
   end_index=data_mode_start_indices(mode_indices(mode_count)+1)-1;
   temp=start_index;
   [start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
   start_index=start_index+temp-1;
   end_index=end_index+temp-1;
   waveno=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),freq(freq_start_index:freq_end_index),'cubic');
   v_gr=interp1(data_freq(start_index:end_index),data_gr_vel(start_index:end_index),freq(freq_start_index:freq_end_index),'cubic');
   valid=v_gr>min_vgr;
   waveno(find(isnan(waveno)))=0;
	tt_count=1;
   for tx_count=1:length(tx_trans);
      %disp at tx location
      disp_at_tx=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list(tx_trans(tx_count)),start_index:end_index),freq(freq_start_index:freq_end_index),'cubic');
	   disp_at_tx(find(isnan(disp_at_tx)))=0;
      for rx_count=1:length(rx_trans);
         exp_trans(1,tt_count)=tx_trans(tx_count);
         exp_trans(2,tt_count)=rx_trans(rx_count);
         disp_at_rx=interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list(rx_trans(rx_count)),start_index:end_index),freq(freq_start_index:freq_end_index),'cubic');
		   disp_at_rx(find(isnan(disp_at_rx)))=0;
         excite=disp_at_tx .* disp_at_rx .* freq(freq_start_index:freq_end_index);
			for refl_count=0:refls;
            %work out propagation distance
            if refl_count==0;
               %direct transmision
               dist=abs(trans_axial_pos(tx_trans(tx_count))-trans_axial_pos(rx_trans(rx_count)));
               amp=1;
            else
               %off a reflector
               dist=abs(trans_axial_pos(tx_trans(tx_count))-refl_pos(refl_count))+...
                  abs(trans_axial_pos(rx_trans(rx_count))-refl_pos(refl_count));
               amp=refl_amp(refl_count);
            end;
            %check if it will be on time trace
%            excite=ones(size(excite));
            if (dist/min_vgr)<(exp_time_step*time_pts);
      	      %phase shift input spec and add to output spec
               specs(freq_start_index:freq_end_index,tt_count)=specs(freq_start_index:freq_end_index,tt_count) +...
                  (amp*...
                  (input_spec(freq_start_index:freq_end_index) .* excite .* ...
                  valid .* exp(2*pi*i*waveno*dist)))';
            end
         end;
			%increment time trace counter
         tt_count=tt_count+1;
      end;
   end;
end;
toc;
%finally IFFT to get time traces
exp_values=real(ifft(specs));
%and chop to correct length
if exp_no_pts<fft_pts
   exp_values=exp_values(1:exp_no_pts,:);
else
   exp_values=[exp_values;zeros(exp_no_pts-fft_pts,size(exp_values,2))];
end;

%special fix to compare with existing exp data
exp_trans(2,:)=exp_trans(2,:)-12;

figure;
to_plot=min(size(exp_values,2),10);
max_y=max(max(exp_values));
time=1:exp_no_pts;
time=(time-1)*exp_time_step;
for count=1:to_plot;
   subplot(to_plot,1,count);
   plot(time,exp_values(:,count));
%   max_y=max(exp_values(:,count));
   if max_y==0;
      max_y=1;
   end;
   axis([0 max(time) -max_y max_y]);
end;
zoom on;

save(exp_fname,'exp_*');