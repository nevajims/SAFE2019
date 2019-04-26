close all;
clear;
%FE data
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';
%calulation ranges
linear=0;
db_range=40;
show_all_modes=1;
show_target_mode=1;
show_kill_modes=1;
freq=linspace(10e3,20e3,100);
vph=linspace(-10e3,10e3,500);
%transmission
tx_pos=linspace(0,0.1,2);
tx_target_mode=8;
tx_proc_sum=0;
tx_proc_sub=1;
tx_kill_modes=[-8];%only used for subtraction use -ve to specify backwards travelling
exc_sig=1;
cent_freq=15e3;
cycles=20;
%reception
rx_equals_tx=1;
rx_pos=linspace(0.025,0.375,2);
rx_target_mode=8;
rx_proc_sum=0;
rx_proc_sub=1;
rx_kill_modes=[9];%only used for subtraction use -ve to specify backwards travelling

%general processing
[mesh_freq, mesh_vph]=meshgrid(freq,vph);
wn_mesh=mesh_freq ./ mesh_vph;
tx_result=zeros(size(mesh_freq));
rx_result=zeros(size(mesh_freq));
result=zeros(size(mesh_freq));

%work out excitation signal spectrum if used
if exc_sig
   time=linspace(0,cycles/cent_freq,cycles*10);
   s=sin(2*pi*cent_freq*time) .* (1-cos(2*pi*time/(cycles/cent_freq)));
   fft_pts=2^nextpow2(length(s)*10);
   f=fft(s,fft_pts);
   freq_step=1/(fft_pts*(time(2)-time(1)));
   freq2=1:fft_pts;
   freq2=(freq2-1)*freq_step;
   sig_spec=interp1(freq2,abs(f),freq,'cubic');
end;

%load FE data
load(fe_fname);

%do main loop twice, if different tx and rx
if rx_equals_tx
   main_count_max=1;
else
   main_count_max=2;
end;

%main loop
tic;
for main_count=1:main_count_max;
   if main_count==1;
      proc_sum=tx_proc_sum;
      proc_sub=tx_proc_sub;
      target_mode=tx_target_mode;
      kill_modes=tx_kill_modes;
      trans_pos=tx_pos;
   end;
   if main_count==2;
      proc_sum=rx_proc_sum;
      proc_sub=rx_proc_sub;
      target_mode=rx_target_mode;
      kill_modes=rx_kill_modes;
      trans_pos=rx_pos;
   end;
	%addition processing
	if proc_sum;
		start_index=data_mode_start_indices(target_mode);
		end_index=data_mode_start_indices(target_mode+1)-1;
		temp=start_index;
	   [start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
		start_index=temp+start_index-1;
		end_index=temp+end_index-1;
   	target_waveno=interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),freq,'cubic');
	   for count=1:length(trans_pos);
   	   weight=exp(-2*pi*i*target_waveno*trans_pos(count));
      	for vph_count=1:length(vph);
	         result(vph_count,:)=result(vph_count,:)+weight .* exp(2*pi*i*wn_mesh(vph_count,:)*trans_pos(count));
   	   end;
	   end;
	end;

	%subtraction processing
	if proc_sub;
   	%prepare propagation matrix
	   prop_matrix=zeros(length(trans_pos),1+length(kill_modes));
   	weight=zeros(length(freq),length(trans_pos));
	   %loop in frequency - weighting is reevaluated at each
   	for freq_count=1:length(freq);
	      %build matrix of displacements of each mode at x locations, first row is desired mode
   	   for mode_count=1:length(kill_modes)+1
      	   if mode_count==1
         	   mode_index=target_mode;
	         else
   	         mode_index=kill_modes(mode_count-1);
      	   end;
			start_index=data_mode_start_indices(abs(mode_index));
			end_index=data_mode_start_indices(abs(mode_index)+1)-1;
			temp=start_index;
   		[start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
			start_index=temp+start_index-1;
	      end_index=temp+end_index-1;
   	   waveno=sign(mode_index)*interp1(data_freq(start_index:end_index),data_freq(start_index:end_index) ./ data_ph_vel(start_index:end_index),freq(freq_count),'cubic');
      	prop_matrix(:,mode_count)=exp(2*pi*i*waveno*trans_pos');
	      prop_matrix(find(isnan(prop_matrix)))=0;
   	   %Moore penrose inverse of prop_matrix
      	inv_prop_matrix=pinv(prop_matrix);
	      %weighting is first line of inverse (i.e. the target mode)
   	   weight(freq_count,:)=inv_prop_matrix(1,:);
	   	end;
	   end;
	   %now work out result
	   for vph_count=1:length(vph);
	      for freq_count=1:length(freq)
   	      result(vph_count,freq_count)=result(vph_count,freq_count)+weight(freq_count,:) * exp(2*pi*i*wn_mesh(vph_count,freq_count)*trans_pos');
      	end;
		end;
   end;
   %put results in correct matrix
   if main_count==1;
      tx_result=result;
   end;
   if main_count==2;
      rx_result=result;
   end;
end;

%combine tx and rx results
if rx_equals_tx
   result=tx_result .^ 2;
else
   result=tx_result .* rx_result;
end;

%effect of excitation signal if reqd
if exc_sig
   for vph_count=1:length(vph);
      result(vph_count,:)=result(vph_count,:) .* sig_spec;
   end;
end;
toc;
%plot result surface
result=result/max(max(abs(result)));
if ~linear;
	result(find(result==0))=1/(10^(db_range/20));
	result=20*log10(result);
	result=result+db_range;
   result=result .* (result>0);
end;

surf(mesh_freq/1000,mesh_vph/1000,abs(result));shading interp;view(2);
colormap('bone');
colorbar;
hold on;

%show all modes
if show_all_modes;
   for count=1:data_no_modes;   
		start_index=data_mode_start_indices(count);
   	end_index=data_mode_start_indices(count+1)-1;
	   col='b';
      plot3(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,ones(1,end_index-start_index+1)*db_range*2,col);
      plot3(data_freq(start_index:end_index)/1000,-data_ph_vel(start_index:end_index)/1000,ones(1,end_index-start_index+1)*db_range*2,col);
   end;
end;
if show_target_mode;
	start_index=data_mode_start_indices(target_mode);
   end_index=data_mode_start_indices(target_mode+1)-1;
	col='r';
   plot3(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,ones(1,end_index-start_index+1)*db_range*2,col);
end;
if show_kill_modes;
   for count=1:length(kill_modes);   
		start_index=data_mode_start_indices(abs(kill_modes(count)));
   	end_index=data_mode_start_indices(abs(kill_modes(count))+1)-1;
      col='y';
      if kill_modes(count)>0;
         plot3(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,ones(1,end_index-start_index+1)*db_range*2,col);
      else
			plot3(data_freq(start_index:end_index)/1000,-data_ph_vel(start_index:end_index)/1000,ones(1,end_index-start_index+1)*db_range*2,col);
      end;
   end;
end;
plot3(freq/1000,zeros(size(freq))/1000,ones(size(freq))*db_range*2,'g');

axis([min(freq)/1000 max(freq)/1000 min(vph)/1000 max(vph)/1000]);

xlabel('Frequency (kHz)');
ylabel('Phase velocity (m/ms)');
zoom on;

%cross section at centre freq vs wavenumber
figure;
%plot(