function []  =  compare_with_disperse_2 (lite_index)
%DONE put the fenel data into the same format as SAFE-  inspect it with the plot single mode program

%
%
%
% create the reference file from the finest safe mode
%
% create the RPD-lite files for comparison-  they should have an option for a name in them but if its not there then
%
%
%
%
% Make a SAFE model the reference-  putting the names in for eacjh of the
% modes
% 
% produce a lookup table
if (nargin == 0) ;lite_index  = 1 ; end

r_p_d_l = get_SAFE_lite_files();

load mode_data_str mode_data_str  %this is the reference file format (produced from standard disperse ascii export)
load mode_lookup mode_lookup 

dis_mode_order = get_dis_mode_order(mode_lookup,mode_data_str);

dis_modes_to_plot = 1:length(dis_mode_order);
default_limit_options = {[0  0.05],[0 8],[0 15],[0 1]};  % should work out consistant way of determining these

fig_handle = figure('units','normalized','outerposition',[0.05 0.05 0.9 0.9],'color',[0.9 0.9 0.9],'DeleteFcn',@DeleteFcn_callback,'UserData',struct('point_index',3,'mode_index',5,'r_p_d_l',{r_p_d_l},'lite_index',lite_index,'lim_options',...
{default_limit_options},'mode_data_str',mode_data_str,'def_lim_options',{default_limit_options},'x_index',1,'y_index',3,'modes_to_plot',1:size(r_p_d_l{lite_index}.freq,2),'mode_lookup',mode_lookup,'dis_mode_order',...
dis_mode_order,'dis_modes_to_plot',dis_modes_to_plot,'freq_for_convergence',NaN,'convergence_plot_exists', 0 , 'modes_in_scope_indices',NaN,'modes_in_scope_names',NaN,'convergence_TextBox',-1,'convergence_fig_handle',-1,...
'modes_in_scope_interp_y_ordinate_val',-1,'modes_in_scope_display_text',-1,'conv_units',{{'kHz'  '1/m'  'm/s'  'm/s'}},'safe_modes_in_scope',NaN,'convergence_axis_handle',-1,'short_mesh_text',-1,'mesh_convergence_TextBox',-1));

uicontrol('Style','pushbutton', 'String', 'Select Mesh no','Position'        , [10 850 120 50] ,'Callback'  , @select_mesh_callback);           % select the mesh to display
uicontrol('Style','pushbutton', 'String', 'Select SAFE Modes','Position'     , [10 800 120 50] ,'Callback'  , @select_SAFE_modes_callback);     % select safe modes
uicontrol('Style','pushbutton', 'String', 'Select Disperse Modes','Position' , [10 750 120 50] ,'Callback'  , @select_Disperse_modes_callback); % select disperse modes
uicontrol('Style', 'popup','String', {'Phase Velocity(m/s)','Group Velocity(m/s)','WaveNo.(1/m)'} , 'Position', [130 800 120 50],'Callback' , @select_y_ordinate); % select the y odinate
uicontrol('Style','pushbutton', 'String', 'Select Freq','Position'      , [10 700 100 40]    ,'Callback'      , @choose_freq_for_convergence);                                 % select the mesh to display
uicontrol('Style','pushbutton', 'String', 'Remove Freq','Position'      , [100 700 100 40]   ,'Callback'      , @remove_freq);                                                 % select the mesh to display
uicontrol('Style','pushbutton', 'String', 'Plot Converge','Position'    , [190 700 100 40]   ,'Callback'      , @plot_convergence);                                            % select the mesh to display
%uicontrol('Style', 'popup','String', {'Freq(Hz)','WaveNo.(1/m)','Phase Velocity(m/s)','Group Velocity(m/s)'},   'Position', [10 420 120 50],'Callback' , @select_x_ordinate); % select the x odinate
% GUI Functions

fig_setup(fig_handle)

end %function []  =  compare_with_disperse (reshaped_proc_data_lite , mode_data_str )
%--------------Callbacks
function DeleteFcn_callback(object_handle,~)
plot_data_structure = get(object_handle,'UserData');

if ishandle(plot_data_structure.convergence_fig_handle)
delete(plot_data_structure.convergence_fig_handle)
end

end  % function Deletes any animation timer object that may exist at the time of closing the figure

function choose_freq_for_convergence (hObject, ~)
plot_data_structure      =   get(get(hObject,'Parent'),'UserData');
[freq_temp,~] =   ginput(1);
x_lims_current  = plot_data_structure.lim_options{plot_data_structure.x_index};

if freq_temp > x_lims_current(1) && freq_temp < x_lims_current(2)
plot_data_structure.freq_for_convergence =  freq_temp ;
plot_data_structure = find_convergence_modes(plot_data_structure);

if ishandle(plot_data_structure.convergence_fig_handle)
plot_data_structure =  update_convergence_axis(plot_data_structure);  
end

plot_data_structure  = reset_disperse_plot(plot_data_structure);
% Display the chosen frequency and the 
end %if freq_temp > x_lims_current(1) && freq_temp < x_lims_current(2)    

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end %function choose_x_ord_val_for_convergence(hObject, ~)

function remove_freq(hObject, ~)
plot_data_structure      =   get(get(hObject,'Parent'),'UserData');

plot_data_structure.freq_for_convergence   = NaN;
plot_data_structure.modes_in_scope_indices = NaN;
modes_in_scope_interp_y_ordinate_val       = NaN;      
plot_data_structure.safe_modes_in_scope    = -1 ;

if ishandle(plot_data_structure.convergence_TextBox)
delete(plot_data_structure.convergence_TextBox)
plot_data_structure.convergence_TextBox = -1;
end

if ishandle(plot_data_structure.convergence_fig_handle)
delete(plot_data_structure.convergence_fig_handle)
end


plot_data_structure  = reset_disperse_plot(plot_data_structure);
set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end

function plot_convergence(hObject, ~)
plot_data_structure      =   get(get(hObject,'Parent'),'UserData');

if ~isnan(plot_data_structure.freq_for_convergence)
if ~ishandle(plot_data_structure.convergence_fig_handle)
plot_data_structure.convergence_fig_handle = figure('units','normalized','outerposition',[0.05 0.05 0.9 0.9],'color',[0.9 0.9 0.9],'UserData',struct('root_figure_handle',plot_data_structure.fig_handle));
end
%plot_data_structure.convergence_fig_handle
plot_data_structure =  update_convergence_axis(plot_data_structure);

end %if ~isnan(plot_data_structure.freq_for_convergence)

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end % function plot_convergence(hObject, ~)

function plot_data_structure =  update_convergence_axis(plot_data_structure)
% plot in whatever config determined by the controls
safe_interpolated_y_ord_vals_in_scope   =   plot_data_structure.safe_interpolated_y_ord_vals_in_scope  ;
modes_in_scope_interp_y_ordinate_val    =   plot_data_structure.modes_in_scope_interp_y_ordinate_val   ;
modes_in_scope_names                    =   plot_data_structure.modes_in_scope_names                   ;
figure(plot_data_structure.convergence_fig_handle)

if ishandle (plot_data_structure.convergence_axis_handle)
delete(plot_data_structure.convergence_axis_handle)
end    

safe_mode_vals        =   cell(1,length(plot_data_structure.modes_in_scope_names));
safe_mode_percent     =   cell(1,length(plot_data_structure.modes_in_scope_names));
% do the split_legend here


if iscell(plot_data_structure.modes_in_scope_names)

for index = 1: length(plot_data_structure.modes_in_scope_names)
% for each mode get the mean and split percentage values

switch(size(safe_interpolated_y_ord_vals_in_scope{index},2))
     case(1)   
 safe_mode_vals{index} =  safe_interpolated_y_ord_vals_in_scope{index};
  
     case(2)
 safe_mode_vals{index} =  mean(safe_interpolated_y_ord_vals_in_scope{index},2);
otherwise
  disp('error should be one or two curves per mode')
end %switch(size(plot_data_structure.safe_interpolated_y_ord_vals_in_scope{index},2))

%go through each mode and if its zero make the % value NaN         safe_mode_vals{index}

for index_2 = 1 : length(safe_mode_vals{index})
if safe_mode_vals{index}(index_2) == 0
safe_mode_percent{index}(index_2) = NaN;
else
safe_mode_percent{index}(index_2) =   abs(100*(safe_mode_vals{index}(index_2) - modes_in_scope_interp_y_ordinate_val{index})/modes_in_scope_interp_y_ordinate_val{index});
end %if safe_mode_vals{index}(index_2) == 0
end %for index_2 = 1 : length(safe_mode_percent{index})
end  %for index = 1: length(plot_data_structure.modes_in_scope_names)

mesh_nos  =  [1:length(plot_data_structure.r_p_d_l)];
plot_data_structure.convergence_axis_handle =  subplot( 1 , 1 , 1 );
xlim([0.5 length(plot_data_structure.r_p_d_l)+0.5])

hold on
h_temp = xlabel('Mesh number');
set(h_temp,'FontSize', 14) 
h_temp_2 = ylabel('Difference with reference(%)');
set(h_temp_2,'FontSize', 14) 



map_2 = colormap(jet(256));
for index = 1: length(modes_in_scope_names)
h_conv{index} = plot(mesh_nos , safe_mode_percent{index},'color',map_2(floor(index*length(map_2)/length(modes_in_scope_names)),:));
set(h_conv{index},'linewidth',6)
end %for index = 1: length(plot_data_structure.modes_in_scope_names)

h_temp_3 = title([plot_data_structure.mode_data_str.units_long_name{plot_data_structure.y_index},' @ freq = ',num2str(round( 10000*plot_data_structure.freq_for_convergence)/10),' kHz.']);
set(h_temp_3,'FontSize', 18) 
legend(modes_in_scope_names)

% Textbox here

if isobject(plot_data_structure.mesh_convergence_TextBox)
delete(plot_data_structure.mesh_convergence_TextBox)
end %if isobject(plot_data_structure.mesh_convergence_TextBox)

mesh_convergence_TextBox = uicontrol('style','text');
set(mesh_convergence_TextBox,'position',[1100 710 320 130])
set(mesh_convergence_TextBox,'BackgroundColor',[1 1 1])
set(mesh_convergence_TextBox,'HorizontalAlignment','left')
set(mesh_convergence_TextBox,'FontSize', 9)

set(mesh_convergence_TextBox,'String',[{'Mesh Details:'},plot_data_structure.short_mesh_text']);                      
plot_data_structure.mesh_convergence_TextBox = mesh_convergence_TextBox;

else
delete(plot_data_structure.convergence_fig_handle)    

end %iscell

end %function plot_data_structure =  update_convergence_axis(plot_data_structure )

function select_y_ordinate(hObject, ~)
plot_data_structure                               =          get(get(hObject,'Parent'),'UserData');
order_ = [3,4,2];
temp_index  = get(hObject,'Value');
plot_data_structure.y_index =  order_(temp_index);

plot_data_structure                               =          find_convergence_modes(plot_data_structure);

if ishandle(plot_data_structure.convergence_fig_handle)
plot_data_structure =  update_convergence_axis(plot_data_structure);  
end

plot_data_structure                               =          reset_disperse_plot(plot_data_structure);    

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end

function select_Disperse_modes_callback (hObject, ~)
plot_data_structure                               =          get(get(hObject,'Parent'),'UserData');
[temp_val,ok] = listdlg('PromptString','Select modes to display:','SelectionMode','multiple','ListString',{plot_data_structure.mode_data_str.mode_name{plot_data_structure.dis_mode_order}});

if ok ==1 
plot_data_structure.dis_modes_to_plot   = temp_val;

if ~isnan(plot_data_structure.freq_for_convergence)
plot_data_structure = find_convergence_modes(plot_data_structure);
end %if ~isnan(plot_data_structure.freq_for_convergence)

plot_data_structure   =  reset_disperse_plot(plot_data_structure);


if ishandle(plot_data_structure.convergence_fig_handle)
plot_data_structure =  update_convergence_axis(plot_data_structure);  
end

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end

end

function select_SAFE_modes_callback (hObject, ~)
plot_data_structure                               =          get(get(hObject,'Parent'),'UserData');
%[temp_val,ok]             =          listdlg('PromptString','Select modes to display:','SelectionMode','multiple','ListString',arrayfun(@num2str,(1:size(plot_data_structure.r_p_d_l{1}.freq , 2)),'unif',0));
[temp_val,ok]              =          listdlg('PromptString','Select modes to display:','SelectionMode','multiple','ListString',plot_data_structure.legend_text);

if ok ==1
plot_data_structure.modes_to_plot = temp_val;
plot_data_structure                               =          reset_disperse_plot(plot_data_structure);

if ishandle(plot_data_structure.convergence_fig_handle)
plot_data_structure =  update_convergence_axis(plot_data_structure);  
end

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure);
end %if ok ==1
end %function  select_SAFE_modes_callback (hObject, ~)

function select_mesh_callback(hObject,~ )
plot_data_structure                               =          get(get(hObject,'Parent'),'UserData');

[plot_data_structure.lite_index,~]                =          listdlg('PromptString','Select modes to display:','SelectionMode','single','ListString',arrayfun(@num2str,(1:size(plot_data_structure.r_p_d_l, 2)),'unif',0));

if  ~isnan(plot_data_structure.freq_for_convergence)
plot_data_structure = find_convergence_modes(plot_data_structure);
end %if  ~isnan(plot_data_structure.freq_for_convergence)

[plot_data_structure]                             =          create_legend_text_SAFE(plot_data_structure)                 ;
plot_data_structure                               =          reset_disperse_plot(plot_data_structure) ;
plot_data_structure                               =          reset_mesh_plot(plot_data_structure)      ;

set(plot_data_structure.fig_handle , 'UserData' , plot_data_structure)                                ;
end % function select_mesh_callback(hObject, ~)

function fig_setup(fig_handle)
plot_data_structure                               =          get(fig_handle,'UserData')                     ;
plot_data_structure.fig_handle                    =          fig_handle                                     ; 
[plot_data_structure]                             =          create_legend_text_SAFE(plot_data_structure)   ;

plot_data_structure                               =          get_short_mesh_text(plot_data_structure)       ;

% [mesh_stats] = get_mesh_stats(mesh)

figure(plot_data_structure.fig_handle)
plot_data_structure.axis_dis_handle    = subplot(3,1,1);
set(plot_data_structure.axis_dis_handle,'visible','off')

plot_data_structure.axis_mesh_handle   = subplot(3,1,2);
set(plot_data_structure.axis_mesh_handle,'visible','off')

plot_data_structure.axis_ghost_handle  = subplot(3,1,3);
set(plot_data_structure.axis_ghost_handle,'visible','off')

% set the default colormap

plot_data_structure                               =          reset_disperse_plot(plot_data_structure)  ;
plot_data_structure                               =          reset_mesh_plot(plot_data_structure)      ; 
set(fig_handle , 'UserData' , plot_data_structure)                                                     ;

end %function fig_setup(fig_handle)

function plot_data_structure  = reset_mesh_plot(plot_data_structure)
reshaped_proc_data_lite = plot_data_structure.r_p_d_l{plot_data_structure.lite_index};
figure(plot_data_structure.fig_handle)
axes(plot_data_structure.axis_mesh_handle)
set(plot_data_structure.axis_mesh_handle,'Position',[-0.05 0.01 0.25 0.25])
cla
axis equal
hold on
axes(plot_data_structure.axis_mesh_handle)

fv.Faces       =       reshaped_proc_data_lite.mesh.el.nds                            ;
fv.Vertices    =       reshaped_proc_data_lite.mesh.nd.pos                            ;  
mesh_handle{1} =       patch(fv, 'EdgeColor','k','FaceColor','c', 'LineWidth',0.01)   ;


%---------------------------------
% Put in text for mesh statistics
%---------------------------------
meshTextBox = uicontrol('style','text');
set(meshTextBox,'position',[35 240 200 80])
set(meshTextBox,'BackgroundColor',[0.9 0.9 0.9])
set(meshTextBox,'HorizontalAlignment','left')
set(meshTextBox,'FontSize', 8)
[mesh_stats] = get_mesh_stats(reshaped_proc_data_lite.mesh);
set(meshTextBox,'String',{['Mesh: ',num2str(plot_data_structure.lite_index)],['Number of elements: ',num2str(length(reshaped_proc_data_lite.mesh.el.nds))],['Number of nodes: ',...
num2str(length(reshaped_proc_data_lite.mesh.nd.pos))], ['Mean Element size: ',num2str(round(mesh_stats.mean_len*1000000)/1000),' mm.'],['Standard Deviation: ',num2str(round(mesh_stats.std_pc*100)/100),' %.']})

end %function plot_data_structure  = reset_mesh_plot(plot_data_structure)

function plot_data_structure  = reset_disperse_plot(plot_data_structure)
% dis_modes_to_plot
% plot the disperse with a thick line
% plot the SAFE with a thin line and points
% plot the selected point on the Safe curve
%-------------------------------------------
% need:
% Y index
% x index
% lim vals
% axes labels
% selected safe modes
% point and mode index
%-------------------------------------------
map_ = colormap(jet(256));
mode_data_str           = plot_data_structure.mode_data_str                          ;
x_index                 = plot_data_structure.x_index                                ;
y_index                 = plot_data_structure.y_index                                ;
reshaped_proc_data_lite = plot_data_structure.r_p_d_l{plot_data_structure.lite_index};
modes_to_plot           = plot_data_structure.modes_to_plot                          ;
dis_mode_order          = plot_data_structure.dis_mode_order                         ;
dis_modes_to_plot       = plot_data_structure.dis_modes_to_plot                      ;
axes(plot_data_structure.axis_dis_handle)
set(plot_data_structure.axis_dis_handle,'visible','on')
cla
hold on

for index = 1 :length (dis_modes_to_plot)
h_dis{index}  =   plot(mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))}(:,x_index),mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))}(:,y_index),'-','color',map_(floor(index*length(map_)/length(dis_modes_to_plot)),:));      
set(h_dis{index},'linewidth',5)
leg_temp{index} = mode_data_str.mode_name{dis_mode_order(dis_modes_to_plot(index))};
end %for index = 1 :length (dis_modes_to_plot)
legend(leg_temp,'location','EastOutside')
h_temp_a = title(['Mesh: ',num2str(plot_data_structure.lite_index) ' vs Disperse.']);
set(h_temp_a,'FontSize', 18) 
h_temp = xlabel([mode_data_str.units_long_name{x_index},'(',mode_data_str.units{x_index},')']);
set(h_temp,'FontSize', 14) 
h_temp_2 = ylabel([mode_data_str.units_long_name{y_index},'(',mode_data_str.units{y_index},')']);
set(h_temp_2,'FontSize', 14) 

xlim(plot_data_structure.lim_options{x_index});
ylim(plot_data_structure.lim_options{y_index});

set(plot_data_structure.axis_dis_handle,'Position',[0.18 0.1 0.63 0.83])

map_2 = flipud(map_);
for index = 1 :length(modes_to_plot) 
switch(x_index) 
    case(1)    
x_vals_temp     = reshaped_proc_data_lite.freq(:,modes_to_plot(index))          ;
    case(2)    
x_vals_temp     = reshaped_proc_data_lite.waveno(:,modes_to_plot(index))        ;        
    case(3)    
x_vals_temp     = reshaped_proc_data_lite.ph_vel(:,modes_to_plot(index))        ;        
    case(4)   
x_vals_temp     = reshaped_proc_data_lite.group_velocity(:,modes_to_plot(index));
end %switch( plot_data_structure.x_label_index) 

switch(y_index) 
    case(1)    
y_vals_temp     = reshaped_proc_data_lite.freq(:,modes_to_plot(index))          ;
    case(2)    
y_vals_temp     = reshaped_proc_data_lite.waveno(:,modes_to_plot(index))        ;         
    case(3)    
y_vals_temp     = reshaped_proc_data_lite.ph_vel(:,modes_to_plot(index))        ;        
    case(4)   
y_vals_temp     = reshaped_proc_data_lite.group_velocity(:,modes_to_plot(index));
end %switch( plot_data_structure.x_label_index) 

h_safe{index} =  plot(x_vals_temp,y_vals_temp,':','color',map_2(floor(index*length(map_2)/length(modes_to_plot)),:));
set(h_safe{index},'linewidth',2)
end % for index = 1 :length(modes_to_plot) 

if ~isnan(plot_data_structure.freq_for_convergence)
y_lims_current           =     plot_data_structure.lim_options{plot_data_structure.y_index};
x_lims_current  = plot_data_structure.lim_options{plot_data_structure.x_index};
x_range_current = x_lims_current(2)-x_lims_current(1);

plot([plot_data_structure.freq_for_convergence-x_range_current/150,plot_data_structure.freq_for_convergence-x_range_current/150],[y_lims_current(1),y_lims_current(2)],'k:')     
plot([plot_data_structure.freq_for_convergence,plot_data_structure.freq_for_convergence],[y_lims_current(1),y_lims_current(2)],'k-')     
plot([plot_data_structure.freq_for_convergence+x_range_current/150,plot_data_structure.freq_for_convergence+x_range_current/150],[y_lims_current(1),y_lims_current(2)],'k:')     

if iscell( plot_data_structure.modes_in_scope_names)

for index = 1:length(plot_data_structure.modes_in_scope_interp_y_ordinate_val)
plot([x_lims_current(1) x_lims_current(2)],[plot_data_structure.modes_in_scope_interp_y_ordinate_val{index} ,plot_data_structure.modes_in_scope_interp_y_ordinate_val{index}], 'g:')     
end %for index = 1:plot_data_structure.modes_in_scope_interp_y_ordinate_val

if ishandle(plot_data_structure.convergence_TextBox)
delete(plot_data_structure.convergence_TextBox)
end

convergence_TextBox = uicontrol('style','text');
set(convergence_TextBox,'position',[15 350 250 330])
set(convergence_TextBox,'BackgroundColor',[0.9 0.9 0.9])
set(convergence_TextBox,'HorizontalAlignment','left')
set(convergence_TextBox,'FontSize', 8)

set(convergence_TextBox,'String',[{['Convergence Freq: ',num2str(round(plot_data_structure.freq_for_convergence*1000)),'kHz '],' ',['Reference Modes: ']},...
regroup_cell_string_array(plot_data_structure.modes_in_scope_display_text,3),{[' '],['Mesh ',num2str(plot_data_structure.lite_index),' Modes: ']},...
regroup_cell_string_array(plot_data_structure.safe_modes_in_scope_display_text,2)]);                      
plot_data_structure.convergence_TextBox = convergence_TextBox ;

else
if ishandle(plot_data_structure.convergence_TextBox)
delete(plot_data_structure.convergence_TextBox)
end
plot_data_structure.convergence_TextBox = -1;    
end

end %if ~isnan(plot_data_structure.freq_for_convergence)
axes(plot_data_structure.axis_ghost_handle)
cla
hold on
set(plot_data_structure.axis_ghost_handle,'Position',[0 0 0.01 0.01])

for index = 1 :length(modes_to_plot) 
switch(x_index) 
    case(1)    
x_vals_temp     = reshaped_proc_data_lite.freq(:,modes_to_plot(index))          ;
    case(2)    
x_vals_temp     = reshaped_proc_data_lite.waveno(:,modes_to_plot(index))        ;        
    case(3)    
x_vals_temp     = reshaped_proc_data_lite.ph_vel(:,modes_to_plot(index))        ;        
    case(4)   
x_vals_temp     = reshaped_proc_data_lite.group_velocity(:,modes_to_plot(index));
end %switch( plot_data_structure.x_label_index) 

switch(y_index) 
    case(1)    
y_vals_temp     = reshaped_proc_data_lite.freq(:,modes_to_plot(index))          ;
    case(2)    
y_vals_temp     = reshaped_proc_data_lite.waveno(:,modes_to_plot(index))        ;         
    case(3)    
y_vals_temp     = reshaped_proc_data_lite.ph_vel(:,modes_to_plot(index))        ;        
    case(4)   
y_vals_temp     = reshaped_proc_data_lite.group_velocity(:,modes_to_plot(index));
end %switch( plot_data_structure.x_label_index) 

h_safe_2{index} =  plot(x_vals_temp,y_vals_temp,':','color',map_2(floor(index*length(map_2)/length(modes_to_plot)),:));
set(h_safe_2{index},'linewidth',2)
end % for index = 1 :length(modes_to_plot) 
leg_handle = legend(plot_data_structure.legend_text{plot_data_structure.modes_to_plot},'location','EastOutside');
set(leg_handle,'Position',[0.9  (0.93 - 0.83*(length(plot_data_structure.modes_to_plot)/40))- 0.4*(40-length(plot_data_structure.modes_to_plot))/40   0.04 0.83 * (length(plot_data_structure.modes_to_plot)/40)]); 
end %function plot_data_structure  = reset_plot(plot_data_structure)

function r_p_d_l = get_SAFE_lite_files() 
dir_struct = dir('reshaped_proc_data_lite*.mat');
if ~isempty(dir_struct)
names_ = {dir_struct.name} ;
for index = 1 : length(names_) 
load(names_{index},'reshaped_proc_data_lite')
% put in the same units as disperse

reshaped_proc_data_lite.freq             = reshaped_proc_data_lite.freq/1E6             ;
reshaped_proc_data_lite.ph_vel           = reshaped_proc_data_lite.ph_vel/1000          ;
reshaped_proc_data_lite.waveno           = reshaped_proc_data_lite.waveno/1000          ;
reshaped_proc_data_lite.group_velocity   = reshaped_proc_data_lite.group_velocity/(1000*2*pi)  ;

r_p_d_l{index} = reshaped_proc_data_lite ;
end % for index = 1 : length(names_) 

else
r_p_d_l = -1;
disp('there are no relavent safe data files in this directory')
end %if length(dir_struct) ~=0
end  %function try__ = get_SAFE_lite files() 

function dis_mode_order = get_dis_mode_order(mode_lookup,mode_data_str)

if length (mode_data_str.mode_name) == length (mode_lookup.mode_name)
    
for index = 1 : length(mode_lookup.mode_name)
dis_mode_order(index) =  find(strcmp(mode_data_str.mode_name,mode_lookup.mode_name{index}));
end %for index = 1:length (mode_lookup.mode_name)

else
    disp('error incorrect number of elements in the mode lookup table')
    dis_mode_order = -1;
end %if length (mode_data_str.mode_name) == length (mode_lookup.mode_name)

end % function dis_mode_order = try__(mode_lookup,mode_data_str)

function [mesh_stats] = get_mesh_stats(mesh)
node_pos          = mesh.nd.pos(:,1) + 1i*mesh.nd.pos(:,2)   ;
element_nodes     = mesh.el.nds                              ;
nodes_per_element = size(element_nodes,2)                    ;
no_of_elements    = size(element_nodes,1)                    ;
lengths           = zeros(no_of_elements,nodes_per_element)  ;

for index = 1 : no_of_elements
for index_2 = 1: nodes_per_element   
point_1 = index_2;
if index_2 == nodes_per_element   
point_2 = 1;
else
point_2 = point_1+1;
end %if index_2 == nodes_per_element   
lengths(index,index_2)  =   abs(node_pos(element_nodes(index,point_1))-node_pos(element_nodes(index,point_2)));
end %for index_2 = 1: nodes_per_element   
end %for index = 1 : no_of_elements
mesh_stats.no_of_elements = no_of_elements                            ;
mesh_stats.mean_len       = mean(mean(lengths))                       ;
mesh_stats.std_pc         = 100*std(std(lengths))/mean(mean(lengths)) ;


end %function [element_length_stats ] = get_mean_element_length(mesh)

function [plot_data_structure] = create_legend_text_SAFE(plot_data_structure)
%disp(num2str(plot_data_structure.lite_index))

reshaped_proc_data_lite  =   plot_data_structure.r_p_d_l{plot_data_structure.lite_index} ;
mode_lookup              =   plot_data_structure.mode_lookup                             ;
mesh_no                  =   plot_data_structure.lite_index                              ;

legend_text = cell(1,size(reshaped_proc_data_lite.freq,2));

if isstruct(mode_lookup)
mode_temp  = zeros(size(mode_lookup.mode_indices,2) ,2);
for index          =      1:size(mode_lookup.mode_indices,2) 
mode_temp(2*index-1,1)  = index ;  
mode_temp(2*index,1)    = index ;  
mode_temp(2*index-1,2)  = mode_lookup.mode_indices{index}(mesh_no ,1);
mode_temp(2*index,2)    = mode_lookup.mode_indices{index}(mesh_no ,2); 

end %for index = 1:size(mode_lookup.mode_indices,2)

for index = 1: size(reshaped_proc_data_lite.freq,2)
temp_index = mode_temp(find(mode_temp(:,2)== index ),1);

if isempty(temp_index)
legend_text{index} = [num2str(index),', [?]'];
elseif length(temp_index) ==1
   
if index > 9    
legend_text{index} = [num2str(index),', [',mode_lookup.mode_name{temp_index} ,']'];
else
legend_text{index} = [num2str(index),',  [',mode_lookup.mode_name{temp_index} ,']'];
end

else
disp('Error mode should equate to either 1 or zero disperse modes')   
end
end %for index = 1: size(reshaped_proc_data_lite.freq,2)
else
    
for index = 1: size(reshaped_proc_data_lite.freq,2)
legend_text{index} = [num2str(index)];
end %for index = 1: size(reshaped_proc_data_lite.freq,2)
end % if isstruct(mode_lookup)
plot_data_structure.legend_text  =  legend_text;
end % function [plot_data_structure] = create_legend_extension_text(plot_data_structure)

function plot_data_structure = find_convergence_modes(plot_data_structure)

freq_for_convergence     =     plot_data_structure.freq_for_convergence      ;
mode_data_str            =     plot_data_structure.mode_data_str             ;   
dis_modes_to_plot        =     plot_data_structure.dis_modes_to_plot         ;
dis_mode_order           =     plot_data_structure.dis_mode_order            ;
y_lims_current           =     plot_data_structure.lim_options{plot_data_structure.y_index};

% modes_in_scope_index = []                                                  ;

modes_in_scope_indices = zeros(length(dis_modes_to_plot));
counter_ = 0;

for index = 1 : length(dis_modes_to_plot)
    
temp_valid_index  =    find (   mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))} (:,plot_data_structure.y_index) < y_lims_current(2)*0.8 &...
mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))} (:,plot_data_structure.y_index) > y_lims_current(2)*0.1) ;

%temp_valid_index  =    find (   mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))} (:,plot_data_structure.y_index) < y_lims_current(2)*0.8 &...
%mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))} (:,plot_data_structure.y_index) > y_lims_current(1)) ;



temp_max_val      =    max(mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))}(temp_valid_index,plot_data_structure.x_index));
temp_min_val      =    min(mode_data_str.data{dis_mode_order(dis_modes_to_plot(index))}(temp_valid_index,plot_data_structure.x_index));

if freq_for_convergence > temp_min_val  && freq_for_convergence < temp_max_val
counter_ = counter_+1;
modes_in_scope_indices (counter_) = index;
valid_index{counter_} = temp_valid_index;
end   %if freq_for_convergence > temp_min_val  && freq_for_convergence < temp_max_val


end % for index = 1 : length(dis_modes_to_plot)

modes_in_scope_indices                      =   modes_in_scope_indices(find( modes_in_scope_indices~=0 ))  ;
modes_in_scope_names                        =   cell(length(modes_in_scope_indices),1)                     ;
modes_in_scope_display_text                 =   cell(length(modes_in_scope_indices),1)                     ;
modes_in_scope_interp_y_ordinate_val        =   cell(length(modes_in_scope_indices),1)                     ;

for index = 1: length(modes_in_scope_indices)
modes_in_scope_names{index} = mode_data_str.mode_name{dis_mode_order(dis_modes_to_plot(modes_in_scope_indices(index)))};

modes_in_scope_interp_y_ordinate_val{index} = interp1( mode_data_str.data{dis_mode_order(dis_modes_to_plot(modes_in_scope_indices(index)))}(valid_index{index},plot_data_structure.x_index),mode_data_str.data{dis_mode_order(dis_modes_to_plot(modes_in_scope_indices(index)))}(valid_index{index},plot_data_structure.y_index),freq_for_convergence, 'PCHIP');
%
%modes_in_scope_interp_y_ordinate_val{index} = spline( mode_data_str.data{dis_mode_order(dis_modes_to_plot(modes_in_scope_indices(index)))}(valid_index{index},plot_data_structure.x_index),mode_data_str.data{dis_mode_order(dis_modes_to_plot(modes_in_scope_indices(index)))}(valid_index{index},plot_data_structure.y_index),freq_for_convergence);


modes_in_scope_display_text{index} = [modes_in_scope_names{index},' [',num2str(round(modes_in_scope_interp_y_ordinate_val{index}*1000)) ,  plot_data_structure.conv_units{plot_data_structure.y_index},']'];

end %for index = 1:plot_data_structure.modes_in_scope_indices

plot_data_structure.modes_in_scope_names                   =   modes_in_scope_names';
plot_data_structure.modes_in_scope_indices                 =   modes_in_scope_indices;
plot_data_structure.modes_in_scope_interp_y_ordinate_val   =   modes_in_scope_interp_y_ordinate_val;
plot_data_structure.modes_in_scope_display_text            =   modes_in_scope_display_text;



if length(plot_data_structure.modes_in_scope_names)==0
plot_data_structure.modes_in_scope_names = NaN;
plot_data_structure.safe_modes_in_scope  = NaN;
plot_data_structure.safe_interpolated_y_ord_vals_in_scope = NaN;
plot_data_structure.safe_modes_in_scope_display_text   = NaN;

else
plot_data_structure    =  get_safe_convergence_values(plot_data_structure);
end %if length(plot_data_structure.modes_in_scope_names)==0

end %function plot_data_structure = find_convergence_modes(plot_data_structure);

function plot_data_structure = get_safe_convergence_values(plot_data_structure)
modes_in_scope_names      =  plot_data_structure.modes_in_scope_names       ;
mode_lookup_name          =  plot_data_structure.mode_lookup.mode_name      ;
mode_lookup_indices       =  plot_data_structure.mode_lookup.mode_indices   ;  
freq_for_convergence      =  plot_data_structure.freq_for_convergence       ;
y_index                   =  plot_data_structure.y_index                    ;


for index = 1: length(modes_in_scope_names)
current_name = modes_in_scope_names{index};
count = 0;    
for index_2 = 1 : length(mode_lookup_name) 
if strcmp(mode_lookup_name{index_2},current_name)==1
count = count+1;
safe_modes_in_scope{index}=mode_lookup_indices{index_2}; 
end % if strcmp(mode_lookup_name{index_2},current_name{index})
end %for index_2 = 1 : length(mode_lookup_name) 

% safe_modes_in_scope--   deal with the case when there are no safe modes
% in scope

if count ~= 1
if count == 0
disp([' error no mode found for ',current_name] )   
else
disp(['error',num2str(count),' modes found for ',current_name{index}])        
end % if count = 0    
end % if count ~= 1
end % for index = 1: length(modes_in_scope_names)



for mode_index = 1:length(safe_modes_in_scope)
for mesh_index = 1:size(safe_modes_in_scope{mode_index},1)    
for pair_index = 1:size(safe_modes_in_scope{mode_index},2) % this will always be 2
    
if  safe_modes_in_scope {mode_index}(mesh_index,pair_index) == 0 || isnan(safe_modes_in_scope {mode_index}(mesh_index,pair_index))    
   
safe_y_ord_vals_in_scope{mode_index}(mesh_index,pair_index) = NaN;

else    
% get 3 values on either side of chodsen freq-  create function for this

safe_mode_index_temp      =  safe_modes_in_scope {mode_index}(mesh_index,pair_index);
%disp(num2str(safe_mode_index_temp))
current_freq_vals_temp    =  plot_data_structure.r_p_d_l{mesh_index}.freq(:,safe_mode_index_temp); 

switch(plot_data_structure.y_index)
    case(2)
current_y_ord_vals_temp   =  plot_data_structure.r_p_d_l{mesh_index}.waveno(:,safe_mode_index_temp);        
    case(3)
current_y_ord_vals_temp   =  plot_data_structure.r_p_d_l{mesh_index}.ph_vel(:,safe_mode_index_temp);        
    case(4)
current_y_ord_vals_temp   =  plot_data_structure.r_p_d_l{mesh_index}.group_velocity(:,safe_mode_index_temp);
end %switch(plot_data_structure.y_index)

safe_interpolated_y_ord_vals_in_scope{mode_index}(mesh_index,pair_index)   = interp1(current_freq_vals_temp , current_y_ord_vals_temp , freq_for_convergence,'PCHIP');

end %if  isnan(safe_modes_in_scope {mode_index}(mesh_index,pair_index))    

end %for pair_index = 1:size(plot_data_structure.safe_modes_in_scope{mode_index},2) % this will always be 2
end %for mesh_index = size(plot_data_structure.safe_modes_in_scope{mode_index},1)    
end %for mode_index = 1:length(safe_modes_in_scope)

for mode_index = 1:length(safe_modes_in_scope)
% for each mode --  is it a double or not    

switch (size(safe_interpolated_y_ord_vals_in_scope{mode_index},2))
    case(1)
safe_modes_in_scope_display_text{mode_index} = [modes_in_scope_names{mode_index},' [',num2str(round(safe_interpolated_y_ord_vals_in_scope{mode_index}(plot_data_structure.lite_index,1) *1000)),plot_data_structure.conv_units{plot_data_structure.y_index},']'];
    case(2)
safe_modes_in_scope_display_text{mode_index} = [modes_in_scope_names{mode_index},' [',num2str(round(safe_interpolated_y_ord_vals_in_scope{mode_index}(plot_data_structure.lite_index,1) *1000)),',', num2str(round(safe_interpolated_y_ord_vals_in_scope{mode_index}(plot_data_structure.lite_index,2) *1000)) ,plot_data_structure.conv_units{plot_data_structure.y_index},']'];        

end %switch

plot_data_structure.safe_modes_in_scope = safe_modes_in_scope;
plot_data_structure.safe_interpolated_y_ord_vals_in_scope = safe_interpolated_y_ord_vals_in_scope';
plot_data_structure.safe_modes_in_scope_display_text   = safe_modes_in_scope_display_text;

end %for mode_index = 1:length(safe_modes_in_scope) 

end %function   plot_data_structure    =  get_safe_convergence_values(plot_data_structure)

function regrouped_array =  regroup_cell_string_array(cell_string_array,grouping_number) 

if length(cell_string_array)~= 0
group_count = 0;
group_index = 1;
for index = 1: length(cell_string_array)
group_count = group_count+1;
if   group_count > grouping_number
group_index = group_index + 1; 
group_count = 1;
end
if group_count == 1
regrouped_array{group_index}  = [cell_string_array{index}];
else
regrouped_array{group_index} = [regrouped_array{group_index},',',cell_string_array{index}];
end %if group_count = 1
if   group_count == grouping_number && index ~= length(cell_string_array)
regrouped_array{group_index} = [regrouped_array{group_index},','];    
end
if index == length(cell_string_array)
regrouped_array{group_index} = [regrouped_array{group_index},'.'];            
end %if index == length(cell_string_array)
end %for index = 1: length(cell_string_array)
else
regrouped_array{1} = '';
end %if length(cell_string_array)~= 0

end 

function plot_data_structure  =  get_short_mesh_text(plot_data_structure)       
r_p_d_l = plot_data_structure.r_p_d_l;
short_mesh_text = cell(length(r_p_d_l),1);
for index = 1:length(r_p_d_l)
[mesh_stats_temp] = get_mesh_stats(r_p_d_l{index}.mesh);
short_mesh_text{index}  =  ['Mesh ',num2str(index),': # elements = ',num2str(mesh_stats_temp.no_of_elements),', mean length = ',num2str(round(mesh_stats_temp.mean_len*1000000)/1000),' mm.']; 
end %for index = 1:lenghth(r_p_d_l)
plot_data_structure.short_mesh_text = short_mesh_text;
end %plot_data_structure   = get_short_mesh_text(plot_data_structure);