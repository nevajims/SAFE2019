%get ready
clc;
clear;
close all;
disp('Finel 3D Mesh Processing');
disp('===== == ==== ==========');

%set defaults in case defaults filenot found
default_dispout_dir='g:\grail\matlab\fe-data';
default_dispout_fname='fe77loop.out';
if exist(strcat(matlabroot,'\finel_defaults.mat'))
    load(strcat(matlabroot,'\finel_defaults.mat'))
end;


if ~exist(default_dispout_dir,'dir')
    default_dispout_dir='g:\grail\matlab\fe-data';
end
cd(default_dispout_dir);

%get data
temp='n';
while not(temp=='y');
    %get directory
    disp(' ');
    fe77_dir=input(strcat('Disp.out file directory [',strrep(default_dispout_dir,'\','\\'),']: '),'s');
    if size(fe77_dir,2)==0
        fe77_dir=default_dispout_dir;
    end;
    default_dispout_dir=fe77_dir;
    
    %append backslash if nesc
    if default_dispout_dir(size(default_dispout_dir,2))~='\'
        default_dispout_dir=strcat(default_dispout_dir,'\');
    end;
    
    %list files in directory
    data_files=dir(strcat(default_dispout_dir,'*.out'));
    disp(' ');
    data_no_files=size(data_files,1);
    for count=1:data_no_files;
        disp(strcat('    ',data_files(count).name));
    end;
    disp(' ');
    default_option=1;
    option=input(strcat('1. Specify file 2. All files in directory [',num2str(default_option),']: '));
    if size(option)==0|~ismember(option,[1 2])
        option=default_option;
    end
    if option==1 
        %get file name
        ok=0;
        while ~ok;
            dispout_fname=input(strcat('Disp.out file [',default_dispout_fname,']: '),'s');
            if size(dispout_fname,2)==0
                dispout_fname=default_dispout_fname;
            end;
            if exist(strcat(default_dispout_dir,dispout_fname));
                ok=1;
                default_dispout_fname=dispout_fname;
            else
                ok=0;
                disp('File does not exist');
            end;
        end;
    end
    save(strcat(matlabroot,'\finel_defaults'),'default_*');
    temp='y';
end
default_step_format=2;
default_max_time_points=10000;
ok=0;
while ~ok;
    step_format=str2num(input(strcat('Step format of file (0 or 2) [',num2str(default_step_format),']: '),'s'));
    if size(step_format,2)==0
        step_format=default_step_format;
    end;
    if ismember(step_format,[0 2])
        ok=1;
    end
end;

ok=0;
while ~ok;
    max_time_points=str2num(input(strcat('Maximum number of time points to read [',num2str(default_max_time_points),']: '),'s'));
    if size(max_time_points,2)==0
        max_time_points=default_max_time_points;
    end;
    if max_time_points
        ok=1;
    end
end;
if option==1
    load(disp_out_read(strcat(default_dispout_dir,default_dispout_fname),max_time_points,step_format));
    disp('Monitoring node_numbers:');
    disp(dispout_nodes);
    
end
if option==2
    for count=1:data_no_files
        disp(strcat('Procesing file:    ',data_files(count).name,' : ',num2str(data_no_files-count),' remaining files'));
        disp_out_read(strcat(default_dispout_dir,data_files(count).name),max_time_points,step_format);                                        
    end
end


  