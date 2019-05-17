function  data = compare_SAFE_modes(show_meshes , phvel_or_waveno , mode_no,  max_freq )


%----------------------------
% linear_or_log   --   linear(1) and log (2)
%----------------------------
% choose maximum frequency to plot tos
% chose base as the number 1 
% ----------------------------
% show_meshes
% phvel_or_waveno 1/2
% subfolder
% ----------------------------
% put the number of the model in front of each file name
% have a file with the name in a seperate folder
%----------------------------
% select the meshes to solutions to compare
% make sure thay have the same number of modes
% choose the mode to compare
%----------------------------
% 0rder=[    ];

P_W_D = pwd  ;
cd('m:\SAFE_solutions')
[ordered_chosen_names,chosen_names]    = get_ordered_chosen_names();
data = get_data(ordered_chosen_names, chosen_names, mode_no );
cd(P_W_D)
plot_data(data, mode_no , phvel_or_waveno, max_freq)  

if show_meshes  ==1
plot_meshes(data.meshes,data.names_ )
end % if show_meshes  ==1

end %function compare_SAFE_modes()

function plot_meshes(meshes,names_)

figure
sub_plots =[1,1;2,1;3,1;2,2;3,2;3,2;3,3;3,3;3,3;4,3;4,3;4,3;4,4;4,4;4,4;4,4];  
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

end %function show_meshes(meshes)

function plot_data(data, mode_no , phvel_or_waveno, max_freq)  

 names_ =  data.names_ ;
 freqs  =  data.freqs  ;
 ph_vel =  data.ph_vel ;
 waveno =  data.waveno ;
  
%divider_ph_vel =ones(size(data.ph_vel,1),size(data.ph_vel,2))
divider_ph_vel = repmat(data.ph_vel(:,1),1,size(data.ph_vel,2));
divider_waveno = repmat(data.waveno(:,1),1,size(data.waveno,2));

figure
suptitle(['Mode ' num2str(mode_no)])
hold on

switch (phvel_or_waveno)
    case(1)
subplot(2,1,1)
plot(freqs , ph_vel)
legend(names_)
ylabel('Ph vel (m/s)') 
xlabel('Freq (Hz)')

subplot(2,1,2)
plot(freqs ,100 * ph_vel./divider_ph_vel)
ylabel('% difference') 
xlabel('Freq (Hz)')
    case(2)
subplot(2,1,1)
plot(freqs , waveno)
legend(names_)        
ylabel('Wave no (/m)') 
xlabel('Freq (Hz)')
subplot(2,1,2)
plot(freqs ,100 * waveno./divider_waveno )
ylabel('% difference') 
xlabel('Freq (Hz)')

end %switch (phvel_or_waveno)
xlim([0 max_freq])




end

function data =  get_data(ordered_chosen_names, chosen_names, mode_no)

for index = 1: length(ordered_chosen_names)
load(chosen_names{ordered_chosen_names(index)})

dummy           =   chosen_names{ordered_chosen_names(index)}    ;
vals            = find( dummy == '_' );
dummy           = dummy(min(vals)+1:max(vals)-1);
vals            = find( dummy == '_' );

if length(vals) ~=0
dummy(find(dummy=='_'))='.' ;    
end %if length(vals) ~=0

data.names_{index} = dummy;
data.freqs(:,index)  =      reshaped_proc_data.freq   (:,mode_no); 
data.ph_vel(:,index) =      reshaped_proc_data.ph_vel (:,mode_no);
data.waveno(:,index) =      reshaped_proc_data.waveno (:,mode_no);
data.meshes{index}   =      reshaped_proc_data.mesh;

end %for index = 1: length(choice)

end


function [ordered_chosen_names,chosen_names]= get_ordered_chosen_names () 

% choose the folder of solutions to compare
current_folder_info =  dir('*')                                                                                                  ;
isdirs ={current_folder_info.isdir}                                                                                              ;
dirnames ={current_folder_info.name}                                                                                             ;
dummy = cell2mat(isdirs)                                                                                                         ;
dir_inds = find(dummy == 1)                                                                                                      ;
dummy2 = dirnames(dir_inds)                                                                                                      ;
all_dir_names = {dummy2{3:end}}                                                                                                  ;
choice = listdlg('PromptString' , 'Select mesh group to solve' , 'SelectionMode' , 'single'  , 'ListString' , all_dir_names)     ;
cd(all_dir_names{choice})
temp_a                =       dir('*.mat')                                                                                       ;
all_file_names        =      {temp_a.name}                                                                                       ;
choice = listdlg('PromptString' , 'Select the meshes to solve' , 'SelectionMode' , 'multiple'  , 'ListString' , all_file_names)  ;
chosen_names = all_file_names(choice);
ordered_chosen_names = order_the_names(chosen_names) ;

end %function ordered_chosen_names = get_ordered_chosen_names () 


function ordered_chosen_names = order_the_names(chosen_names) 

for index = 1: length(chosen_names)
order_(index) =  min(find(chosen_names{index}=='_'));
end %for_index = 1: length(chosen_names)
[~,ordered_chosen_names]  = sort (order_) ;

end %function ordered_chosen_names = order_the_names(chosen_names) 





