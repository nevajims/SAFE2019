%get ready
clc;
clear;
close all;
disp('Finel 3D Mesh Processing');
disp('===== == ==== ==========');

%set defaults in case defaults filenot found
default_base_dir='g:\grail\matlab\fe-data';
default_mesh_fname='mesh.txt';
default_file_prefix='eigvec';
default_data_fname='result1';
default_dat_fname='10mm_tap';
if exist(strcat(matlabroot,'\finel_defaults.mat'))
   load(strcat(matlabroot,'\finel_defaults.mat'))
end;
if exist(strcat(default_base_dir,'\'),'dir');
    cd(default_base_dir);
end
%get data
temp='n';
while not(temp=='y');
   %get directory
   disp(' ');
   base_dir=input(strcat('3D Data directory [',strrep(default_base_dir,'\','\\'),']: '),'s');
   if size(base_dir,2)==0
      base_dir=default_base_dir;
   end;
   default_base_dir=base_dir;
      
   %append backslash if nesc
	if default_base_dir(size(default_base_dir,2))~='\'
   	default_base_dir=strcat(default_base_dir,'\');
   end;
   
   %list files in directory
   data_files=dir(strcat(default_base_dir,'*.txt'));
   disp(' ');
   data_no_files=size(data_files,1);
   for count=1:data_no_files;
      disp(strcat('    ',data_files(count).name));
   end;
   disp(' ');
   
   %get mesh file
   ok=0;
   while ~ok;
	   mesh_fname=input(strcat('Mesh file [',default_mesh_fname,']: '),'s');
   	if size(mesh_fname,2)==0
         mesh_fname=default_mesh_fname;
      end;
		if exist(strcat(default_base_dir,mesh_fname));
         ok=1;
         default_mesh_fname=mesh_fname;
      else
         ok=0;
         disp('File does not exist');
      end;
   end;
   
   
   %confirm
   disp(' ');
  	disp(strcat('About to process ',mesh_fname));
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%load the mesh file as one big matrix
temp=load(strcat(default_base_dir,default_mesh_fname),'-ascii');
data3d_no_nodes=temp(1,1);
data3d_no_els=temp(1,2);
data3d_no_nodes_per_element=temp(1,3);
data3d_no_dimensions=temp(1,4);
if (data3d_no_nodes<1)|(data3d_no_els<1)
   disp('Mesh file corrupt');
   return;
end;
disp(strcat('Number of nodes: ',num2str(data3d_no_nodes)));
disp(strcat('Number of elements: ',num2str(data3d_no_els)));
disp(strcat('Number of nodes per element: ',num2str(data3d_no_nodes_per_element)));
disp(strcat('This is a ',num2str(data3d_no_dimensions),'D model'));

%generate node matrix
data3d_nodes=temp(2:data3d_no_nodes+1,2:4);
%generte element matrix
if data3d_no_nodes_per_element<=4
   data3d_els(1:data3d_no_els,1:data3d_no_nodes_per_element)=temp(data3d_no_nodes+2:data3d_no_nodes+2+data3d_no_els-1,1:data3d_no_nodes_per_element);
elseif data3d_no_nodes_per_element<=8
   data3d_els(1:data3d_no_els,1:4)=temp(data3d_no_nodes+2:2:data3d_no_nodes+2+(data3d_no_els-1)*2,1:4);
   data3d_els(1:data3d_no_els,5:data3d_no_nodes_per_element)=temp(data3d_no_nodes+3:2:data3d_no_nodes+3+(data3d_no_els-1)*2,1:data3d_no_nodes_per_element-4);
else
   disp('Elements with more than 8 nodes are not currently supported');
   return;
end;
disp(' ');
temp='x';
while not((temp=='n')|(temp=='y'))
   temp='y';
   temp=input(strcat('Proceed [',temp,']? '),'s');
   if size(temp,2)==0
      temp='y';
   end;
end;
clc;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('Load mat file for 2d modeshapes');
disp('==== === ==== === == ==========');
load('g:\grail\matlab\fe-data\3d-models\10mm_tap.mat');
%first correct the node x coordinates to remove the radius 
temp=min(data_nodes(:,1));
data_nodes(:,1)=data_nodes(:,1)-temp;
maximums2D=max(data_nodes(:,:));
minimums2D=min(data_nodes(:,:));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%process the 3D mesh data
maximums3D=max(data3d_nodes(:,:));
minimums3D=min(data3d_nodes(:,:));
%check that meshes are the same size in the x-y plane
if round(sum(maximums3D(1:2)-maximums2D(1:2)));
   disp('Mesh cross sections are not compatable');
   break;
end;
%Set up the forcing%%%%%%%%%%%%%%%%%%%%%%%%%
coords='xyz';
forcing_modes=[3 5 7 8 10];
no_forcing_modes=length(forcing_modes);
forcing_z_location=0.0;
perimeter_forcing_only=0;
forcing_direction=[1 2 3];
forcing_phase=[0 0 90];
freq=15e3;
no_cycles=4;
%set up the monitoring%%%%%%%%%%%%%%%%%%%%%%
moni=1;
plot=0;
monitoring_z_location=[2.49 2.52 5.49 5.52]
perimeter_monitoring_only=1;
monitoring_direction=[3];
%set up the defect
if 0    %work out where the defect is
defect_axial_location=[4.9950 5.01];
%set up the joining vector
temp=find(data3d_nodes(:,3)==defect_axial_location(1));
joining_vector=zeros(size(temp,1),2);
joining_node_list(:,1)=find(data3d_nodes(:,3)==defect_axial_location(1));
joining_node_list(:,2)=find(data3d_nodes(:,3)==defect_axial_location(2));
%assuming that the nodes are in the same order for each region of the mesh writh the join commands to the file
end
tolerances=[0.001,0.001,0.0005];	%this should be set to less than half the smallest node spacing.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% setup complete now do the calculations%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
node_nos_2d=[1:data_no_nodes];
%find the forcing nodes and match them with the 2d model
forcing_node_list=find_cross_section_nodes(data3d_nodes,forcing_z_location,3,tolerances(3));
forcing_node_lookup=find_matching_nodes_xy(node_nos_2d,data_nodes,forcing_node_list,data3d_nodes(forcing_node_list,:),tolerances);
if ~min(min(forcing_node_lookup))
    disp('Warning: there are unmatched forcing nodes, the meshes are either incompatible or the tolerances are to small');
    break;
end;
%find the monitoring nodes
for location_no=1:length(monitoring_z_location)
    monitoring_node_list(location_no,:)=find_cross_section_nodes(data3d_nodes,monitoring_z_location(location_no),3,tolerances(3));
end
if ~length(monitoring_node_list)
    disp('Warning: there are no matching monitoring nodes, the tolerances are to small');
    break;
end;


%%%%%%%%%%%%%%%%%%%%open the blank dat file and read in the lines%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%list files in directory
data_files=dir(strcat(default_base_dir,'*.dat'));
disp(' ');
data_no_files=size(data_files,1);
for count=1:data_no_files;
    disp(strcat('    ',data_files(count).name));
end;
disp(' ');

%get dat file
ok=0;
while ~ok;
    blankdat_fname=input(strcat('Blank .dat file [all dat files]: '),'s');
    if size(blankdat_fname,2)
        if exist(strcat(default_base_dir,blankdat_fname));
            ok=1;
            data_files=dir(strcat(default_base_dir,blankdat_fname));
            data_no_files=1;
        else
            ok=0;
            disp('File does not exist');
        end;
    else
        ok=1;
    end
end;
for file_count=1:data_no_files;
    fid=fopen(strcat(default_base_dir,data_files(file_count).name),'r');
    nlines=1;
    temp=fgetl(fid);
    insert_forcing_line=0;
    insert_joining_line=0;
    while temp>=0
        if strcmp(':insert forcing',temp);
            insert_forcing_line=nlines;
        end;
        if strcmp(':insert joining',temp);
            insert_joining_line=nlines;
        end;
        temp=fgetl(fid);
        nlines=nlines+1;
    end
    nlines=nlines-1;
    fseek(fid,0,'bof');
    file_lines=cell(nlines,1);
    for count=1:nlines
        file_lines(count)={fgetl(fid)};
    end
    fclose(fid);
    for mode_count=1:no_forcing_modes
        mode_no=forcing_modes(mode_count);
        %%%%%%%%%%%%%%%%%%%%open the new  dat file and write the initial data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        newdat_fname=(strcat(default_base_dir,'mode',num2str(mode_no),'_',data_files(file_count).name));
        fid=fopen(newdat_fname,'w');
        fseek(fid,0,'bof');
        %%%%%%%%%%%%%%%%%%%% write the joining commands%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        current_line=1;
        if insert_joining_line
            for current_line=1:insert_joining_line-1
                fprintf(fid,'%s\n',char(file_lines(current_line)))
            end
            current_line=insert_joining_line+1
            fprintf(fid,'connect\n');
            for count=1:size(joining_node_list,1)
                if data3d_nodes(joining_node_list(count,1),1)<=1
                    fprintf(fid,'nodes\t%i\t%i\n',joining_node_list(count,1),joining_node_list(count,2));
                end
            end
        end
        if insert_forcing_line
            for current_line=current_line:insert_forcing_line-1
                fprintf(fid,'%s\n',char(file_lines(current_line)));
            end
            current_line=insert_forcing_line+1
        end
        
        %%%%%%%%%%%%%%%%%%%% write the forcing commands%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if insert_forcing_line
            if perimeter_forcing_only
                forcing_node_lookup=[forcing_node_lookup(data_perimeter_node_list(:),1) forcing_node_lookup(data_perimeter_node_list(:),2)];
            end
            [start_index,end_index]=get_good_mode_indices(mode_no,data_freq,data_mode_start_indices);
            fprintf(fid,'renumber\n');
            fprintf(fid,'assemble stiffness diagonal mass\n');
            fprintf(fid,'echo on\n');
            fprintf(fid,'awave\n');
            fprintf(fid,'step time 0.0 5.0e-3 0.75e-6\n');
            fprintf(fid,':Forcing mode %i at %f kHz at %2.2f m\n',mode_no,freq/1000,forcing_z_location);
            fprintf(fid,'step cycle\t%6.0f\t%i\n',freq,no_cycles);
            displacements=[interp1(data_freq(start_index:end_index),data_ms_x(:,start_index:end_index)',freq)',...
                    interp1(data_freq(start_index:end_index),data_ms_y(:,start_index:end_index)',freq)',...
                    interp1(data_freq(start_index:end_index),data_ms_z(:,start_index:end_index)',freq)'];
            for count1=1:size(forcing_node_lookup,1)
                node_count=forcing_node_lookup(count1,1);
                for count2=1:length(forcing_direction)
                    coord=forcing_direction(count2);
                    fprintf(fid,'step frce\t%E\t%3.1f\t%i\t%c\n',displacements(node_count,coord),forcing_phase(coord),forcing_node_lookup(count1,2),coords(coord));
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%% write the monitoring commands %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if moni
            monitoring_nodes_plot=0;
            for location_no=1:length(monitoring_z_location)
                monitoring_node_lookup=find_matching_nodes_xy(node_nos_2d,data_nodes,monitoring_node_list(location_no,:),data3d_nodes(monitoring_node_list(location_no,:),:),tolerances);
                if perimeter_monitoring_only
                    monitoring_node_lookup=[monitoring_node_lookup(data_perimeter_node_list(:),1) monitoring_node_lookup(data_perimeter_node_list(:),2)];
                end
                fprintf(fid,':Monitoring perimeter nodes at %2.3f m\n',monitoring_z_location(location_no));
                for count1=1:size(monitoring_node_lookup,1)
                    for count2=1:length(monitoring_direction)
                        coord=monitoring_direction(count2);
                        fprintf(fid,'step moni\t%i\t%c\n',monitoring_node_lookup(count1,2),coords(coord));
                    end
                end
                if monitoring_nodes_plot
                    monitoring_nodes_plot=[monitoring_nodes_plot,monitoring_node_lookup(:,2)];
                else
                    monitoring_nodes_plot=monitoring_node_lookup(:,2);
                end
            end
            for count3=1:length(forcing_direction)
                fprintf(fid,'step moni\t%i\t%c\n',forcing_node_lookup(1),coords(forcing_direction(count3))); %monitor one of the excitation nodes just in case
            end
        end
        %%%%%Write the end of the dat file%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf(fid,':\n');
        fprintf(fid,'step samp 5 50000\n');
        fprintf(fid,'step mcon 2 1 1	;Hanning windowed toneburst\n');
        fprintf(fid,'step format 2\n');
        fprintf(fid,'echo off\n');
        fprintf(fid,':\n');
        fprintf(fid,'end job\n');
        fprintf(fid,'\n');
        fclose(fid);
    end
end
%%%%% plot the mesh if required%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if plot
    figure(1);hold on;
    mesh_fig=subplot('position',[0.125 0.125 0.75 0.75]);
    chart_title='Mesh';
    scale=256;
    view_pos=3;
    draw_mesh_3D(data3d_nodes,data3d_els,0,forcing_node_lookup(:,2),monitoring_nodes_plot,0,scale,mesh_fig,view_pos,chart_title);
end
fclose all
end      