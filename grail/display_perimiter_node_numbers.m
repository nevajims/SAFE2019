clear;
close all;
clc;
disp('Perimeter Node Display');
disp('============ =======');

%set defaults in case defaults filenot found
default_base_dir=pwd;
default_data_fname='result1';
show_tx_locations = 1;

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

first_normalizing_index = 4;
first_graph_point = 0;
%first_graph_point = 16;
mesh_fig=figure(1);
set(mesh_fig,'Position',[400 300 540 400]);
mesh_handle=subplot('position',[0.125 0.125 0.75 0.75]);
hold on;
view1=[0 90];
scale=1;
marked_nodes=0;
numbered_nodes=data_perimeter_node_list;
numbered_els=0;
use_tx_labels=0;
mesh_title=strcat('Mesh for: ',fname, ' with tx locations and node nos');
mesh_title=strcat('Mesh and Perimeter node numbers');
draw_mesh(data_nodes,data_els,marked_nodes,numbered_els,numbered_nodes,use_tx_labels,scale,mesh_handle,view1,mesh_title);
