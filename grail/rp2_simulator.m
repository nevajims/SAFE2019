%this program simulates an experimental data (*.rla) file
%based on the new prototype configuration

clear;
close all;

%INPUT DATA

%input signal (assumed Hanning Window)
in_freq = 14.5e3;
in_cycles = 10;

%reflectors
refl_dist = [5];
refl_type = [1];%TODO - doesn't do aanything at present
refl_amp = [1];

%output filename
output_fname='N:\grail\matlab\rp2-simulated-15kHz.rla';

%hardware filename
hardware_fname='n:\grail\matlab\new_prototype';

%time step (1/sampling freq)
time_step = 1e-5; %100 kHz

%which modes to include in model
mode_list = [3, 5, 7, 8, 10];

%minimum group velocity that will be considered
min_gr_vel = 1e3;

%END OF USEFUL INPUT

%Name of file to get feature type refl coeff. matrices from
%feat_fname='F:\Paul\guided-ultrasonics\rail\matlab\fe-data\5mm_tap';%TODO

%Name of FE file to get mode shapes from - DONT CHANGE
%fe_fname='C:\Paul\matlab\rail\fe-data\5mm_tap';
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';

%END OF INPUT

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create input signal, spectrum and back shift to correct time origin
max_time = max(abs(refl_dist)) * 2 / min_gr_vel;
time_pts = ceil(max_time / time_step);
fft_pts = 2^nextpow2(time_pts);
disp(fft_pts);
max_time = fft_pts * time_step;
in_time = [0:fft_pts] * time_step;
in_signal=0.5 * sin(2 * pi * in_freq * in_time) .* (1 - cos(2 * pi * in_freq * in_time / in_cycles)) .* (in_time<in_cycles/in_freq);;
in_spec=fft(in_signal,fft_pts);
in_spec = in_spec(1:fft_pts/2+1);
freq_step = 1 / (fft_pts * time_step);
freq = ([1:fft_pts/2+1]-1)'*freq_step;
in_spec = in_spec' .* exp( - 2 * pi * i * freq * in_cycles / in_freq / 2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create wavenumber and validity matrix for each mode
run(hardware_fname);
load(fe_fname);
total_modes = length(mode_list);
mode_waveno = zeros(fft_pts/2+1, total_modes);
mode_valid = zeros(fft_pts/2+1, total_modes);
for mi = 1:total_modes;
   [start_index,end_index]=get_good_mode_indices(mode_list(mi),data_freq,data_mode_start_indices);
   mode_waveno(:,mi) = freq ./ interp1(data_freq(start_index:end_index), data_ph_vel(start_index:end_index), freq);
   mode_valid(:,mi) = interp1(data_freq(start_index:end_index), data_gr_vel(start_index:end_index), freq) > min_gr_vel;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create mode shape matrix for modes at transducer nodes **now with new sign flipper!!
mode_shapes = zeros(fft_pts/2+1,length(trans_node_list), total_modes);
for mi=1:total_modes;
   [start_index,end_index]=get_good_mode_indices(mode_list(mi),data_freq,data_mode_start_indices);
   for ii=start_index:end_index-1'
      if (data_ms_z(trans_node_list,ii)' * data_ms_z(trans_node_list,ii+1))<0
         data_ms_z(:,ii+1:end_index) = -data_ms_z(:,ii+1:end_index);
      end;
   end;
   for ii = 1:length(trans_node_list);
      mode_shapes(:,ii,mi) = interp1(data_freq(start_index:end_index),data_ms_z(trans_node_list(ii),start_index:end_index),freq);
   end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%set up transmitter and receiver row/pos indices vectors
total_transmitters = sum(sum(trans_pos(find(transmitter_rows),:))); 
total_receivers = sum(sum(trans_pos(find(receiver_rows),:))); 
total_time_traces = total_transmitters * total_receivers;

[temp_tx_row, temp_tx_pos] = find(transmitter_rows' * ones(1,size(trans_pos,2)) .* trans_pos);
[temp_rx_row, temp_rx_pos] = find(receiver_rows' * ones(1,size(trans_pos,2)) .* trans_pos);

temp_tx_indices = ones(total_receivers,1) * [1:total_transmitters];
temp_rx_indices = (ones(total_transmitters,1) * [1:total_receivers])';

tx_row = temp_tx_row(temp_tx_indices(:))';
rx_row = temp_rx_row(temp_rx_indices(:))';
tx_pos = temp_tx_pos(temp_tx_indices(:))';
rx_pos = temp_rx_pos(temp_rx_indices(:))';
clear('temp_*');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%the main loop
out_spectra = zeros(fft_pts/2+1,total_time_traces);
total_refls = length(refl_dist);
for tti=1:total_time_traces;
   for ri = 1:total_refls;
      d1 = abs(refl_dist(ri) - trans_row_pos(tx_row(tti)));
      d2 = abs(refl_dist(ri) - trans_row_pos(rx_row(tti)));
      %should sort out entries in reflection coefficient matrix here
      %for the approprate feature type. As a test ...
      refl_coef = eye(total_modes) * refl_amp(ri);
      for m1 = 1:total_modes;
         %propagate outgoing mode to reflector
         %taking into account (1) prop distance, (2) excitability, (3) transducer phasing
         spectrum_at_refl = in_spec .* ...
            exp (-2 * pi * i * d1 * mode_waveno(:, m1)) .* ...
            mode_valid(:,m1) .* ...
            mode_shapes(:,tx_pos(tti),m1) .* ...
            freq * ...
   	      trans_pos_phasings(tx_pos(tti));
         for m2 = 1:total_modes;
            %back propagate each mode back to receiver and calc spectrum
            %taking into account (1) prop distance, (2) mode shape, (3) transducer phasing and (4) reflection coefficient for the mode
            spectrum_at_rx = spectrum_at_refl .* ...
               exp (-2 * pi * i * d2 * mode_waveno(:, m2)) .* ...
               mode_shapes(:,rx_pos(tti),m2) .* ...
               mode_valid(:,m2) * ...
               trans_pos_phasings(rx_pos(tti)) * ...
               refl_coef(m1, m2);
            %add on the contribution of mode to out spectra
				out_spectra(:,tti) = out_spectra(:,tti) + spectrum_at_rx;
         end;
      end
   end
   disp(tti);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%inverse FFT to get time traces
out_spectra(find(isnan(out_spectra))) = 0;
out_data=real(ifft(out_spectra,fft_pts));
out_data = out_data / max(max(abs(out_data)));
temp1=zeros(time_pts, total_time_traces+1);
temp1(:,1)=in_time(1:time_pts)';
temp1(:,2:total_time_traces+1)=out_data(1:time_pts,:);
temp2=[0,tx_pos + tx_row/100;0,rx_pos + rx_row/100];
temp3 = [temp2;temp1];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%write output file
fid = fopen(output_fname,'wt');
if (fid>0)
   fprintf(fid, 'RL00\n');
	fprintf(fid, '$ Laboratory Rail Testing Matlab Simulated Data\n');
	fprintf(fid, '$ Excitation %i kHz %i cycle Gaussian Toneburst\n', in_freq / 1e3, in_cycles);
	fprintf(fid, '$ Raw Data Begin Data set 1\n');
	fprintf(fid, '$ 1-indexed position in structure is (1,1)\n');
	fprintf(fid, '%i kHz\n', in_freq);
	fprintf(fid, '%i points (%i cols)\n', time_pts, total_time_traces);
   for ii=1:2;
      fprintf(fid, '%.2f\t', temp3(ii,1:total_time_traces));
      fprintf(fid, '%.2f\n', temp3(ii,total_time_traces+1));
   end;
   for ii=3:size(temp3,1);
      fprintf(fid, '%f\t', temp3(ii,1:total_time_traces));
      fprintf(fid, '%f\n', temp3(ii,total_time_traces+1));
      fprintf(fid, '\n');
   end;
	fclose(fid);  
end;