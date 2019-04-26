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
find_surface_nodes=1;
find_surface_els=0;
if find_surface_nodes
    %first find all the edge/corner and surface nodes
    node_occurances=zeros([data3d_no_nodes,1]);
    for element_no=1:data3d_no_els
        for local_node_no=1:data3d_no_nodes_per_element
            node_occurances(data3d_els(element_no,local_node_no))=node_occurances(data3d_els(element_no,local_node_no))+1;
        end;
    end;
    edge_nodes=0;
    surface_nodes=0;
    for node_no=1:data3d_no_nodes;
        if node_occurances(node_no)<=3|node_occurances(node_no)==6
            if edge_nodes==0
                edge_nodes=node_no;
            else
                edge_nodes=[edge_nodes,node_no];
            end
        end
        if node_occurances(node_no)<=4|node_occurances(node_no)==6
            if surface_nodes==0
                surface_nodes=node_no;
            else
                surface_nodes=[surface_nodes,node_no];
            end
        end
    end
end
%Then work out which elements are on the edges and surface
edge_els=0;
surface_els=0;
if find_surface_els
    for element_no=1:data3d_no_els
        if sum(ismember(node_occurances(data3d_els(element_no,:)),[1 2 3 6 5 7]))
            if edge_els==0
                edge_els=element_no;
            else
                edge_els=[edge_els,element_no];
            end
        end
        if sum(ismember(node_occurances(data3d_els(element_no,:)),[4]))
            if surface_els==0
                surface_els=element_no;
            else
                surface_els=[surface_els,element_no];
            end
        end
    end;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load('g:\grail\matlab\fe-data\2d-models\10mm_tap.mat'); % Load the 2d file data for the same mesh density
radius_2d=min(data_nodes(:,1));
data_nodes(:,1)=data_nodes(:,1)-radius_2d;
tolerance=0.0001;
data_nodes=round(data_nodes./tolerance)*tolerance;
data3d_nodes=round(data3d_nodes./tolerance)*tolerance; %set 5 significant figures to the node coordinates
run('new_prototype'); % load the hardware definition file
trans_firstrow_position=3; %position of the first row in meters, this is specified in the .dat file which created the mesh file
trans_row_pos = trans_row_pos+(83*1e-3+trans_firstrow_position);
%find which transducers are in use and what their numbers are and sort them into numerical order if required, otherwise number them by row (1-5), and position (1,12)
[column_index,row_index,num]=find(trans_num');
sort_into_tx_no_order=0;
sorted_num=num;
sort_index=1:length(num);
if sort_into_tx_no_order==1
    [sorted_num,sort_index]=sort(num);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
trans_nodes_3d=zeros(size(trans_row_pos,2),size(trans_node_list_coarse_mesh,2));
for trans_row_index=1:size(trans_row_pos,2)
    current_trans_row_pos=trans_row_pos(trans_row_index);
    cross_section_node_list=find_cross_section_nodes(data3d_nodes,current_trans_row_pos,3,0.001);
    %find nodes in the 3d mesh which correspond to each transducer
    for trans_node_index_2d=1:size(trans_node_list_coarse_mesh,2);
        temp1=data3d_nodes(cross_section_node_list,1)==(data_nodes(trans_node_list_coarse_mesh(trans_node_index_2d),1))&data3d_nodes(cross_section_node_list,2)==data_nodes(trans_node_list_coarse_mesh(trans_node_index_2d),2);
        if sum(temp1)==0
            disp('No nodes in the 3d mesh correspond to transducer locations')
        end
        if sum(temp1)>1
            disp('More that one node in the 3d mesh correspond to transducer locations')
        end
        trans_nodes_3d(trans_row_index,trans_node_index_2d)=cross_section_node_list(find(temp1));
    end
end
%write the supporting node commands
fprintf(1,'support\n')
support_node_coordinates=[0 0.07,0; 0,-0.07,0; 0.16,0,0];
support_nodes=zeros(size(support_node_coordinates,1),1);
zero_plane_node_list=find_cross_section_nodes(data3d_nodes,0.0,3,tolerance);
for support_node_index=1:size(support_node_coordinates,1)
    support_nodes(support_node_index)=zero_plane_node_list(find(data3d_nodes(zero_plane_node_list,1)==support_node_coordinates(support_node_index,1)&data3d_nodes(zero_plane_node_list,2)==support_node_coordinates(support_node_index,2)));
    fprintf('\tpoint\t%i\tz\n',support_nodes(support_node_index));
end
fprintf('renumber\n');
fprintf('assemble stiffness diagonal mass\n');
fprintf('echo on\n');
fprintf('awave\n');
fprintf('step time 0.0 7.5e-3 0.75e-6\n');
fprintf('step cycle\t15000\t4\n',support_nodes(support_node_index));
%write the forcing commands
num_frce_nodes=length(sorted_num); %how many transducers are there
for frce_node_index=1:num_frce_nodes %take each in numerical order
    sorted_index=sort_index(frce_node_index);
    trans_number=num(sorted_index);
    current_row_index=row_index(sorted_index);
    current_column_index=column_index(sorted_index);
    current_trans_nodes_3d=trans_nodes_3d(current_row_index,current_column_index);
    %disp(strcat('Transducer number',num2str(trans_number),'is position',num2str(current_column_index),'on row',num2str(current_row_index)));
    %fprintf(1,'step node\t%E\t%i\t%c\t%s\n',1.0,current_trans_nodes_3d,'z',strcat(';transducer number',num2str(trans_number)));
    fprintf(1,'step frce\t%E\t%3.1f\t%i\t%c\t%s\n',1.0,0.0,current_trans_nodes_3d,'z',strcat(';transducer number',num2str(trans_number)));
end

%write the pulse echo monitoring commands
fprintf(1,':The pulse-echo monitoring nodes\n')
num_moni_nodes=length(sorted_num); %how many transducers are there
for moni_node_index=1:num_moni_nodes %take each in numerical order
    sorted_index=sort_index(moni_node_index);
    trans_number=num(sorted_index);
    current_row_index=row_index(sorted_index);
    current_column_index=column_index(sorted_index);
    current_trans_nodes_3d=trans_nodes_3d(current_row_index,current_column_index);
    %disp(strcat('Transducer number',num2str(trans_number),'is position',num2str(current_column_index),'on row',num2str(current_row_index)));
    fprintf(1,'step moni\t%i\t%c\n',current_trans_nodes_3d,'z');
end

%write the pitch catch monitoring commands
fprintf(1,':The pitch-catch monitoring nodes\n')
num_moni_nodes=length(sorted_num); %how many transducers are there
for moni_node_index=1:num_moni_nodes %take each in numerical order
    sorted_index=sort_index(moni_node_index);
    trans_number=num(sorted_index);
    current_row_index=row_index(sorted_index);
    current_column_index=column_index(sorted_index);
    current_trans_nodes_3d=trans_nodes_3d(current_row_index,current_column_index);
    %disp(strcat('Transducer number',num2str(trans_number),'is position',num2str(current_column_index),'on row',num2str(current_row_index)));
    fprintf(1,'step moni\t%i\t%c\n',(current_trans_nodes_3d+1230),'z');
end



figure(1);hold on;
mesh_fig=subplot('position',[0.125 0.125 0.75 0.75]);
chart_title='Mesh';
scale=256;
view_pos=2;

nodes_to_plot=1:data3d_no_nodes;
if data3d_no_nodes>500
    nodes_to_plot=surface_nodes;
end
if data3d_no_nodes>1000
    nodes_to_plot=edge_nodes;
end
trans_nodes_to_plot=trans_nodes_3d(1:size(trans_nodes_3d,1)*size(trans_nodes_3d,2));
moni_nodes_to_plot=trans_nodes_to_plot+1230;
draw_mesh_3D(data3d_nodes,data3d_els,nodes_to_plot,0,trans_nodes_to_plot,moni_nodes_to_plot,support_nodes,scale,mesh_fig,view_pos,chart_title);