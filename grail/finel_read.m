%get ready
clc;
clear;
close all;
disp('Finel Eigenvector Processing');
disp('===== =========== ==========');
%set defaults in case defaults filenot found
default_base_dir='g:\10-MAIN PROJECTS\grail\matlab\fe-data';
default_mesh_fname='mesh.txt';
default_file_prefix='eigvec';
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
   
   %get prefix
   ok=0;
   while ~ok;
	   file_prefix=input(strcat('Data file prefix [',default_file_prefix,']: '),'s');
   	if size(file_prefix,2)==0
      	file_prefix=default_file_prefix;
	   end;
   	data_files=dir(strcat(default_base_dir,file_prefix,'*.txt'));
	   disp(' ');
      data_no_files=size(data_files,1);
      if data_no_files>0;
		   for count=1:data_no_files;
	      	disp(strcat('    ',data_files(count).name));
         end;
         ok=1;
         default_file_prefix=file_prefix;
      else
         disp('No files');
         ok=0;
      end;
   end;
   
   %specify output filename as same as prefix
   ok=1;
   while ~ok;
	   output_fname=input(strcat('Output file [',default_data_fname,']: '),'s');
   	if size(output_fname,2)==0
         output_fname=default_data_fname;
      end;
      default_data_fname=output_fname;
      ok=1;
   end;
   
   output_fname=file_prefix;
   
   %confirm
   disp(' ');
  	disp(strcat('About to process ',num2str(data_no_files),' files'));
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

%specify the expected number of modeshapes in the files
data_no_ms=20;
%load the mesh file as one big matrix
temp=load(strcat(default_base_dir,default_mesh_fname),'-ascii');
data_no_nodes=temp(1,1);
data_no_els=temp(1,2);
if (data_no_nodes<1)|(data_no_els<1)
   disp('Mesh file corrupt');
   return;
end;
disp(strcat('Number of data_nodes: ',num2str(data_no_nodes)));
disp(strcat('Number of elements: ',num2str(data_no_els)));

%generate node matrix
data_nodes=temp(2:data_no_nodes+1,2:4);

%generte element matrix
data_els=temp(data_no_nodes+2:data_no_nodes+2+data_no_els-1,1:4);

x_min=min(data_nodes(:,1));
x_max=max(data_nodes(:,1));
y_min=min(data_nodes(:,2));
y_max=max(data_nodes(:,2));
curv_rad=0.5*(x_min+x_max);

%loop through the files
for file_count=1:data_no_files;
   %read in a mode shapes file
   fname=strcat(default_base_dir,data_files(file_count).name);
   if ~exist(fname);
      disp('File missing');
      fname;
      return;
   end;
   	
	%load the lot as one big matrix
	temp=load(strcat(fname),'-ascii');

	%extract order from filename and work out wavelength
	i1=findstr(fname,'=');
	i2=findstr(fname,'_');
	circ_order=str2num(fname(max(i1)+1:max(i2)-2));

	wavelength=2*pi*curv_rad/circ_order;

	%work out how many mode shapes there are
    if not(size(temp,1)/(data_no_nodes+1)==data_no_ms);
            disp(fname);
        	disp(' has wrong number of mode shapes');
        return
    end
    disp(fname);
	disp(strcat('Number of mode shapes: ',num2str(data_no_ms)));
   disp(strcat('Circular order: ',num2str(circ_order)));
   disp(' ');
   
   %set up matrices if first time through loop
   if file_count==1;
		data_freq=zeros(data_no_ms*data_no_files,1);
		data_ph_vel=zeros(data_no_ms*data_no_files,1);
		data_gr_vel=zeros(data_no_ms*data_no_files,1);
		data_ms_x=zeros(data_no_nodes,data_no_ms*data_no_files);
		data_ms_y=zeros(data_no_nodes,data_no_ms*data_no_files);
      data_ms_z=zeros(data_no_nodes,data_no_ms*data_no_files);
   end;
	%extract the mode shapes, phase velocities etc.
	for count=1:data_no_ms;
   	data_freq(count+(file_count-1)*data_no_ms,1)=sqrt(temp((count-1)*(data_no_nodes+1)+1,3))/(2*pi);
      %mass_norm=1000;
      mass_norm=sqrt(temp((count-1)*(data_no_nodes+1)+1,4));
   	data_ph_vel(count+(file_count-1)*data_no_ms,1)=data_freq(count+(file_count-1)*data_no_ms,1)*wavelength;
	   data_ms_x(:,count+(file_count-1)*data_no_ms)=temp((count-1)*(data_no_nodes+1)+2:(count)*(data_no_nodes+1),2)/mass_norm;
   	data_ms_y(:,count+(file_count-1)*data_no_ms)=temp((count-1)*(data_no_nodes+1)+2:(count)*(data_no_nodes+1),3)/mass_norm;
	   data_ms_z(:,count+(file_count-1)*data_no_ms)=temp((count-1)*(data_no_nodes+1)+2:(count)*(data_no_nodes+1),4)/mass_norm;
   end;
%end of file loop

end;

%reordering of mode numbers if this is necessary for consistency with
%previous models. Note this only changes the name of the mode not its order
%in the mode list. listed as column 1 = new number, column 2 = old number
data_mode_list=[1 2 3 4 5 6 7 8 9 10;1 2 3 4 5 6 7 8 9 10]'; %default, no change
%data_mode_list=[1 2 3 7 5 6 4 8 10 9;1 2 3 4 5 6 7 8 9 10]'; %modes reordered for BS80A rail
%data_mode_list=[1 2 3 7 6 5 4 8 9 10;1 2 3 4 5 6 7 8 9 10]'; %modes reordered for NP46 rail

%sort the data by modes
no_pts=size(data_ms_x,2);
min_percent_change_in_ms=70;
%set up basic look up table for original data
lookup=1:no_pts;
%calc wavelength of each block (file) of data and sort lookups by blocks accordingly
	lambda=data_ph_vel(1:data_no_ms:no_pts,1) ./ data_freq(1:data_no_ms:no_pts,1);
[lambda,block_lookup]=sort(lambda);
block_lookup(:)=block_lookup(size(block_lookup,1):-1:1);

for count=1:data_no_files
   initial_lookup((count-1)*data_no_ms+1:count*data_no_ms)=lookup((block_lookup(count)-1)*data_no_ms+1:block_lookup(count)*data_no_ms);
end;

%sort the data into descending lambda
data_freq(:)=data_freq(initial_lookup(:));
data_ph_vel(:)=data_ph_vel(initial_lookup(:));
data_ms_x(:,:)=data_ms_x(:,initial_lookup(:));
data_ms_y(:,:)=data_ms_y(:,initial_lookup(:));
data_ms_z(:,:)=data_ms_z(:,initial_lookup(:));

%get ready for the mode tracing part
valid_pts=ones(no_pts,1);
sorted_lookup=zeros(no_pts,1);
data_mode_start_indices=zeros(data_no_ms,1);

mode_start_index_in_initial_lookup=1;
mode_start_index_in_sorted_lookup=1;
index_in_sorted_lookup=1;
mode_count=1;

while mode_start_index_in_initial_lookup<=no_pts;
   if valid_pts(mode_start_index_in_initial_lookup,1);
      %found first point of mode
		old_max_dps=-1; %to turn off mode shape comparison
      data_mode_start_indices(mode_count)=mode_start_index_in_sorted_lookup;%where the mode starts in the sorted lookup
      current_index_in_initial_lookup=mode_start_index_in_initial_lookup;%this is initial value for the current point
      first_block=floor((current_index_in_initial_lookup-1)/data_no_ms)+2; %the block after where the current point is
      last_block=data_no_files; % the last block in the look up table
      %add point to mode in sorted lookup
		sorted_lookup(index_in_sorted_lookup)=current_index_in_initial_lookup;
		valid_pts(current_index_in_initial_lookup)=0; %so that the point can't be used as either a starting point or another point on another mode
      index_in_sorted_lookup=index_in_sorted_lookup+1;
      %work through the subsequent blocks to trace the mode
      if first_block<=last_block;%catch, in case a stray point is found in last block, and there are no further blocks to trace in
	      for block=first_block:last_block;
   	      %find the best match in the block
      	   dps=zeros(no_pts,1);         
         	first_index=(block-1)*data_no_ms+1;
	         last_index=block*data_no_ms;
   	      %compare each point in block with current point
            for index=first_index:last_index;
               dps(index,1)=abs(...
                  dot(data_ms_x(:,current_index_in_initial_lookup),data_ms_x(:,index))+...
                  dot(data_ms_y(:,current_index_in_initial_lookup),data_ms_y(:,index))+...
               	dot(data_ms_z(:,current_index_in_initial_lookup),data_ms_z(:,index)));
               %self_dps=zeros(data_no_nodes,1);
               %for node_count=1:data_no_nodes
               %   first_vector=[data_ms_x(node_count,current_index_in_initial_lookup)...
               %         			data_ms_y(node_count,current_index_in_initial_lookup)...
               %         			data_ms_z(node_count,current_index_in_initial_lookup)];
               %   second_vector=[data_ms_x(node_count,index)...
               %         			data_ms_y(node_count,index)...
               %         			data_ms_z(node_count,index)];
               %            if (norm(first_vector)*norm(second_vector))~=0;
               %               self_dps(node_count)=abs(dot(first_vector,second_vector)/(norm(first_vector)*norm(second_vector)));
               %            else
               %               self_dps(node_count)=0;
               %            end;
               %end;
     				%dps(index)=sum(self_dps)/data_no_nodes;
            end;
            dps(first_index:last_index,1)=dps(first_index:last_index,1) .* valid_pts(first_index:last_index,1);%eliminate any points already used
            [new_max_dps,current_index_in_initial_lookup]=max(dps);%increment index 
            %look for mode shape mismatch if not first point 
            if old_max_dps>1;
               if new_max_dps/old_max_dps*100<min_percent_change_in_ms;
                  %end of mode due to mode shape mismatch
                  break;
               end;
            end;
 				old_max_dps=new_max_dps;
		      %add point to sorted lookup
      	   sorted_lookup(index_in_sorted_lookup)=current_index_in_initial_lookup;
         	valid_pts(current_index_in_initial_lookup)=0;
	   	   index_in_sorted_lookup=index_in_sorted_lookup+1;
         end;
      end;
      
      mode_count=mode_count+1;
      mode_start_index_in_sorted_lookup=index_in_sorted_lookup;
   end;
   mode_start_index_in_initial_lookup=mode_start_index_in_initial_lookup+1;
end;

data_no_modes=size(data_mode_start_indices,1);
data_mode_start_indices=[data_mode_start_indices;no_pts];%last index is last point in array - useful in other functions

%sort original data into order specified by sorted look-up
data_freq(:)=data_freq(sorted_lookup(:));
data_ph_vel(:)=data_ph_vel(sorted_lookup(:));
data_ms_x(:,:)=data_ms_x(:,sorted_lookup(:));
data_ms_y(:,:)=data_ms_y(:,sorted_lookup(:));
data_ms_z(:,:)=data_ms_z(:,sorted_lookup(:));

%set up for plots colors
mode_colors='ymcrgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbkymcrgbk';

%plot phase velocity
figure;hold on;
for mode_count=1:data_no_modes;
   start_index=data_mode_start_indices(mode_count);
	end_index=data_mode_start_indices(mode_count+1)-1;
   plot(data_freq(start_index:end_index)/1000,data_ph_vel(start_index:end_index)/1000,strcat(mode_colors(mode_count),'.-'));
end;
axis([0 max(data_freq)/1000 0 10]);

%calculate and plot group velocity
data_gr_vel=zeros(size(data_ph_vel,1),size(data_ph_vel,2));
figure;hold on;
for mode_count=1:data_no_modes;
   mode_count
   start_index=data_mode_start_indices(mode_count);
	end_index=data_mode_start_indices(mode_count+1)-1;
   %fit quadratic and differentiate to get group velocity at centre point
   for count=start_index+1:end_index-1
      w1=2*pi*data_freq(count-1,1);
      w2=2*pi*data_freq(count,1);
      w3=2*pi*data_freq(count+1,1);
      k1=data_freq(count-1,1)/data_ph_vel(count-1,1);
      k2=data_freq(count,1)/data_ph_vel(count,1);
      k3=data_freq(count+1,1)/data_ph_vel(count+1,1);
      a2=((k1-k3)-(w1-w3)*(k2-k3)/(w2-w3))/((w1^2-w3^2)-(w1-w3)*(w2^2-w3^2)/(w2-w3));
      a1=((k2-k3)-(w2^2-w3^2)*a2)/(w2-w3);
      data_gr_vel(count,1)=1/(2*a2*w2+a1)/(2*pi);
      if count==start_index+1
         data_gr_vel(count-1,1)=1/(2*a2*w1+a1)/(2*pi);
      end;
      if count==end_index-1
         data_gr_vel(count+1,1)=1/(2*a2*w3+a1)/(2*pi);
      end;
   end;
   plot(data_freq(start_index:end_index)/1000,data_gr_vel(start_index:end_index)/1000,strcat(mode_colors(mode_count),'.-'));
end;
axis([0 max(data_freq)/1000 0 6]);

%calculate nodal mass matrix
mass=zeros(size(data_nodes,1),1);
for count=1:data_no_els
   area=calc_area_quad(...
      data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),...
      data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),...
      data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),...
      data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2)...
      );
   for node_count=1:4;
      mass(data_els(count,node_count),1)=mass(data_els(count,node_count),1)+area/4;
   end;
end;

%calculate power flow for each point and normalise displacements - excitability is then disp^2*freq
for count=1:size(data_freq,1);
   %calc power flow
   power_flow=...
      (sum((...
   	data_ms_x(:,count).^2+...
      data_ms_y(:,count).^2+...
      data_ms_z(:,count).^2).*...
      mass(:))*...
      data_freq(count) ^ 2 * ...
      abs(data_gr_vel(count))) .^ 0.5;
   %normalise displacements
   data_ms_x(:,count)=data_ms_x(:,count)/power_flow;
   data_ms_y(:,count)=data_ms_y(:,count)/power_flow;
   data_ms_z(:,count)=data_ms_z(:,count)/power_flow;
end;

%extract the perimeter nodes

%find perimeter nodes and sort into order

perimeter_nodes_is=zeros(data_no_nodes,1);
for node1=1:size(data_els,1);
   for node2=1:size(data_els,2);
      perimeter_nodes_is(data_els(node1,node2))=perimeter_nodes_is(data_els(node1,node2))+1;
   end;
end;
%find nodes with less than four entries as these are on the perimeter
data_no_perimeter_nodes=0;
for node1=1:data_no_nodes;
   if perimeter_nodes_is(node1)<4;
      perimeter_nodes_is(node1)=1;
   else
      perimeter_nodes_is(node1)=0;
   end;
end;
data_no_perimeter_nodes=sum(perimeter_nodes_is);
data_perimeter_node_list=zeros(data_no_perimeter_nodes,1);
dist=zeros(data_no_nodes,3);
%put the perimeter nodes in order
for node_count=1:data_no_perimeter_nodes;
   %first time through - find a node
   if node_count==1;
      for count=1:data_no_nodes
         if perimeter_nodes_is(count)==1;
            data_perimeter_node_list(node_count)=count;
            perimeter_nodes_is(count)=0;
            break;
         end;
      end;
   else
   	%other times through
      last_node=data_nodes(data_perimeter_node_list(node_count-1),:);
		dist=zeros(data_no_nodes,1);
      for count=1:3
      	dist(:,1)=dist(:,1) + (data_nodes(:,count) - last_node(count)) .^ 2;
      end;
      dist=dist .^ 0.5;
      %add on a big number so that there is no danger of selecting an already selected node
      big_dist=max(dist);
      dist=dist+~perimeter_nodes_is*big_dist;
      [min_dist,current_node]=min(dist);
      data_perimeter_node_list(node_count)=current_node;  
      perimeter_nodes_is(current_node)=0;
         
   end;
end;
%sort the order to start on the axis of symmetry
max_y=max(data_nodes(data_perimeter_node_list(:),2));
min_y=min(data_nodes(data_perimeter_node_list(:),2));
sym_axis_y=mean([max_y min_y]);
min_x=min(data_nodes(data_perimeter_node_list(:),1));
nodes=find(data_nodes(:,1)==min_x);
closest_node_y=min(data_nodes(nodes(:),2)-sym_axis_y);
node_index=find(data_nodes(nodes(:),2)==sym_axis_y);
start_node_no=nodes(node_index(1));
start_node_index=find(data_perimeter_node_list==start_node_no);
temp=zeros((size(data_perimeter_node_list,1)),1);
temp(1:(size(data_perimeter_node_list)-start_node_index)+1)=data_perimeter_node_list(start_node_index:size(data_perimeter_node_list));
temp((size(data_perimeter_node_list)-start_node_index)+2:size(data_perimeter_node_list))=data_perimeter_node_list(1:start_node_index-1);
data_perimeter_node_list=temp;
%calculate the normal (default#1) and tangential (default#2) direction to the surface of the rail
delta=zeros(size(data_perimeter_node_list,1),3);
for count=1:size(data_perimeter_node_list,1)
   if count==1
       delta(count,:)=data_nodes(data_perimeter_node_list(count),:)-data_nodes(data_perimeter_node_list(size(data_perimeter_node_list,1)),:);
   else;
       delta(count,:)=data_nodes(data_perimeter_node_list(count),:)-data_nodes(data_perimeter_node_list(count-1),:);
   end;   
   magnitude(count,1)=norm(delta(count,:));
   tangential_unit_vectors(count,:)=delta(count,:)./magnitude(count);
   normal_unit_vectors(count,:)=cross(tangential_unit_vectors(count,:),[0 0 1]);
end;
%find the vectors for each node as the average of the surrounding nodes
for count=1:size(data_perimeter_node_list,1)
   if count==size(data_perimeter_node_list,1)
       temp=tangential_unit_vectors(count,:)+tangential_unit_vectors(1,:);
       data_surface_tangent(count,:)=temp/norm(temp);
   else;
       temp=tangential_unit_vectors(count,:)+tangential_unit_vectors(count+1,:);
       data_surface_tangent(count,:)=temp/norm(temp);
   end;   
   data_surface_normal(count,:)=cross(data_surface_tangent(count,:),[0 0 -1]);
end;
%plot a mode shape
index=1;
disp_shape=data_nodes+[data_ms_x(:,index),data_ms_y(:,index),data_ms_z(:,index)]/20;
figure;hold on;view(3);
for count=1:data_no_els;
temp=[	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3);
   			data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),data_nodes(data_els(count,2),3);
            data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),data_nodes(data_els(count,4),3);
            data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2),data_nodes(data_els(count,3),3);
         	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3)];   
   plot3(temp(:,1),temp(:,2),temp(:,3),'b');
   temp=[	disp_shape(data_els(count,1),1),disp_shape(data_els(count,1),2),disp_shape(data_els(count,1),3);
   			disp_shape(data_els(count,2),1),disp_shape(data_els(count,2),2),disp_shape(data_els(count,2),3);
            disp_shape(data_els(count,4),1),disp_shape(data_els(count,4),2),disp_shape(data_els(count,4),3);
            disp_shape(data_els(count,3),1),disp_shape(data_els(count,3),2),disp_shape(data_els(count,3),3);
         	disp_shape(data_els(count,1),1),disp_shape(data_els(count,1),2),disp_shape(data_els(count,1),3)];   
   plot3(temp(:,1),temp(:,2),temp(:,3),'r');
         
   
end;

%save output file - should also have a data_ field for mode names e.g. 'head mode etc'
%and maybeone for symm/antisymm
save(strcat(default_base_dir,output_fname),'data_*');
