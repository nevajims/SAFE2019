clear;
close all;
fe_fname='n:\grail\matlab\fe-data\2D-models\5mm_tap';

waveno_fname='c:\temp\rail_wavenumbers.txt';
gr_vel_fname='c:\temp\rail_group_velocities.txt';

save_as_cpp_file = 1;

freq_min=11.5e3;
freq_max=18.5e3;
freq_pts=100;
modes=[3,5,7,8,10];
%NUMBER_OF_MODE_COMBINATIONS = length(modes)^2 in C++ code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(fe_fname);
freq=linspace(freq_min,freq_max,freq_pts);
waveno=zeros(length(freq),length(modes));
group_velocities=zeros(length(freq),length(modes));

data_waveno=data_freq ./ data_ph_vel;

figure;
hold on;
for ii=1:length(modes);
   [i1,i2]=get_good_mode_indices(modes(ii),data_freq,data_mode_start_indices);
   group_velocities(:,ii)=interp1(data_freq(i1:i2),data_gr_vel(i1:i2),freq,'cubic')';
   plot(data_freq(i1:i2),data_gr_vel(i1:i2),'r.');
   plot(freq,group_velocities(:,ii),'b-');
end;

figure;
hold on;
for ii=1:length(modes);
   [i1,i2]=get_good_mode_indices(modes(ii),data_freq,data_mode_start_indices);
   waveno(:,ii)=interp1(data_freq(i1:i2),data_waveno(i1:i2),freq,'cubic')';
   plot(data_freq(i1:i2),data_waveno(i1:i2),'r.');
   plot(freq,waveno(:,ii),'b-');
end;

if save_as_cpp_file;
    fid=fopen('n:\grail\matlab\exportedRailCurves.cpp','wt');
    fprintf (fid,'Matlab exported file containing Rail Group Velocities\n');
    fprintf (fid,'double gDefaultRailVgr=\n');
    fprintf (fid,'int gDefaultRailModes[] = {');
    for ii=1:length(modes);
        fprintf (fid,'%i, ',modes(ii));
    end;
    fprintf (fid,'};\n\n');
    for jj=1:length(freq);
        fprintf (fid,'{%f, {',freq(jj));
        for ii=1:length(modes);
            fprintf (fid,'{%f,%f}, ',waveno(jj,ii),group_velocities(jj,ii));
        end;
        fprintf (fid,'}},\n');
    end;
    fclose(fid);
else;
    %%wavenumber file
    temp=[freq',waveno];
    temp=[[0,modes];temp];
    save(waveno_fname,'temp','-ascii','-double');

    %%vgr file
    temp=[freq',group_velocities];
    temp=[[0,modes];temp];
    save(gr_vel_fname,'temp','-ascii','-double');
end;