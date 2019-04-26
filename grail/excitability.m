clear;
close all;
clc;
disp('Excitability Display');
disp('============ =======');

%set defaults in case defaults filenot found
default_base_dir=pwd;
default_data_fname='result1';

if exist(strcat(matlabroot,'\finel_defaults.mat'))
   load(strcat(matlabroot,'\finel_defaults.mat'))
end;

cd(default_base_dir);

%get data
temp='n';
while not(temp=='y');
   %get directory
   disp(' ');
   base_dir=input(strcat('Data directory [',strrep(default_base_dir,'\','\\'),']: '),'s');
   if size(base_dir,2)==0
      base_dir=default_base_dir;
   end;
   default_base_dir=base_dir;
      
   %append backslash if nesc
	if default_base_dir(size(default_base_dir,2))~='\'
   	default_base_dir=strcat(default_base_dir,'\');
   end;
   
   %list files in directory
   data_files=dir(strcat(default_base_dir,'*.mat'));
   disp(' ');
   data_no_files=size(data_files,1);
   for count=1:data_no_files;
      disp(strcat('    ',num2str(count),'. ',data_files(count).name));
   end;
   disp(' ');
   
	%get data file
   ok=0;
   while ~ok;
	   data_fname=input(strcat('Data file [',default_data_fname,']: '),'s');
   	if size(data_fname,2)==0
         data_fname=default_data_fname;
      end;
		if exist(strcat(default_base_dir,data_fname,'.mat'));
         ok=1;
         default_data_fname=data_fname;
      else
         ok=0;
         disp('File does not exist');
      end;
   end;
     
   fname=strcat(default_base_dir,default_data_fname);
   disp(strcat('About to load: ',fname));
   disp(' ');
   
	temp='x';
   while not((temp=='n')|(temp=='y'))
      temp='y';
      temp=input(strcat('Proceed [',temp,']? '),'s');
      if size(temp,2)==0
         temp='y';
      end;
	end;
end;

save(strcat(matlabroot,'\finel_defaults'),'default_*');

load(fname);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clf;
hold on;
axis equal;
no_data_els=size(data_els,1);
figure(1);
for count=1:no_data_els;
	temp=[	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3);
 		data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),data_nodes(data_els(count,2),3);
      data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),data_nodes(data_els(count,4),3);
      data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2),data_nodes(data_els(count,3),3);
     	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3)];   
	   plot3(temp(:,1),temp(:,2),temp(:,3),'b');
end;
mode_no=1;
initial_direction=1;
selected_node_no=1;
plot3(data_nodes(selected_node_no,1),data_nodes(selected_node_no,2),data_nodes(selected_node_no,3),'ro');
mode_colors='ymcrgbkymcrgbkymcrgbkymcrgbkymcrgbk';
power_flow=zeros(1,size(data_freq,1));
excite=zeros(1,size(data_freq,1));
for mode_count=1:data_no_modes;
   col=strcat(mode_colors(mode_count),'.-');
	hold on;
	figure(2);
   start_index=data_mode_start_indices(mode_count);
   end_index=data_mode_start_indices(mode_count+1)-1;
   excite_x(1,start_index:end_index)=...
      abs((data_ms_x(selected_node_no,start_index:end_index) .^ 2 .* ...
	   data_freq(start_index:end_index)' ...
      ));
   excite_y(1,start_index:end_index)=...
      abs((data_ms_y(selected_node_no,start_index:end_index) .^ 2 .* ...
	   data_freq(start_index:end_index)' ...
      ));
   excite_z(1,start_index:end_index)=...
      abs((data_ms_z(selected_node_no,start_index:end_index) .^ 2 .* ...
	   data_freq(start_index:end_index)' ...
      ));
   plot(data_freq(start_index:end_index)/1000,excite_y(start_index:end_index),col);
end;
axis([0 20 0 3e-5]);
zoom on;
xlabel('Frequency (kHz)');
ylabel('Excitability (linear)');

for mode_count=1:data_no_modes;
   col=strcat(mode_colors(mode_count),'.-');
	hold on;
	figure(3);
   start_index=data_mode_start_indices(mode_count);
   end_index=data_mode_start_indices(mode_count+1)-1;
   plot(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,col);
end;
axis([0 20 0 10]);
zoom on;
xlabel('Frequency (kHz)');
ylabel('Phase Velocity');

