clear;
close all;
clc;
disp('Mesh Display');
disp('==== =======');

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
mesh_handle=subplot('position',[0.125 0.125 0.75 0.75]);
view1=[0 90];
scale=1;

marked_nodes=[1];
%numbered_nodes=1:size(data_nodes,1);
%numbered_nodes=data_perimeter_node_list(:);
numbered_nodes= [153, 319, 329, 193, 216, 238, 118, 96, 73, 273, 258, 33];
numbered_els=0;
draw_mesh(data_nodes,data_els,marked_nodes,numbered_els,numbered_nodes,1,scale,mesh_handle,view1,'Mesh');
%quiver3(data_nodes(data_perimeter_node_list(:,1),1),data_nodes(data_perimeter_node_list(:,1),2),data_nodes(data_perimeter_node_list(:,1),3),...
%    data_surface_tangent(:,1),data_surface_tangent(:,2),data_surface_tangent(:,3))

