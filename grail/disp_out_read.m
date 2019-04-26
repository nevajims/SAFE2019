function mat_file_name=disp_out_read(fname,max_time_pts,step_format);
%disp.out reader
[path,name,ext,ver] = fileparts(fname);
fid=fopen(fname,'r');
if step_format==0
   %read number of nodes
   dispout_no_nodes=fscanf(fid,'%f');
   %set up results matrix
   dispout_data=zeros(max_time_pts,dispout_no_nodes);
   for count=1:max_time_pts;
      %read in time line
      temp=fgetl(fid);
      if count==1
         t1=sscanf(temp(12:length(temp)),'%f');
      end;
      if count==2;
         t2=sscanf(temp(12:length(temp)),'%f');
         dispout_timestep=t2-t1;
      end;
      %read in 2 more lines
      fgetl(fid);
      fgetl(fid);
      %read in data
      %check each line has an E in it
      good=1;
      pos=ftell(fid);
      for count2=1:dispout_no_nodes
         l=fgetl(fid);
         if isempty(findstr('E',l));
            good=0;
            break;
         end;
      end;
      %go back to start of block
      fseek(fid,pos,'bof');
      %if ok then read in block
      if good;
         temp=fscanf(fid,'%f',[3,dispout_no_nodes])';
         fgetl(fid);
         dispout_data(count,:)=temp(:,3)';
      end;
      if ~good;
         for count2=1:dispout_no_nodes
            line=fgetl(fid);
            if isempty(findstr('E',line));
               dispout_data(count,count2)=0;
            else
               temp=sscanf(line,'%f',3);
               dispout_data(count,count2)=temp(:,3);
            end;
         end;
      end;
      if count==1;
         dispout_nodes=temp(:,1);
         dispout_dirs=temp(:,2);
      end;
      if feof(fid)
         break;
      end;
      disp(strcat(num2str(count),'timepoint completed'));
   end;
end;
if step_format==2
	fgetl(fid);	%read the first 5 lines which have no useful information
   fgetl(fid);
    fgetl(fid);
   fgetl(fid);
   fgetl(fid);
   temp=fgetl(fid);
   dispout_no_nodes=sscanf(temp(8:length(temp)),'%f'); %read the number of monitoring points
   position=ftell(fid);
   temp=fscanf(fid,'%s %f %f %f %f %f',[6,dispout_no_nodes])';
   if size(temp,2)==5
       fseek(fid,position,-1);
       temp=fscanf(fid,'%s %f %f %f %f',[5,dispout_no_nodes])';
   end
   dispout_nodes=temp(:,2);
   dispout_dirs=temp(:,3);
   if size(temp,2)==6
        dispout_node_coords_xy=temp(:,4:6);
   elseif size(temp,2)==5
        dispout_node_coords_xy=temp(:,4:5);
   end
   for count=1:max_time_pts;
      %read in time line
      if count==1
         temp=fgetl(fid);
	     temp=fgetl(fid);
         t1=sscanf(temp(5:length(temp)),'%f');
      elseif count==2;
         temp=fgetl(fid);
         t2=sscanf(temp(5:length(temp)),'%f');
         dispout_timestep=t2-t1;
      else
         temp=fgetl(fid);
      end
      
      %read in data
      %check each line has an E in it
      good=1;
      pos=ftell(fid);
      for count2=1:dispout_no_nodes
         l=fgetl(fid);
         if isempty(findstr('E',l));
            good=0;
            break;
         end;
      end;
      %go back to start of block
      fseek(fid,pos,'bof');
      %if ok then read in block
      if good;
         temp=fscanf(fid,'%s %f %f %f',[4,dispout_no_nodes])';
         fgetl(fid);
         dispout_data(count,:)=temp(:,4)';
      end;
      if ~good;
         for count3=1:dispout_no_nodes
            lineposition=ftell(fid);
            l=fgetl(fid);
            if isempty(findstr('E',l));
               dispout_data(count,count3)=0;
            else
               fseek(fid,lineposition,'bof');
               temp=fscanf(fid,'%s %f %f %f',[4,1])';
               fgetl(fid);
               dispout_data(count,count3)=temp(4);
            end;
         end;
      end;
      if feof(fid)
         break;
      end;
      %disp(strcat(num2str(count),'timepoint completed'));
  end;
end

dispout_no_pts=count;
dispout_data=dispout_data(1:dispout_no_pts,:);
save(fullfile(path,name),'dispout_*');
mat_file_name=fullfile(path,name);
fclose(fid);
