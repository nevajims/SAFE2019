clear;
close all;
clc;
disp('Excitability Display');
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


%data_mode_list=[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20;1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]';
 
data_mode_list=[1,2,3,4,5,6,7,8,9,10;1,2,3,4,5,6,7,8,9,10]';
%trans_node_list=[63 53 306 72 107 139];% 251 279 241 409 151 197];
%trans_node_list=[53 306 72 107 139]; %for bs113a 5mm tapered mesh
%trans_node_list=[296 310 72 107 139]; %for bs113a 5mm tapered mesh 2013 transducer positions, not in the lower fillet
%trans_node_list=[8 46 63 72 80]; for CEN60 coarse
%trans_node_list=[153, 319, 329, 193, 216, 238];%, 118, 96, 73, 273, 258, 33];% for BS80 5mm tapered
%trans_node_list=[164, 302, 312, 171, 194, 215]%, 106, 85, 62, 252, 237, 55];% for NP46 5mm tapered
%trans_node_list=[282, 461, 471, 291, 327, 368]%, 182, 141 ,105 ,408 ,393, 96];% for 50E2 5mm tapered
%trans_node_list=[282, 467, 479, 291, 327, 367]%,  , , , , ];% for 54E1 5mm tapered
%trans_node_list=[393, 411, 105, 141, 181]%467, 479, 291, 327, 368];% for 56E1 5mm tapered
%trans_node_list=[421, 435, 257, 285, 317]%, , , , , ];% for 60E1 5mm tapered
trans_node_list=[80, 476, 141, 182, 212, 430, 400, 359, 535, 298]%, , , , , ];% for 50E2T1 5mm tapered
first_normalizing_index = 4;
first_graph_point = 0;
%first_graph_point = 16;
trans_node_index_in_perimeter_node_list=zeros(size(trans_node_list));
for count=1:length(trans_node_list);
    trans_node_index_in_perimeter_node_list(count)=find(data_perimeter_node_list(:)==trans_node_list(count));
end;
selected_node_index=1;
selected_node=data_perimeter_node_list(selected_node_index);
mesh_fig=figure(1);
set(mesh_fig,'Position',[400 300 540 400]);
mesh_handle=subplot('position',[0.125 0.125 0.75 0.75]);
hold on;
view1=[0 90];
scale=1;
marked_nodes=trans_node_list;
numbered_nodes=trans_node_list;
numbered_els=0;
use_tx_labels=1;
mesh_title=strcat('Mesh for: ',fname, ' with tx locations and node nos');
mesh_title=strcat('Mesh and Transducer Locations');
draw_mesh(data_nodes,data_els,marked_nodes,numbered_els,numbered_nodes,use_tx_labels,scale,mesh_handle,view1,mesh_title);
mode_colors='ymcrgbkymcrgbkymcrgbkymcrgbkymcrgbk';
excite_normal=zeros(size(data_mode_list,1),size(trans_node_list,1));
excite_torsional=zeros(size(data_mode_list,1),size(trans_node_list,1));
excite_axial=zeros(size(data_mode_list,1),size(trans_node_list,1));
node_count=1;
freq=16.0e3;
data_surface_axial=[0 0 1]; %this is set constant to make disp_axial=disp_z which must be true for all 2D models

for mode_count=1:length(data_mode_list);
    for node_count=1:length(data_perimeter_node_list)
        selected_node=data_perimeter_node_list(node_count);
        selected_mode=data_mode_list(mode_count,1);
        start_index=data_mode_start_indices(selected_mode);
        end_index=data_mode_start_indices(selected_mode+1)-1;
        %do the groovy monotonic thingy
	     temp=start_index;
   	  [start_index,end_index,inc]=smart_monotonic_range(data_freq(start_index:end_index));
        start_index=temp+start_index-1;
        end_index=temp+end_index-1;
        %calculate the x,y and z displacements for each perimeter node by interpolating the modeshapes
        disp_x=interp1(data_freq(start_index:end_index),data_ms_x(selected_node,start_index:end_index)',freq);
        disp_y=interp1(data_freq(start_index:end_index),data_ms_y(selected_node,start_index:end_index)',freq);
        disp_z=interp1(data_freq(start_index:end_index),data_ms_z(selected_node,start_index:end_index)',freq);
        %convert to normal, tangential and axial coordinates, note axial is the same as z in this case
        disp_normal=dot([disp_x disp_y disp_z], data_surface_normal(node_count,:));
        disp_tangent=dot([disp_x disp_y disp_z], data_surface_tangent(node_count,:));
        disp_axial=dot([disp_x disp_y disp_z], data_surface_axial);
        %Then use these displacements to calculate the excitabilities
        excite_normal(mode_count,node_count)=disp_normal^2*freq;
        excite_tangent(mode_count,node_count)=disp_tangent^2*freq;
        excite_axial(mode_count,node_count)=disp_axial^2*freq;
    end;
 end;
 %normalise the results to the largest of all mode/node combinations
 max_excitability=max([max(max(excite_normal(:,trans_node_index_in_perimeter_node_list(first_normalizing_index:length(trans_node_index_in_perimeter_node_list)))))...
       max(max(excite_tangent(:,trans_node_index_in_perimeter_node_list(first_normalizing_index:length(trans_node_index_in_perimeter_node_list)))))...
       max(max(excite_axial(:,trans_node_index_in_perimeter_node_list(first_normalizing_index:length(trans_node_index_in_perimeter_node_list)))))]);

 %max_excitability = max_excitability* 0.75;
 excite_normal=excite_normal/max_excitability;
 excite_tangent=excite_tangent/max_excitability;
 excite_axial=excite_axial/max_excitability;
 %Plot the results 
 for count=1:length(data_mode_list);
    i=figure(count+1);
    set(i,'Position',[400 300 540 400]);
    %Plot normal excite
    h=subplot(3,1,1);
    hold on;
    title(strcat('Mode number ',num2str(data_mode_list(count,2)),' at ',num2str(freq/1000),' kHz'));
    %title(strcat('Mode number: ',num2str(mode_list(count)),' at low frequency'));
    plot(excite_normal(count,:),'b.-');
    axis([first_graph_point length(data_perimeter_node_list)/2 0 1]);
    set(h,'xtick',-1);
    if (show_tx_locations~=0)
	    plot(trans_node_index_in_perimeter_node_list(:),(excite_normal(count,trans_node_index_in_perimeter_node_list(:))),'ro')
        for tx_count=1:length(trans_node_list)
            t=text(trans_node_index_in_perimeter_node_list(tx_count),-0.1,strcat('Tx',num2str(tx_count)));
            set(t,'HorizontalAlignment','center');
            set(t,'VerticalAlignment','middle');
            set(t,'Color','red')
        end;
    end;
    ylabel('Normal');
    %plot tangential excite
    h=subplot(3,1,2);
    hold on;
    plot(excite_tangent(count,:),'b.-');
    axis([first_graph_point length(data_perimeter_node_list)/2 0 1]);
    set(h,'xtick',-1);
    if (show_tx_locations~=0)
    	plot(trans_node_index_in_perimeter_node_list(:),(excite_tangent(count,trans_node_index_in_perimeter_node_list(:))),'ro')
        for tx_count=1:length(trans_node_list)
            t=text(trans_node_index_in_perimeter_node_list(tx_count),-0.1,strcat('Tx',num2str(tx_count)));
            set(t,'HorizontalAlignment','center');
            set(t,'VerticalAlignment','middle');
            set(t,'Color','red')
        end;
    end;
    ylabel('Tangential');
    %Plot axial excite
	h=subplot(3,1,3);
    hold on;
    plot(excite_axial(count,:),'b.-');
    axis([first_graph_point length(data_perimeter_node_list)/2 0 1]);
    set(h,'xtick',-1);
    if (show_tx_locations~=0)
	    plot(trans_node_index_in_perimeter_node_list(:),(excite_axial(count,trans_node_index_in_perimeter_node_list(:))),'ro')
        for tx_count=1:length(trans_node_list)
        t=text(trans_node_index_in_perimeter_node_list(tx_count),-0.1,strcat('Tx',num2str(tx_count)));
        set(t,'HorizontalAlignment','center');
        set(t,'VerticalAlignment','middle');
        set(t,'Color','red')
        end;
    end;
    ylabel('Axial');
    zoom on;
 end;
 
 no_tx_locations=length(trans_node_index_in_perimeter_node_list);		%number of unique tx locations
 i=figure;
 set(i,'Position',[400 300 540 400])
 %Plot normal excite
 for tx=1:no_tx_locations;
    h=subplot(no_tx_locations,1,tx);
    if tx==1;
        title(strcat('Normal Excitability at ',num2str(freq/1000),' kHz'));
        %title('Normal Excitability');
     end;
    hold on;
    bar(data_mode_list(:,1),excite_normal(data_mode_list(:,1),trans_node_index_in_perimeter_node_list(tx)))
    axis([0 length(data_mode_list)+1 0 1]);
    set(h,'xtick',-1)
    ylabel(strcat('Tx ',num2str(tx)));
 end;
 set(h,'xtick',data_mode_list(:,2));
 xlabel('Mode Number');
 i=figure;
 set(i,'Position',[400 300 540 400])
 %Plot tangential excite
 for tx=1:no_tx_locations;
    h=subplot(no_tx_locations,1,tx);
    if tx==1;
        title(strcat('Tangential Excitability at ',num2str(freq/1000),' kHz'));
        %title('Tangential Excitability')
     end;
    hold on;
    bar(data_mode_list(:,1),excite_tangent(data_mode_list(:,1),trans_node_index_in_perimeter_node_list(tx)))
    axis([0 length(data_mode_list)+1 0 1]);
    set(h,'xtick',-1)
    ylabel(strcat('Tx ',num2str(tx)));
 end;
 xlabel('Mode Number');
 set(h,'xtick',data_mode_list(:,2))
 i=figure;
 set(i,'Position',[400 300 540 400])
 %Plot axial excite
 for tx=1:no_tx_locations;
    h=subplot(no_tx_locations,1,tx);
    if tx==1;
        title(strcat('Axial Excitability at ',num2str(freq/1000),' kHz'));
        %title('Axial Excitability')
     end;
    hold on;
    bar(data_mode_list(:,1),excite_axial(data_mode_list(:,1),trans_node_index_in_perimeter_node_list(tx)))
    set(h,'xtick',-1)
    axis([0 length(data_mode_list)+1 0 1]);
    ylabel(strcat('Tx ',num2str(tx)));
 end;
 xlabel('Mode Number');
 set(h,'xtick',data_mode_list(:,2))



      

