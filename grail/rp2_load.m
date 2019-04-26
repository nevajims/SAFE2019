%Change to default directory
if ~exist('def_working_dir','var');
   def_working_dir=matlabroot;
end;

if ischar(def_working_dir);
   cd(def_working_dir);
end;

%Dialog to open file
[exp_fname,def_working_dir]=uigetfile('*.rla','Open array data file');

%SAVE DEFAULTS
save(defaults_fname,'def_*');

fname=fullfile(def_working_dir,exp_fname);
tic;
load_exp_data;
disp(['Loading experimental data: ',num2str(toc)]);

%conversion to frequency domain and compensate for transmission delay in wavemaker
tic;
time_pts=size(in_time_data,1);
fft_pts=2^nextpow2(time_pts);
in_freq_data=fft(in_time_data,fft_pts);
in_freq_data=in_freq_data(1:fft_pts/2+1,:);
time_step=in_time(2)-in_time(1);
max_time=max(in_time);
freq_step=1/(fft_pts*time_step);
freq=[0:fft_pts/2]*freq_step;
in_signal=0.5*sin(2*pi*in_freq*in_time).*(1-cos(2*pi*in_freq*in_time/in_cycles)).*(in_time<=(in_cycles/in_freq));
in_signal_spec=fft(in_signal,fft_pts);
in_signal_spec=in_signal_spec(1:fft_pts/2+1,:);
freq_start_count=min(find(abs(in_signal_spec)>(max(abs(in_signal_spec)))/100));
freq_end_count=max(find(abs(in_signal_spec)>(max(abs(in_signal_spec)))/100));
freq_cent_count=round((freq_start_count+freq_end_count)/2);
filt_freq=in_freq;
filt_cycles=in_cycles;
delay=in_cycles/in_freq/2 *1.5;%1.5 is a fiddle cos I don't know what wavemaker delay is
dead_time=in_cycles/in_freq;
for tt_count=1:in_no_time_traces;
   in_freq_data(:,tt_count)=in_freq_data(:,tt_count) .* exp(-2*pi*i*freq*delay)';
end;
 
%TO DO should work out b/w of input signal and extract useful data only

disp(['Converting to frequency domain: ',num2str(toc)]);

%work out coupling, but do not compensate unless requested
rp2_calculate_coupling;

set(comp_coup_button,'enable','on');
set(mode_extract_button,'enable','off');
set(filter_button,'enable','on');
set(convert_to_dist_button,'enable','off');
set(feat_extr_button,'enable','off');

