file_name='n:\grail\matlab\fe-data\3d-models\cracks\symmetric_web_crack_ref_coef.mat';
load(file_name);
defect_dimension={'Crack Length (mm)', 'Crack Area (mm^2)'};
[notch_depths,b]=sort(notch_depths);
tc=tc(:,:,b);
rc=rc(:,:,b);
temp=[200,600,1000,1500,1800];
notch_depths=[notch_depths;temp];
temp=rc;
dim=max(find(rc(1,1,:)));
rc=zeros([size(rc,1),size(rc,2),dim])
rc(:,:,:)=temp(:,:,1:dim)
temp=tc;
tc=zeros([size(tc,1),size(tc,2),dim]);
tc(:,:,:)=temp(:,:,1:dim);
save(file_name,'rc','tc','output_fname','notch_depths','excite_modes','rc_modes','defect_dimension');