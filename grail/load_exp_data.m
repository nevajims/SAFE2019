%NB this file currently has a bodge in it to fill up the txand rx indices where they are missing in spectrum
%this includes the missing row 10 data. When row 10 data is reinstated and indices are exported properly,
%put in return before bodge lines at end of this file


%loads file specified by current variable fname
%returns: 	in_time_data = matrix of time traces in colmns
%				tx_row = row vector of transmitter rows
%				tx_pos = row vector of transmitter positions around rail
%				rx_row = row vector of receiver rows
%				rx_pos = row vector of receiver positions around rail
%				in_time = column vector of times
%				in_freq = centre frequency of excitation signal
%				in_cycles = cycles in excitation signal
temp_fid=fopen(fname,'rt');
fgetl(temp_fid);
fgetl(temp_fid);
temp_x=fgetl(temp_fid);%this line has centre frequency and number of cycles
in_freq=sscanf(temp_x(findstr(temp_x,'Excitation')+length('Excitation')+1:findstr(temp_x,'kHz')-1),'%f')*1e3;
in_cycles=sscanf(temp_x(findstr(temp_x,'kHz')+length('kHz')+1:findstr(temp_x,'cycle')-1),'%f');
fgetl(temp_fid);
fgetl(temp_fid);
fgetl(temp_fid);
temp_x=fgetl(temp_fid);%this line says hpow many cols
temp_rows=sscanf(temp_x,'%f');
temp_cols=sscanf(temp_x(findstr(temp_x,'(')+1:findstr(temp_x,'cols')-1),'%f');
temp_x=fgetl(temp_fid);%this line has the transmitter locations
temp_txs=sscanf(temp_x,'%f',inf);
temp_txs=temp_txs(2:length(temp_txs));
temp_x=fgetl(temp_fid);%this line has the receiver locations
temp_rxs=sscanf(temp_x,'%f',inf);
temp_rxs=temp_rxs(2:length(temp_rxs));
tx_pos=floor(temp_txs);
tx_row=round((temp_txs-tx_pos)*100);
rx_pos=floor(temp_rxs);
rx_row=round((temp_rxs-rx_pos)*100);
fgetl(temp_fid);
fgetl(temp_fid);
temp_data=fscanf(temp_fid,'%f',inf);
if length(temp_data)<(temp_cols*temp_rows);
   temp_data=[temp_data;zeros(temp_cols*temp_rows-length(temp_data),1)];
end;
temp_data=reshape(temp_data,temp_cols,temp_rows)';
in_time=temp_data(:,1);
in_time_data=temp_data(:,2:temp_cols);
in_no_time_traces=size(in_time_data,2);
in_no_time_pts=size(in_time_data,1);
fclose(temp_fid);
clear temp_*;
%create look up and reverse loop up table for single vector of all transducers
trans_row_lookup=[ones(1,4),ones(1,4)*2,ones(1,6)*3,ones(1,6)*4,ones(1,6)*5,ones(1,6)*6,ones(1,6)*7,ones(1,6)*8,ones(1,4)*9,ones(1,4)*10];
trans_pos_lookup=[3,5,8,10, 3,5,8,10, 2,4,6,7,9,11, 2,4,6,7,9,11, 2,4,6,7,9,11, 2,4,6,7,9,11, 2,4,6,7,9,11, 2,4,6,7,9,11, 3,5,8,10, 3,5,8,10];
in_time=[0;in_time(1:length(in_time)-1)];
%bodge for current errors in spectrum files, incl no reception on row 10;
%when spectrum fixed delete % sign at start of next line
return;

count=1;
for tx_row_count=1:5;
   for rx_row_count=6:9;
      if (tx_row_count==1)|(tx_row_count==2);
         tx_pos_indices=[3,5,10,8];
         for tx_pos_count=1:4;
            if (rx_row_count==9)|(tx_row_count==10);
               rx_pos_indices=[3,5,10,8];
               for rx_pos_count=1:4;
						tx_pos(count)=tx_pos_indices(tx_pos_count);
                  rx_pos(count)=rx_pos_indices(rx_pos_count);
                  tx_row(count)=tx_row_count;
                  rx_row(count)=rx_row_count;
                  count=count+1;
               end;
            else
               rx_pos_indices=[2,4,6,11,9,7];
               for rx_pos_count=1:6;
						tx_pos(count)=tx_pos_indices(tx_pos_count);
                  rx_pos(count)=rx_pos_indices(rx_pos_count);
                  tx_row(count)=tx_row_count;
                  rx_row(count)=rx_row_count;
                  count=count+1;
               end;
            end;
         end;
      else
         tx_pos_indices=[2,4,6,11,9,7];
         for tx_pos_count=1:6;
            if (rx_row_count==9)|(tx_row_count==10);
               rx_pos_indices=[3,5,10,8];
               for rx_pos_count=1:4;
						tx_pos(count)=tx_pos_indices(tx_pos_count);
                  rx_pos(count)=rx_pos_indices(rx_pos_count);
                  tx_row(count)=tx_row_count;
                  rx_row(count)=rx_row_count;
                  count=count+1;
               end;
            else
               rx_pos_indices=[2,4,6,11,9,7];
               for rx_pos_count=1:6;
						tx_pos(count)=tx_pos_indices(tx_pos_count);
                  rx_pos(count)=rx_pos_indices(rx_pos_count);
                  tx_row(count)=tx_row_count;
                  rx_row(count)=rx_row_count;
                  count=count+1;
               end;
            end;
         end;
      end;
   end;
end;

        
    