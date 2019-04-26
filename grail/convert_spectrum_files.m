%this will read all spectrum files matching mask
%extract transmitter, receiver
%and save the lot in matlab matrices

source_dir='n:\grail\exp-results\connington\10mweb\';
output_dir='n:\grail\matlab\exp-data\connington-april01\';

fname_mask='TX_*_RX_*-15kHz-4cyc-comptran.tim';
output_fname='20m-sep-15khz-4cycles-to-20ms-web-comp';

chop_after_time=20e-3;%set negative to store complete time traces
transmitter_prefix='TX_';
transmitter_suffix='_';
receiver_prefix='RX_';
receiver_suffix='-';

pad=0;
trans_pos=[2:11];

%build file list
spec_files=dir(strcat(source_dir,fname_mask));
exp_no_files=size(spec_files,1)
exp_cent_freq=15e3;
exp_cycles=4;


fcount=1;
for file_count=1:exp_no_files;
   fname=strcat(source_dir,spec_files(file_count).name);
   [temp_data, temp_no_pts, temp_time_step, time_origin, comments, result] = read_spectrum_file(fname);
   skip=0;
   %check for dud file
   if (temp_time_step==0)|(temp_no_pts==0)
      skip=1;
   end;
	tx=number_from_string(fname,transmitter_prefix,transmitter_suffix);
   rx=number_from_string(fname,receiver_prefix,receiver_suffix);
   if (tx<1)|(tx>12)|(rx<1)|(rx>12);
      skip=1;
   end;
	ft=str2num(spec_files(file_count).date(13:14))*3600 ...
         +str2num(spec_files(file_count).date(16:17))*60 ...
         +str2num(spec_files(file_count).date(19:20));
	%default
	index=fcount;
   %check for duplicates
   for count=1:fcount-1;
      if (tx==exp_trans(1,count))&(rx==exp_trans(2,count));
         %duplicate found - compare times
         if ftime(count)>ft;
            skip=1;%existing data is more recent
         else
            index=count;%existing data is older so overwrite it
            fcount=fcount-1;
         end;
         break;
      end;
   end;
   
         
   if ~skip;
      %if first time, set up arrays
	   if fcount==1;
   	   if chop_after_time<0
      	   exp_no_pts=temp_no_pts;
	      else
   	      exp_no_pts=round((chop_after_time-time_origin)/temp_time_step);
      	end;
	      exp_time_step=temp_time_step;
   	   exp_values=zeros(exp_no_pts,exp_no_files); %each column is a time trace
      	exp_trans=zeros(2,exp_no_files); %first row is transmitter, second is receiver
	 	   ftime=zeros(1,exp_no_files);
       end;
		if ~(tx==4);
         exp_values(:,index)=temp_data(1:exp_no_pts,1);
      else;
         exp_values(:,index)=-temp_data(1:exp_no_pts,1);
		end;         
   	exp_trans(1,index)=tx;
	   exp_trans(2,index)=rx;
		ftime(index)=ft;
      disp(strcat('File #',num2str(file_count)));
      disp(strcat('Index ',num2str(fcount)));
		fcount=fcount+1;
   end;
end;


exp_no_files=fcount-1;
exp_values=exp_values(:,1:exp_no_files);
exp_trans=exp_trans(:,1:exp_no_files);
ftime=ftime(:,1:exp_no_files);

if pad;
   temp_exp_values=exp_values;
   temp_exp_trans=exp_trans;
   exp_no_files=length(trans_pos)^2;
   exp_trans=zeros(2,exp_no_files);
   exp_values=zeros(exp_no_pts,exp_no_files);
   for count1=1:length(trans_pos);
      for count2=1:length(trans_pos);
         exp_trans(1,(count1-1)*length(trans_pos)+count2)=trans_pos(count1);
         exp_trans(2,(count1-1)*length(trans_pos)+count2)=trans_pos(count2);
      end;
   end;
   for count1=1:size(exp_trans,2);
      tx=exp_trans(1,count1);
      rx=exp_trans(2,count1);
      index1=0;
      index2=0;
      for count2=1:size(temp_exp_values,2);
         if (tx==temp_exp_trans(1,count2))&(rx==temp_exp_trans(2,count2));
            index1=count2;
         end;
         if (rx==temp_exp_trans(1,count2))&(tx==temp_exp_trans(2,count2));
            index2=count2;
         end;
      end;
      
      if (index1==0);
         index1=index2;
      end;
      
		if index1~=0;         
         exp_values(:,count1)=temp_exp_values(:,index1);
      end;
   end;
end;

save(strcat(output_dir,output_fname),'exp_*');