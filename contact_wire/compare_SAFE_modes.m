function  compare_SAFE_modes(show_meshes , phvel_or_waveno, mode_no )
% ----------------------------
%  show_meshes
%  phvel_or_waveno 1/2
%  subfolder
% ----------------------------
%  select the meshes to colutions to compare
%  make sure thay have the same number of modes
%  choose the mode to compare
% ----------------------------
% 0rder=[    ];

P_W_D = pwd  ;
cd('m:\SAFE_solutions')
temp_a                =       dir('*.mat')                                                                                       ;
all_file_names        =      {temp_a.name}                                                                                       ;
choice = listdlg('PromptString' , 'Select the meshes to solve' , 'SelectionMode' , 'multiple'  , 'ListString' , all_file_names)  ;

for index = 1: length(choice)
load(all_file_names{choice(index)})
dummy           =   all_file_names{choice(index)}    ;
dummy          =       dummy(10:strfind(dummy,'wear')-2)  ;
vals = find( dummy == '_' );
if ~isempty(vals); dummy(vals) = '.'; end
names_{index} = dummy;

freqs(:,index)  =      reshaped_proc_data.freq   (:,mode_no); 
ph_vel(:,index) =      reshaped_proc_data.ph_vel (:,mode_no);
waveno(:,index) =      reshaped_proc_data.waveno (:,mode_no);
meshes{index}   =      reshaped_proc_data.mesh;

end %for index = 1: length(choice)
cd(P_W_D)

figure
switch (phvel_or_waveno)
    case(1)
plot(freqs,ph_vel)
legend(names_)
    case(2)
plot(freqs,waveno)
legend(names_)        
end %switch (phvel_or_waveno)

if show_meshes  ==1
figure
sub_plots =[1,1;2,1;3,1;2,2;1,1;3,2;3,2;3,3;3,3;4,3;4,3;4,3];  

for index = 1: length(meshes)
mesh = meshes{index};
subplot(sub_plots(length(meshes),1),sub_plots(length(meshes),2),index)
title(names_{index})
fv.Vertices  = mesh.nd.pos;
fv.Faces     = mesh.el.nds;
patch(fv, 'FaceColor', 'c');
axis equal;
axis off;
end %for index = 1: length(meshes)
end % if show_meshes  ==1



end %function compare_SAFE_modes()


