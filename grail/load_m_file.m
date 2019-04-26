function fname=load_m_file
%set defaults in case defaults file not found
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

save(strcat(default_base_dir,'\finel_defaults'),'default_*');

