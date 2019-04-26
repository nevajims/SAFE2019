function read_mesh_file;
%set defaults in case defaults file not found
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

%save(strcat(matlabroot,'\finel_defaults'),'default_*');

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
