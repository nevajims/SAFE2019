%loads file specified by current variable exp_fname
%returns: 	in_time_data = matrix of time traces in colmns
%				tx_row = row vector of transmitter rows
%				tx_pos = row vector of transmitter positions around rail
%				rx_row = row vector of receiver rows
%				rx_pos = row vector of receiver positions around rail
%				in_time = column vector of times
%				in_freq = centre frequency of excitation signal
%				in_cycles = cycles in excitation signal
temp_fid=fopen(exp_fname,'rt');
fgetl(temp_fid);
fgetl(temp_fid);
temp_x=fgetl(temp_fid);%this line has centre frequency and number of cycles
in_freq=sscanf(temp_x(findstr(temp_x,'Excitation')+length('Excitation')+1:findstr(temp_x,'kHz')-1),'%f')*1e3;
in_cycles=sscanf(temp_x(findstr(temp_x,'kHz')+length('kHz')+1:findstr(temp_x,'cycle')-1),'%f');
fgetl(temp_fid);
fgetl(temp_fid);
fgetl(temp_fid);
fgetl(temp_fid);
%temp_x=fgetl(temp_fid);%this line says how many cols
%temp_rows=sscanf(temp_x,'%f');
%temp_cols=sscanf(temp_x(findstr(temp_x,'(')+1:findstr(temp_x,'cols')-1),'%f');

temp_x=fgetl(temp_fid);%this line has the transmitter locations
temp_txs=sscanf(temp_x,'%f',inf);
temp_txs=temp_txs(3:length(temp_txs));
temp_x=fgetl(temp_fid);%this line has the receiver locations
temp_rxs=sscanf(temp_x,'%f',inf);
temp_rxs=temp_rxs(3:length(temp_rxs));
tx_pos=floor(temp_txs);
tx_row=round((temp_txs-tx_pos)*100);
rx_pos=floor(temp_rxs);
rx_row=round((temp_rxs-rx_pos)*100);
tx_row(find(tx_row>=10)) = round(tx_row/10);
rx_row(find(rx_row>=10)) = round(rx_row/10);
keyboard;
in_no_time_traces = length(tx_pos);
temp_data=fscanf(temp_fid,'%f',inf);
in_no_time_pts = length(temp_data)/(in_no_time_traces+1);
if round(in_no_time_pts)~=in_no_time_pts
   disp('Error in file');
	keyboard;
end;
temp_data=reshape(temp_data,in_no_time_traces+2,in_no_time_pts)';
in_time=temp_data(:,1);
%%in_time_data=temp_data(:,2:in_no_time_traces+1);
in_time_data=temp_data(:,3:in_no_time_traces+1);    %%changed to ignore the zero column
fclose(temp_fid);
% clear temp_*;
return;
