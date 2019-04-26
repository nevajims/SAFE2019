%get ready
clc;
clear;
close all;
disp('Finel 3D Mesh Processing');
disp('===== == ==== ==========');

%set defaults in case defaults filenot found
default_base_dir='n:\grail\matlab\fe-data';
default_mesh_fname='mesh.txt';
default_file_prefix='eigvec';
default_data_fname='result1';
default_dat_fname='10mm_tap';
if exist(strcat(matlabroot,'\finel_defaults.mat'))
   load(strcat(matlabroot,'\finel_defaults.mat'))
end;
cd(default_base_dir);
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
defect_location=[5.025,3]%[4.995,3]; %this gives the position of the defect in metres followed by the axis perpendicular to the defect plane (1=x, 2=y, 3=z)
defect_plane=find(~ismember([1,2,3],defect_location(2)));
crack_opening=0.001; %this is the largest opening of the crack in metres(usually 1mm)
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if 0
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
%Then work out which elements are on the edges and surface
edge_els=0;
surface_els=0;
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
%find all the nodes at the defect plane which are surface nodes and belong to elements on the lower z side
element_positions=zeros(size(data3d_els,1),3);
for element_no=1:data3d_no_els
    element_positions(element_no,:)=mean(data3d_nodes(data3d_els(element_no,:),:));
end
temp1=find(data3d_nodes(:,defect_location(2))>=defect_location(1)-crack_opening&data3d_nodes(:,defect_location(2))<=defect_location(1)+crack_opening);
temp2=find(data3d_nodes(:,defect_location(2))==defect_location(1));
defect_nodes=temp1(find(ismember(temp1,temp2)==0));
%find all the elements which have these nodes as members and how many per element
temp=zeros(data3d_no_els,1);
for element_no=1:data3d_no_els
    temp(element_no)=sum(ismember(data3d_els(element_no,:),defect_nodes));
end
defect_elements=zeros([size(find(temp),1),2]);
defect_elements(:,1)=find(temp);
defect_elements(:,2)=temp(find(temp)); %the first number is the element no and the second is the number of defect nodes in that element
%elements with 2 or more nodes present will count for 100% area, elements with 1 will count for 50% of area
defect_area=0;
for defect_element_index=1:size(defect_elements,1)
    node_nos=find(data3d_nodes(data3d_els(defect_elements(defect_element_index,1),:),defect_location(2))>=defect_location(1)-crack_opening&data3d_nodes(data3d_els(defect_elements(defect_element_index,1),:),defect_location(2))<=defect_location(1)+crack_opening);
    if defect_elements(defect_element_index,2)>=2
        %calculate area based on the four nodes on the defect
        defect_area=defect_area+calc_area_quad(...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(1)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(1)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(2)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(2)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(4)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(4)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(3)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(3)),defect_plane(2)));
    elseif defect_elements(defect_element_index,2)<2
       defect_area=defect_area+calc_area_quad(...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(1)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(1)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(2)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(2)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(4)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(4)),defect_plane(2)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(3)),defect_plane(1)),...
            data3d_nodes(data3d_els(defect_elements(defect_element_index,1),node_nos(3)),defect_plane(2)))/2;
    end
end
disp(strcat('Number of Defect Nodes: ',num2str(size(defect_nodes,1))));
disp(strcat('Number of Defect Elements: ',num2str(size(defect_elements,1))));
disp(strcat('Defect Area (m^2): ',num2str(defect_area)));
figure(1);hold on;
mesh_fig=subplot('position',[0.125 0.125 0.75 0.75]);
chart_title='Mesh';
scale=256;
view_pos=3;
%draw_mesh_3D(data3d_nodes(surface_nodes,:),data3d_els,0,defect_nodes,0,0,scale,mesh_fig,view_pos,chart_title);
disp(' ');
temp='x';
while not((temp=='n')|(temp=='y'))
   temp='y';
   temp=input(strcat('Draw Mesh? [',temp,']? '),'s');
   if size(temp,2)==0
      temp='y';
   end;
end
draw_mesh_3D(data3d_nodes,data3d_els,0,defect_nodes,0,0,scale,mesh_fig,view_pos,chart_title);
