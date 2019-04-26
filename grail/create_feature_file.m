clear;
close all;
%tx_modes=      [3,5,7,8,10,  3,3,3,3,   5,5,5,5,   7,7,7,7,   8,8,8,8,   10,10,10,10];
%rx_modes=      [3,5,7,8,10,  5,7,8,10,  3,7,8,10,  3,5,8,10,  3,5,7,10,  3,5,7,8];
tx_modes=      [3,3,3,3,3,  5,5,5,5,5,   7,7,7,7,7,   8,8,8,8,8,   10,10,10,10,10];
rx_modes=      [3,5,7,8,10, 3,5,7,8,10,  3,5,7,8,10,  3,5,7,8,10,  3,5,7,8,10];
receive_modes=[3,5,7,8,10];
force_symmetry=0;
thresh=0.5;
max_feats=500;
feat_matrix=zeros(max_feats,length(tx_modes));
feat_area_loss=zeros(max_feats,1);

force_scale_factors_so_full_scale_is_unity=0;
boost_defect_factor = 2;
make_cpp_file = 1;

feat_index=[...
      0;...
      1;...
      2;...
      3;...
      4;...
      5;...
      6;...
      7;...
	];

feat_parent_index=[...
      -1;...
      -1;...
      -1;...
      -1;...
      -1;...
      -1;...
      -1;...
      -1;...
	];

rc_files=[...
      {'n:\grail\matlab\reflection-coefficients\sym_head_crack_ref_coef.mat'};...%first file is always used for rail end only and max notch depth is used
      {'n:\grail\matlab\reflection-coefficients\thermit_porosity_ref_coef.mat'};...%second file is always used for Thermit weld only and zero porosity is used
      {'dummy'};...
      {'n:\grail\matlab\reflection-coefficients\sym_head_crack_ref_coef.mat'};...
      {'n:\grail\matlab\reflection-coefficients\asym_head_crack_ref_coef.mat'};...
      {'n:\grail\matlab\reflection-coefficients\sym_web_crack_ref_coef.mat'};...
      {'n:\grail\matlab\reflection-coefficients\sym_base_crack_ref_coef.mat'};...
      {'n:\grail\matlab\reflection-coefficients\asym_toe_crack_ref_coef.mat'};...
   ];

feat_long_names=[...
      {'Rail end'};...
      {'Thermit weld'};...
      {'Residuals'};...
      {'Symm head defect'};...
      {'Anti-symm head defect'};...
      {'Symm web defect'};...
      {'Symm foot defect'};...
      {'Anti-symm foot defect'};...
   ];

feat_short_names=[...
      {'End'};...
      {'Weld'};...
      {'Res.'};...
      {'Head (S)'};...
      {'Head (A)'};...
      {'Web (S)'};...
      {'Foot (S)'};...
      {'Foot (A)'};...
   ];

feat_long_units=[...
      {'None'};...
      {'None'};...
      {'None'};...
      {'Area loss (percent)'};...
      {'Area loss (percent)'};...
      {'Area loss (percent)'};...
      {'Area loss (percent)'};...
      {'Area loss (percent)'};...
   ];

feat_short_units=[...
      {'-'};...
      {'-'};...
      {'-'};...
      {'pc'};...
      {'pc'};...
      {'pc'};...
      {'pc'};...
      {'pc'};...
   ];

feat_location=[...
      {'other'};...
      {'other'};...
      {'other'};...
      {'head'};...
      {'head'};...
      {'web'};...
      {'foot'};...
      {'foot'};...
   ];
     
feat_symmetry=[...
      {'symmetric'};...
      {'symmetric'};...
      {'symmetric'};...
      {'symmetric'};...
      {'anti-symmetric'};...
      {'symmetric'};...
      {'symmetric'};...
      {'anti-symmetric'};...
   ];

feat_color=[...
      0;...
      0;...
      0;...
      0;...
      0;...
      0;...
      0;...
      0;...
	];

%end of rail case
file_count=1;
feat_count=1;
load(char(rc_files(file_count)));
notch_count=find(notch_depths(2,:)==max(notch_depths(2,:))); %find full depth crack entry
temp=rc(receive_modes,:,notch_count);
if force_symmetry;
	temp=force_sym(temp);
end;
%temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
for ii=1:length(tx_modes);
	feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;

%thermit weld case
file_count=2;
feat_count=2;
load(char(rc_files(file_count)));
notch_count=find(notch_depths(2,:)==min(notch_depths(2,:))); %find zero porosity entry
temp=rc(receive_modes,:,notch_count);
if force_symmetry;
	temp=force_sym(temp);
end;
%temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
for ii=1:length(tx_modes);
	feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii)));
end;

%residuals
file_count=3;
feat_count=3;
for ii=1:length(tx_modes);
	feat_matrix(feat_count,ii)=1.0;
end;

%symmetric head crack
file_count=4;
feat_count=4;
load(char(rc_files(file_count)));
notch_count=find(notch_depths(1,:)==50); %find full head depth crack entry
temp=rc(receive_modes,:,notch_count);
if force_symmetry;
	temp=force_sym(temp);
end;
%temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
for ii=1:length(tx_modes);
	feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii))) / boost_defect_factor;
end;

%rest of features
for file_count=5:length(feat_index);
    feat_count=file_count;
    load(char(rc_files(file_count)));

    notch_count=find(notch_depths(1,:)==max(notch_depths(1,:))); %find full depth crack entry
    temp=rc(receive_modes,:,notch_count);
    if force_symmetry;
    	temp=force_sym(temp);
    end;
%temp=temp .* (abs(temp)>max(max(abs(temp)))*thresh);
    for ii=1:length(tx_modes);
    	feat_matrix(feat_count,ii)=temp(find(receive_modes==rx_modes(ii)),find(excite_modes==tx_modes(ii))) / boost_defect_factor;
    end;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create the text file

if make_cpp_file;
    output_fname='n:\grail\matlab\railFeatureDataTmp.cpp';
else;
    output_fname='d:\paul\visualCpp\railTester\Rail\rail_features.txt';
end;

fid=fopen(output_fname,'wt');
frewind(fid);

%title line
fprintf(fid,'This is a test created in Matlab\n');

%number of features
fprintf(fid,'Number of features: %i\n',feat_count);
%first header line
fprintf(fid,'Parent index\t');
fprintf(fid,'Index\t');
fprintf(fid,'Long name\t');
fprintf(fid,'Short name\t');
fprintf(fid,'Long units\t');
fprintf(fid,'Short units\t');
fprintf(fid,'Future1\t');
fprintf(fid,'Future2\t');
fprintf(fid,'Location\t');
fprintf(fid,'Symmetry\t');
fprintf(fid,'Color\t');
for ii=1:length(tx_modes);
   fprintf(fid,'%i\t',tx_modes(ii));
end;
fprintf(fid,'Power\t');
fprintf(fid,'Scale\t');
fprintf(fid,'Round up to\t');
fprintf(fid,'Future3\t');
fprintf(fid,'Future4\n');
%second header line
fprintf(fid,'Parent index\t');
fprintf(fid,'Index\t');
fprintf(fid,'Long name\t');
fprintf(fid,'Short name\t');
fprintf(fid,'Long units\t');
fprintf(fid,'Short units\t');
fprintf(fid,'Future1\t');
fprintf(fid,'Future2\t');
fprintf(fid,'Location\t');
fprintf(fid,'Symmetry\t');
fprintf(fid,'Color\t');
for ii=1:length(rx_modes);
   fprintf(fid,'%i\t',rx_modes(ii));
end;
fprintf(fid,'Power\t');
fprintf(fid,'Scale\t');
fprintf(fid,'Round up to\t');
fprintf(fid,'Future3\t');
fprintf(fid,'Future4\n');


if make_cpp_file;
    loop_count = 0;
    fprintf (fid,'sRailModeOrderInformation gFeatureModeOrder[NUMBER_OF_MODES][NUMBER_OF_MODES] = {\n');
    
 	for jj=1:length(tx_modes);
           if loop_count == 0;
                fprintf(fid,'\n{');
            end;
            loop_count = loop_count + 1;
            fprintf(fid,'{%i,%i},',tx_modes(jj),rx_modes(jj));
            if (tx_modes(jj) == 10);
            else;
                fprintf(fid,' ');
            end;
            
            if (loop_count==5);
                fprintf (fid,'},');
                loop_count = 0;
            end;
        end;
        fprintf(fid,'\n};\n');

        fprintf(fid,'\nsRailFeatureInformation gDefaultFeatures[] = {\n');
        loop_count = 0;
    for ii=1:feat_count;
  	    fprintf(fid,'{(%i)/*ndx*/, ',feat_index(ii));
  	    fprintf(fid,'%i/*prt*/, ',feat_parent_index(ii));
	    fprintf(fid,['_S(\"',char(feat_long_names(ii)),'\"),']);
        fprintf(fid,['_S(\"',char(feat_short_names(ii)),'\"),']);
  	    fprintf(fid,['_S(\"',char(feat_long_units(ii)),'\"),']);
  	    fprintf(fid,['_S(\"',char(feat_short_units(ii)),'\"),']);
  	    fprintf(fid,[char(feat_location(ii)),', ']);
  	    fprintf(fid,[char(feat_symmetry(ii)),', ']);
  	    fprintf(fid,'%i/*clr*/, ',feat_color(ii));
        fprintf(fid,'1.0/*pwr*/, ');
        if force_scale_factors_so_full_scale_is_unity
         val=1.0/(feat_matrix(ii,:) * feat_matrix(ii,:)');
            fprintf(fid,'%f/*scl*/, ',val);
        else
        
          fprintf(fid,'1.0/*scl*/, ');
         end;
        fprintf(fid,'-1.0/*rnd*/, {');
 	    for jj=1:length(tx_modes);
            if loop_count == 0;
                fprintf(fid,'\n{');
            end;
            loop_count = loop_count + 1;
            fprintf(fid,'%f,',feat_matrix(ii,jj));
            if (loop_count==5);
                fprintf (fid,'},');
                loop_count = 0;
            end;
	    end;
        fprintf(fid,'}},\n');
    end;
    fprintf (fid,'};\n');
else;
%the data
for ii=1:feat_count;
  	fprintf(fid,'%i\t',feat_index(ii));
  	fprintf(fid,'%i\t',feat_parent_index(ii));
	fprintf(fid,[char(feat_long_names(ii)),'\t']);
    fprintf(fid,[char(feat_short_names(ii)),'\t']);
  	fprintf(fid,[char(feat_long_units(ii)),'\t']);
  	fprintf(fid,[char(feat_short_units(ii)),'\t']);
  	fprintf(fid,'-\t');
  	fprintf(fid,'-\t');
  	fprintf(fid,[char(feat_location(ii)),'\t']);
  	fprintf(fid,[char(feat_symmetry(ii)),'\t']);
  	fprintf(fid,'%i\t',feat_color(ii));
	for jj=1:length(tx_modes);
      fprintf(fid,'%f\t',feat_matrix(ii,jj));
	end;
   fprintf(fid,'1.0\t');
    if force_scale_factors_so_full_scale_is_unity
        val=1.0/(feat_matrix(ii,:) * feat_matrix(ii,:)');
        fprintf(fid,'%f\t',val);
    else
        
        fprintf(fid,'1.0\t');
    end;
   fprintf(fid,'-1.0\t');
   fprintf(fid,'0.0\t');
   fprintf(fid,'0.0\n');
end;
end;

fclose(fid);
   

