prompt={'Filter frequency (kHz)',...
      'Cycles'};
if ~(exist('def_filter_freq','var')&exist('def_filter_cycles','var'));
   def_filt_freq=15e3;
   def_filt_cycles=5;
end;

def={num2str(def_filt_freq/1e3),num2str(def_filt_cycles)};
temp=inputdlg(prompt,'Time domain filter',1,def);
filt_freq=str2num(char(temp(1)))*1e3;
filt_cycles=str2num(char(temp(2)));
def_filt_freq=filt_freq;
def_filt_cycles=filt_cycles;

%SAVE DEFAULTS
save(defaults_fname,'def_*');

%do the filtering
if filt_freq>0;
	filt_signal=exp(2*pi*i*filt_freq*in_time) .* gaussian(length(in_time),0.5,(filt_cycles/2/filt_freq)/max(in_time))';
	filt_signal_spec=fft(filt_signal,fft_pts);
	filt_signal_spec=filt_signal_spec(1:fft_pts/2+1);
	temp=filt_signal_spec ./ in_signal_spec;
	filt_freq_data=zeros(size(in_freq_data));
	for count=1:size(in_freq_data,2);
   	filt_freq_data(:,count)=in_freq_data(:,count) .* temp;
   end;
else
   filt_freq_data=in_freq_data;
end;

%last line - turn of figures too
set(comp_coup_button,'enable','off');
set(mode_extract_button,'enable','on');
set(convert_to_dist_button,'enable','off');
set(feat_extr_button,'enable','off');

