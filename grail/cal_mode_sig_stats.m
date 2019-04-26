%First load the reflection coefficient file
%fname=load_m_file;
min_defect_csa=0.0;
max_defect_csa=1.0;
data_files=dir('*.mat');
fid=fopen('c:\temp\temp.txt','wt');
disp(' ');
data_no_files=size(data_files,1);
for count=1:data_no_files;
    disp(strcat('    ',num2str(count),'. ',data_files(count).name));
end;
disp(' ');
for file_loop=1:data_no_files
    load(data_files(file_loop).name);
    asymmetry=0;
    %Display the information
    disp(strcat('Defect type: ',output_fname));
    %disp(strcat(defect_dimension',num2str(num2str(notch_depths))));
    if size(notch_depths,1)==2
        max_defect=max(find(notch_depths(2,:)<(max_defect_csa*7000)));
        min_defect=min(find(notch_depths(2,:)>(min_defect_csa*7000)));
    else
        max_defect=length(notch_depths);
        min_defect=1;
    end
    defects_to_calculate=(min_defect:max_defect);
    d=rc(excite_modes(:),:,:);
    errors=zeros(length(notch_depths),1);
    max_asymmetry=0;
    
    
    for defect_index=1:length(defects_to_calculate)
        defect=defects_to_calculate(defect_index)
        temp=abs((d(:,:,defect)-d(:,:,defect)')./abs(max(max(d(:,:,defect)))));
        asymmetry(defect_index)=mean(sum(temp)./4);
        if max(max(temp))>max_asymmetry
            max_asymmetry=max(max(temp));
        end
    end
    mean_asymmetry=mean(asymmetry);
    %disp(strcat('Mean asymmetry is:',num2str(mean_asymmetry*100),'%'));
    %disp(strcat('Max asymmetry is:',num2str(max_asymmetry*100),'%'));
    fprintf(fid,'%s\t %f\t %f\n',output_fname,mean_asymmetry*100,max_asymmetry*100);    
    
end
fclose(fid);