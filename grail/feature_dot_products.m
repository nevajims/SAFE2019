clear;
close all;
fname='d:\paul\visualCpp\railTester\Rail\rail_features.txt';

fid=fopen(fname,'rt');

%header lines

for ii=1:4;
    if (ii==2)
        feat_no=fscanf(fid,'Number of features: %i');
        fgetl(fid);
    else
        fgetl(fid);
    end;
end;

rc_matrix=zeros(feat_no,25);

for ii=1:feat_no;
    %read in 11 tab characters
    for jj=1:11;
        tmp=0;
        while (tmp~=9)
            tmp=fread(fid,1,'uchar');
        end;
    end;
    rc_matrix(ii,:)=fscanf(fid,'%f',25)';
    fgetl(fid);
end;

%normalise RC matrix
for ii=1:feat_no;
    rc_matrix(ii,:)=rc_matrix(ii,:) / sqrt (rc_matrix(ii,:) * rc_matrix(ii,:)');
end;

plot(rc_matrix');

%work out normalised dot products between each permutation of features
dp_matrix=zeros(feat_no,feat_no);
for ii=1:feat_no;
    for jj=1:feat_no;
        dp_matrix(ii,jj)=rc_matrix(ii,:)  * rc_matrix(jj,:)';
    end;
end;

disp(dp_matrix);


fclose(fid);