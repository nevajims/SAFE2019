close all;
tx_modes=      [3,5,7,8,10,  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
rx_modes=      [3,5,7,8,10,  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
receive_modes=[3,5,7,8,10];
force_symmetry=1;
thresh=0.5;
max_feats=500;
feat_matrix=zeros(max_feats,length(tx_modes));
feat_type=cell(max_feats,1);
feat_area_loss=zeros(max_feats,1);


rc_files=[...
      {'n:\grail\matlab\fe-data\3D-models\cracks\symmetric_head_crack_ref_coef'};...%first file is always rail  end and max notch depth is used
      {'n:\grail\matlab\fe-data\3D-models\thermit\thermit_weld_cap_ref_coef'};...
      {'n:\grail\matlab\fe-data\3D-models\cracks\symmetric_head_crack_ref_coef'};...
      {'n:\grail\matlab\fe-data\3D-models\cracks\antisym_head_crack_ref_coef'};...
      {'n:\grail\matlab\fe-data\3D-models\cracks\symmetric_foot_crack_ref_coef'};...
      {'n:\grail\matlab\fe-data\3D-models\cracks\asym_toe_crack_ref_coef'};...
   ];

feat_types=[...
      {'Rail end'};...
      {'Thermit weld'};...
      {'Symm head defect'};...
      {'Anti-symm head defect'};...
      {'Symm foot defect'};...
      {'Anti-symm foot defect'};...
   ];

feat_count=0;
for file_count=1:length(rc_files);
   load(char(rc_files(file_count)));
   if file_count==1;
      notch_count=find(notch_depths(2,:)==max(notch_depths(2,:)));
		feat_count=feat_count+1;
		feat_type(feat_count)=cellstr('Rail end');
		temp=rc(receive_modes,:,notch_count);
		if force_symmetry;
			temp=force_sym(temp);
		end;
		temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
		for ii=1:length(tx_modes);
      	feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
      end;
   else
	   for notch_count=1:size(notch_depths,2);
   	   feat_count=feat_count+1;
      	feat_type(feat_count)=cellstr([char(feat_types(file_count)),': ',num2str(notch_depths(2,notch_count))]);
			temp=rc(receive_modes,:,notch_count);
			if force_symmetry;
			   temp=force_sym(temp);
			end;
			temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
			for ii=1:length(tx_modes);
            feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
         end;
		end;
   end;
end;

feat_count=feat_count+1;
feat_matrix(feat_count,:)=ones(1,size(feat_matrix,2));
feat_type(feat_count)=cellstr('Common noise');


feat_matrix=feat_matrix(1:feat_count,:);
feat_type=feat_type(1:feat_count,:);
feat_area_loss=feat_area_loss(1:feat_count,:);

clear('feat_count');
clear('feat_types');
keyboard;
save('n:\grail\matlab\features','feat_*');

disp([tx_modes',rx_modes',feat_matrix']);

disp(['Condition number: ',num2str(cond(feat_matrix))]);


if 0;





%end of rail
load('n:\grail\matlab\fe-data\3D-models\cracks\symmetric_head_crack_ref_coef');
feat_type{feat_count}='Rail end';
depth=160;%depth of feature to extract
feat_area_loss(feat_count)=1;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%thermit weld
load('n:\grail\matlab\fe-data\3D-models\thermit\thermit_weld_cap_ref_coef');
feat_type{feat_count}='Thermit weld 10';
depth=10;%depth of feature to extract
feat_area_loss(feat_count)=1;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%head symmetric crack
load('n:\grail\matlab\fe-data\3D-models\cracks\symmetric_head_crack_ref_coef');
feat_type{feat_count}='Symm head crack';
depth=50;%depth of feature to extract
feat_area_loss(feat_count)=0.3;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%head anti-symmetric side crack
feat_type{feat_count}='Anti-symm head side crack';
load('n:\grail\matlab\fe-data\3D-models\cracks\antisym_head_crack_ref_coef');
depth=30;%depth of feature to extract
feat_area_loss(feat_count)=0.2;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%symmetric foot crack
load('n:\grail\matlab\fe-data\3D-models\cracks\symmetric_foot_crack_ref_coef');
feat_type{feat_count}='Symm foot crack';
depth=70;%depth of feature to extract
feat_area_loss(feat_count)=0.3;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%anti-symmetric toe crack
load('n:\grail\matlab\fe-data\3D-models\cracks\asym_toe_crack_ref_coef');
feat_type{feat_count}='Anti-symm toe crack';
depth=50;%depth of feature to extract
feat_area_loss(feat_count)=0.3;%work this out and put it in here
depth_index=find(notch_depths==depth);
temp=rc(receive_modes,:,depth_index);
if force_symmetry;
   temp=force_sym(temp);
end;
temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;

%common noise
temp=ones(5,5);
feat_type{feat_count}='Common noise';
%fill in feat_matrix
for ii=1:length(tx_modes);
   feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;
feat_count=feat_count+1;


%%%%%%%%%%%%%%

feat_count=feat_count-1;
feat_matrix=feat_matrix(1:feat_count,:);
feat_area_loss=feat_area_loss(1:feat_count);
feat_type=feat_type(1:feat_count);

for ii=1:size(feat_matrix,1);
%   feat_matrix(ii,:)=feat_matrix(ii,:)/max(abs(feat_matrix(ii,:)));
end;

clear('feat_count');
save('n:\grail\matlab\features','feat_*');

disp([tx_modes',rx_modes',pinv(feat_matrix)]);

disp(['Condition number: ',num2str(cond(feat_matrix))]);
end;