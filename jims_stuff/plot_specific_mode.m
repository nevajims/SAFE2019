% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% To do:
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% options for correcting the dispersion curves
% piecewise spline interpolation between points
% why are the 2d animations so jumpy  (when the 3d animation is smooth)
% some kind of visual display of the mode amplitude  abs(x  y  z) - as color superimposed   
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% main program
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function [] =   plot_specific_mode(reshaped_proc_data)
if (nargin == 0) ; reshaped_proc_data = -1 ; end
% reshaped_proc_data.group_velocity = reshaped_proc_data.group_velocity *2*pi;
reshaped_proc_data.group_velocity = calc_group_vel(reshaped_proc_data.freq,reshaped_proc_data.waveno);
% set up figure as parent object and put all relevant data in this-  all
% other objects will be children of this and can therfore access the data
% structure held in 'UserData'  AKA   plot_data_structure
default_limit_options = {[0  300],[0 5],[0 1000],[0 2000]};


fig_handle = figure('units','normalized','outerposition',[0.05 0.05 0.9 0.9],'DeleteFcn',@DeleteFcn_callback ,'UserData',struct('undeformed_node_positions',-1,...
'mult_factor',1,'max_mult_factor',2,'mesh_view1',[180 -90],'mesh_view2',[0 90],'mesh_view3',[90 0],'point_index',3,'show_displacement',0, ...
'mode_index',1,'reshaped_proc_data',reshaped_proc_data,'lim_options',{default_limit_options},'def_lim_options',{default_limit_options} ,'label_options',...
{{'Freq(Hz)','WaveNo.(1/m)','Phase Velocity(m/s)','Group Velocity(m/s)'}},'x_index',1,'y_index',3,'cartesian_or_cylindrical',1,'mode_shape_display_option',...
1,'animate_button_value',0,'animation_timer_handle',-1,'current_animation_angle',0,'mult_factor_speed',30,'modes_to_plot',1:size(reshaped_proc_data.freq,2),'show_mesh',0));


% menus-------------------------------------------------------------------------------------------------
menu_handle             = uimenu(fig_handle, 'Label','DISPERSION OPTIONS')                               ;
uimenu(menu_handle, 'Label','Open disp file','Callback',@Open_new_file)                                  ; % open a new dispersion file 
%--------------------------------------------------------------------------------------------------------

% buttons, sliders etc-----------------------------------------------------------------------------------
slider_handle    = uicontrol('Style','slider','Min',1,'Max',2,'Value',1.5,'Position'         , [20 20 120 20]    ,  'Callback' , @slider_func_mag)                                  ; % controls magnification of animation
slider_handle_2  = uicontrol('Style','slider','Min',10,'Max',80,'Value',30,'Position'        , [960 440 120 20]  ,  'Callback' , @slider_func_speed)                                ; % controls speed of animation
slider_handle_xl = uicontrol('Style','slider','Min',0,'Max',15000,'Value',1,'Position'      , [10 850 120 20]   ,  'Callback' , @slider_func_xl); % ,'String',['variable=',num2str(1)]);
slider_handle_xh = uicontrol('Style','slider','Min',0,'Max',15000,'Value',1,'Position'      , [10 830 120 20]   ,  'Callback' , @slider_func_xh); % ,'String',['variable=',num2str(1)]);
slider_handle_yl = uicontrol('Style','slider','Min',0,'Max',10000,'Value',1,'Position'      , [10 770 120 20]   ,  'Callback' , @slider_func_yl); % ,'String',['variable=',num2str(1)]);
slider_handle_yh = uicontrol('Style','slider','Min',0,'Max',10000,'Value',1,'Position'      , [10 750 120 20]   ,  'Callback' , @slider_func_yh); % ,'String',['variable=',num2str(1)]);

uicontrol('Style', 'pushbutton', 'String', 'Choose point','Position'                               , [10 500 120 50]                       ,'Callback' , @but_func_1)                     ; % select point on dispersion curve       
uicontrol('Style', 'pushbutton', 'String', 'Select Modes /no','Position'                           , [10 550 120 50]                       ,'Callback' , @but_func_2)                     ; % select modes on dispersion curve       
uicontrol('Style', 'pushbutton', 'String', 'Select Modes /freq','Position'                         , [10 600 120 50]                       ,'Callback' , @but_func_3)                     ; % select modes on dispersion curve       
uicontrol('Style', 'pushbutton', 'String', 'Show Legend','Position'                                , [10 650 120 50]                       ,'Callback' , @but_func_4)                     ; % select modes on dispersion curve       
uicontrol('Style', 'pushbutton', 'String', 'Reset Limts','Position'                                , [10 720 80 30]                        ,'Callback' , @but_func_5)                     ; % select modes on dispersion curve       
uicontrol('Style', 'checkbox', 'String', 'Displacement vectors on','Position'                      , [20 150 160 20]                       ,'Callback' , @check_func_1)                   ; % turn on/off displacement vectors      
uicontrol('Style', 'popup','String', {'Freq(Hz)','WaveNo.(1/m)','Phase Velocity(m/s)','Group Velocity(m/s)'},   'Position', [10 410 120 50],'Callback' , @select_x_ordinate); % select the x odinate

uicontrol('Style', 'popup','String', {'Phase Velocity(m/s)','Group Velocity(m/s)','Freq(Hz)','WaveNo.(1/m)'},   'Position', [10 370 120 50],'Callback' , @select_y_ordinate); % select the y odinate

uicontrol('Style', 'popup','String', {'Cartesian','Cylindrical'},   'Position'                     , [20 180 100 40]                       ,'Callback' , @co_ord_display)                 ; % switch between cylindrical and cartesian coordinates 
uicontrol('Style', 'popup','String', {'2d mesh','external nodes','3d rendered'},'Position'         , [20 230 100 40]                       ,'Callback' , @mesh_display)                   ; % switch between full mesh and external edge view 
uicontrol('Style', 'popup','String', {'xy','iso','xz'},'Position'                                  , [850 420 100 40]                      ,'Callback' , @animation_view)                 ; % view for animation 
uicontrol('Style', 'checkbox','String','Animate Mode','Position'                                   , [730 440 100 20]                      ,'Callback' , @Animate_button)                 ; % switch on and off the animation of a selected mode
checkbox_handle_mesh =  uicontrol('Style', 'checkbox','String','Show redered Mesh','Position'      , [730 410 130 20]   ,  'Callback' , @show_mesh_ren,'visible','off' ) ; % switch on and off 3d mesh 
clear reshaped_proc_data 


fig_setup(fig_handle,slider_handle,slider_handle_2,checkbox_handle_mesh,slider_handle_xl,slider_handle_xh,slider_handle_yl,slider_handle_yh);                           
%------------------------------------------------------------------------------------------------------
end %function plot_specific_mode_(reshaped_proc_data )
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% callbacks
% ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function DeleteFcn_callback(object_handle,~)
plot_data_structure = get(object_handle,'UserData');
[~]  = stop_current_animation(plot_data_structure);    
end  % function Deletes any animation timer object that may exist at the time of closing the figure

function fig_setup(fig_handle,slider_handle,slider_handle_2,checkbox_handle_mesh,slider_handle_xl,slider_handle_xh,slider_handle_yl,slider_handle_yh)

% this is an 'autocallback'
plot_data_structure                         = get(fig_handle,'UserData') ;
plot_data_structure.fig_handle              = fig_handle                 ;
plot_data_structure.slider_handle           = slider_handle              ;
plot_data_structure.slider_handle_2         = slider_handle_2            ;
plot_data_structure.checkbox_handle_mesh    = checkbox_handle_mesh       ;
plot_data_structure.slider_handle_xl        = slider_handle_xl           ;  
plot_data_structure.slider_handle_xh        = slider_handle_xh           ;  
plot_data_structure.slider_handle_yl        = slider_handle_yl           ;
plot_data_structure.slider_handle_yh        = slider_handle_yh           ;

plot_data_structure.dispersion_axis         = subplot(2,3,1:3)           ;
plot_data_structure.mesh_axis1              = subplot(2,3,4)             ;
set(plot_data_structure.mesh_axis1,'UserData',1)
plot_data_structure.mesh_axis2         = subplot(2,3,5)             ;
set(plot_data_structure.mesh_axis2,'UserData',2)
plot_data_structure.mesh_axis3         = subplot(2,3,6)             ;
set(plot_data_structure.mesh_axis3,'UserData',3)

set(slider_handle_2,'Value',plot_data_structure.mult_factor_speed)  


if isstruct(plot_data_structure.reshaped_proc_data)
    
plot_data_structure                                        =     put_node_positions_in_3space(plot_data_structure)     ;                                                                                                                
plot_data_structure                                        =     get_ordered_external_nodes(plot_data_structure)       ;
plot_data_structure                                        =     plot_dispersion_curves(plot_data_structure)           ;
plot_data_structure                                        =     calculate_max_mult_factor(plot_data_structure)        ;

plot_data_structure                                        =     switch_real_and_complex_ms_z(plot_data_structure)     ;

plot_data_structure                                        =     get_undeformed_3d_mesh_properties(plot_data_structure);
plot_data_structure                                        =     plot_point_on_dispersion_curves(plot_data_structure)  ;
plot_data_structure                                        =     plot_deformed_and_undeformed_mesh(plot_data_structure);
plot_data_structure                                        =     set_scale_sliders(plot_data_structure);

set( plot_data_structure.slider_handle , 'Max' , plot_data_structure.max_mult_factor );

set(plot_data_structure.slider_handle,'Value',plot_data_structure.mult_factor);

axes(plot_data_structure.dispersion_axis)  

plot_data_structure.legend_handle = -1;
end %if isstruct(plot_data_structure.reshaped_proc_data)


set(fig_handle,'UserData',plot_data_structure)                                                                     ;

end  % set the figure up with axis and plot data if it exists

function Open_new_file(object_handle,~)
plot_data_structure                 = get(get(get(object_handle,'Parent'),'Parent'),'UserData')     ;
plot_data_structure.menu_handle     = get(object_handle,'Parent')                                   ;  
plot_data_structure.sub_menu_handle = object_handle                                                 ;
[FileName,PathName]                 = uigetfile( '*dis.mat' , 'Select mat file' )                   ;

if FileName ~= 0
full_file_name                         = [PathName,'\',FileName]                                    ; 
cd(PathName)                                                                                        ;
plot_data_structure.file_name          = full_file_name                                             ;   
load(full_file_name);plot_data_structure.reshaped_proc_data                     =reshaped_proc_data ;
end %if FileName ~= 0


if isstruct(plot_data_structure.reshaped_proc_data)
plot_data_structure                                        = put_node_positions_in_3space(plot_data_structure)      ;
plot_data_structure                                        = get_ordered_external_nodes(plot_data_structure)        ;

plot_data_structure                                        = plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure                                        = calculate_max_mult_factor(plot_data_structure)         ;
plot_data_structure                                        = get_undeformed_3d_mesh_properties(plot_data_structure);

set(plot_data_structure.slider_handle,'Max',plot_data_structure.max_mult_factor )                                                                     ;
set(plot_data_structure.slider_handle,'Value',plot_data_structure.mult_factor)                                                                     ;

end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(get(object_handle,'Parent'),'Parent'),'UserData',plot_data_structure)            ;

end   % function Open_new_file(object_handle,not_used)

function slider_func_mag (hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

[plot_data_structure]  = stop_current_animation(plot_data_structure);    

plot_data_structure.mult_factor  = new_value                           ;
plot_data_structure = reset_mesh_plots(plot_data_structure)            ;

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function slider_func_mag (hObject, ~) magnification of mesh displacements
 
function slider_func_speed (hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
[plot_data_structure]  = stop_current_animation(plot_data_structure);
plot_data_structure.mult_factor_speed  = new_value               ;
plot_data_structure = reset_mesh_plots(plot_data_structure)      ;
set(get(hObject,'Parent'),'UserData',plot_data_structure)        ;

end  % function slider_func_speed (hObject, ~) speed of animation

function but_func_1(hObject, ~)
%disp(['Selecting a point'])
plot_data_structure  =  get(get(hObject,'Parent'),'UserData')    ;

if isstruct(plot_data_structure.reshaped_proc_data)
[plot_data_structure]  = stop_current_animation(plot_data_structure);
%cla(plot_data_structure.mesh_axis2)  
axes(plot_data_structure.dispersion_axis);
[plot_data_structure.selected_x,plot_data_structure.selected_y, plot_data_structure.button_] = myginput(1,'crosshair');
plot_data_structure =  plot_dispersion_curves(plot_data_structure)                                                       ;
plot_data_structure = find_closest_index(plot_data_structure)                                                            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)                                               ;
plot_data_structure = calculate_max_mult_factor(plot_data_structure)                                                     ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                                                            ;
set(get(hObject,'Parent'),'UserData',plot_data_structure)                                                                ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

end % function  choose point on dispersion curves

function but_func_2(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

if isstruct(plot_data_structure.reshaped_proc_data)

[plot_data_structure]  = stop_current_animation(plot_data_structure);
cla(plot_data_structure.mesh_axis2)  

[modes_to_plot,ok] = listdlg('PromptString','Select modes to display:','SelectionMode','multiple','ListString',arrayfun(@num2str,(1:size(plot_data_structure.reshaped_proc_data.freq,2)  ),'unif',0));

if ok ==1
plot_data_structure.modes_to_plot = modes_to_plot;   
plot_data_structure       = plot_dispersion_curves(plot_data_structure);

cla(plot_data_structure.mesh_axis1)
cla(plot_data_structure.mesh_axis3)

if ishandle(plot_data_structure.dis_title)
delete(plot_data_structure.dis_title)
end %if ishandle(plot_data_structure.dis_title)

if ishandle(plot_data_structure.legend_handle)    
delete(plot_data_structure.legend_handle)
axes(plot_data_structure.dispersion_axis)    
plot_data_structure.legend_handle = legend( arrayfun(@num2str,plot_data_structure.modes_to_plot,'unif',0),'location','EastOutside');
set(plot_data_structure.legend_handle,'Position',[0.94 0.93 - 0.83*(length(plot_data_structure.modes_to_plot)/40) 0.04 0.83*(length(plot_data_structure.modes_to_plot)/40)]); 
end %if ishandle(plot_data_structure.legend_handle)    

set(get(hObject,'Parent'),'UserData',plot_data_structure);

end %if ok ==1


end %if isstruct(plot_data_structure.reshaped_proc_data)

end % function choose modes to display

function but_func_3(hObject, ~)

plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

if isstruct(plot_data_structure.reshaped_proc_data)
[plot_data_structure]  = stop_current_animation(plot_data_structure);

axes(plot_data_structure.dispersion_axis);
[chosen_freq,~ ,button_ ] = myginput(1,'crosshair');
freq_  =  plot_data_structure.reshaped_proc_data.freq;
if button_ == 1
freq_lims = get(plot_data_structure.dispersion_axis ,'XLim');

if chosen_freq < freq_lims(1);chosen_freq = freq_lims(1);end
if chosen_freq > freq_lims(2);chosen_freq = freq_lims(2);end
modes_to_plot = zeros(1,size(freq_,2));
for index = 1: size(freq_,2)
if  chosen_freq < max(freq_(:,index)) && chosen_freq > min(freq_(:,index))
modes_to_plot = [modes_to_plot,index];
end %if  chosen_freq < max(freq_(:,index)) && chosen_freq > min(freq_(:,index))
end %for index = 1: size(plot_data_structure.reshaped_proc_data.freq,2)
modes_to_plot = modes_to_plot(modes_to_plot~=0);
plot_data_structure.modes_to_plot  = modes_to_plot;   
plot_data_structure                = plot_dispersion_curves(plot_data_structure);
cla(plot_data_structure.mesh_axis1)
cla(plot_data_structure.mesh_axis3)


if ishandle(plot_data_structure.dis_title)
delete(plot_data_structure.dis_title)
end %if ishandle(plot_data_structure.dis_title)
end %if button_ == 1



if ishandle(plot_data_structure.legend_handle)    
delete(plot_data_structure.legend_handle)
axes(plot_data_structure.dispersion_axis)           
plot_data_structure.legend_handle = legend( arrayfun(@num2str,plot_data_structure.modes_to_plot,'unif',0),'location','EastOutside');
set(plot_data_structure.legend_handle,'Position',[0.94 0.93 - 0.83*(length(plot_data_structure.modes_to_plot)/40) 0.04 0.83*(length(plot_data_structure.modes_to_plot)/40)]); 
end %if ishandle(plot_data_structure.legend_handle)    

set(get(hObject,'Parent'),'UserData',plot_data_structure)                                   ;

end %if isstruct(plot_data_structure.reshaped_proc_data)

end % function choose modes to display by frequency

function but_func_4(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
[plot_data_structure]  = stop_current_animation(plot_data_structure);

if isstruct(plot_data_structure.reshaped_proc_data)
if ishandle(plot_data_structure.legend_handle)    
delete(plot_data_structure.legend_handle)
else
axes(plot_data_structure.dispersion_axis)    
plot_data_structure.legend_handle = legend( arrayfun(@num2str,plot_data_structure.modes_to_plot,'unif',0),'location','EastOutside');
set(plot_data_structure.legend_handle,'Position',[0.94 0.93 - 0.83*(length(plot_data_structure.modes_to_plot)/40) 0.04 0.83*(length(plot_data_structure.modes_to_plot)/40)]); 
end %if ishandle(plot_data_structure.legend_handle)    
end %if isstruct(plot_data_structure.reshaped_proc_data)

plot_data_structure = reset_mesh_plots(plot_data_structure);

set(get(hObject,'Parent'),'UserData',plot_data_structure)                                   ;
end  % show legend

function but_func_5(hObject, ~) % reset limits to default
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
[plot_data_structure]  = stop_current_animation(plot_data_structure);

if isstruct(plot_data_structure.reshaped_proc_data)
plot_data_structure.lim_options     =  plot_data_structure.def_lim_options;
plot_data_structure                 =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure                 = plot_point_on_dispersion_curves(plot_data_structure)    ;
plot_data_structure                 = reset_mesh_plots(plot_data_structure)                 ;

x_lims = plot_data_structure.lim_options{plot_data_structure.x_index};
y_lims = plot_data_structure.lim_options{plot_data_structure.y_index};

x_min_def    = x_lims(1);
x_max_def    = x_lims(2);
y_min_def    = y_lims(1);
y_max_def    = y_lims(2);


set(plot_data_structure.slider_handle_xl,'Value' , x_min_def);         %    set to initial default value
set(plot_data_structure.slider_handle_xh,'Value' , x_max_def);

set(plot_data_structure.slider_handle_yl,'Value' , y_min_def);
set(plot_data_structure.slider_handle_yh,'Value' , y_max_def);


end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure)                                   ;
end

function check_func_1(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.show_displacement  =  get(hObject,'Value');
[plot_data_structure]  = stop_current_animation(plot_data_structure);
plot_data_structure = reset_mesh_plots(plot_data_structure);
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function  show displcement vectors

function Animate_button(hObject,~)
% clear plot_data_structure
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.animate_button_value = get(hObject,'Value');

switch (plot_data_structure.animate_button_value)
    
    case(0) 
 %plot_data_structure.animation_timer_handle; 
[plot_data_structure]  = stop_current_animation(plot_data_structure);

    case(1) % create animation handle (if it doesnt exist) and turn timer on        
[plot_data_structure] = create_new_animation(plot_data_structure);
end %Animate_button

set(plot_data_structure.fig_handle,'UserData',plot_data_structure);

end % start or stop the animation

function show_mesh_ren (hObject,~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.show_mesh = get(hObject,'Value');

[plot_data_structure]  = stop_current_animation(plot_data_structure);

plot_data_structure = reset_mesh_plots(plot_data_structure);

set(plot_data_structure.fig_handle,'UserData',plot_data_structure);
end % start or stop the animation

function animation_timer_Callback(hObj, ~)
animation_data_structure   = get(hObj,'UserData');

no_angle_increments        = animation_data_structure.mult_factor_speed;   
angle_increment            = -2*pi/no_angle_increments;

starting_angle             = animation_data_structure.current_animation_angle;   % rename this

if starting_angle          < -2*pi; starting_angle = starting_angle+2*pi ; end ;   % not strictly necessary      
%disp(num2str( 180*starting_angle/(pi)))
mesh_view                  = animation_data_structure.animation_view;
ordered_node_lists         = animation_data_structure.ordered_node_lists; 
element_nodes              = animation_data_structure.element_nodes;
mode_shape_display_option  = animation_data_structure.mode_shape_display_option;
mesh_axis                  = animation_data_structure.mesh_axis;
undeformed_node_positions  = animation_data_structure.undeformed_node_positions;
mult_factor                = animation_data_structure.mult_factor;
ms_x                       = animation_data_structure.ms_x;
ms_y                       = animation_data_structure.ms_y;
ms_z                       = animation_data_structure.ms_z;
cartesian_or_cylindrical   = animation_data_structure.cartesian_or_cylindrical;
undeformed_3d_mesh_properties =  animation_data_structure.undeformed_3d_mesh_properties;
show_mesh                     =  animation_data_structure.show_mesh;
axes(mesh_axis)
%disp(num2str(starting_angle))

ms_x = abs(ms_x).*exp(1i*(angle(ms_x) + starting_angle));   
ms_y = abs(ms_y).*exp(1i*(angle(ms_y) + starting_angle));   
ms_z = abs(ms_z).*exp(1i*(angle(ms_z) + starting_angle));   
        
switch (mode_shape_display_option)

    
    case{1 2}    
[deformed_node_positions]  = get_deformed_node_positions(ms_x, ms_y, ms_z, mult_factor, cartesian_or_cylindrical , undeformed_node_positions);
if animation_data_structure.reset_plot
axes(mesh_axis)
cla
axis equal
set(mesh_axis, 'visible', 'on')
hold on 
animation_data_structure.un_plot_line_handle   = plot_a_mesh (undeformed_node_positions , ordered_node_lists, element_nodes, mesh_axis, mesh_view, 0 , mode_shape_display_option );
[animation_data_structure.xlim_ , animation_data_structure.ylim_ , animation_data_structure.zlim_] =  get_animation_limits(undeformed_node_positions, mult_factor , ms_x , ms_y , ms_z);

set(mesh_axis,'xlim', animation_data_structure.xlim_);
set(mesh_axis,'ylim', animation_data_structure.ylim_);
set(mesh_axis,'zlim', animation_data_structure.zlim_);

animation_data_structure.reset_plot = 0;
end %if animation_data_structure.reset_plot

set(mesh_axis,'xlim', animation_data_structure.xlim_ );
set(mesh_axis,'ylim', animation_data_structure.ylim_ );
set(mesh_axis,'zlim', animation_data_structure.zlim_ );

if iscell(animation_data_structure.def_plot_line_handle)
for index = 1:size(animation_data_structure.def_plot_line_handle,2)
delete(animation_data_structure.def_plot_line_handle{index})
end %for index = 1:size(animation_data_structure.def_plot_line_handle,2)
end %if iscell(animation_data_structure.def_plot_line_handle)
animation_data_structure.def_plot_line_handle  =  plot_a_mesh (deformed_node_positions,ordered_node_lists, element_nodes, mesh_axis, mesh_view, 1 , mode_shape_display_option);

    case(3)
axes(mesh_axis)       
view([ -37.5,-30])
hold off
axis normal
zlim([0 1.2])
set(mesh_axis, 'visible', 'off')
cla

[deformed_3d_mesh]               =     get_deformed_3d_mesh(ms_x , ms_y , ms_z , undeformed_3d_mesh_properties , ordered_node_lists , mult_factor, cartesian_or_cylindrical );

switch(animation_data_structure.show_mesh)
    case(0)    
patch(deformed_3d_mesh,'EdgeColor','none','FaceColor','g');
    case (1)
patch(deformed_3d_mesh,'EdgeColor','k','FaceColor','g');
end

light('Position',[1 3 2]); light('Position',[-3 -1 3]);material shiny; alpha('color'); alpha('opaque'); alphamap('rampdown'); alphamap('vup'); camlight(45,45); lighting phong; set(gcf, 'Renderer', 'OpenGL')
%light('position',[0,0,-3])

end

animation_data_structure.current_animation_angle = starting_angle + angle_increment;
%disp(num2str(180*animation_data_structure.current_animation_angle/pi))

set(hObj,'UserData',animation_data_structure);


end % function animation_timer_Callback (hObj, ~)

function co_ord_display(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

[plot_data_structure]  = stop_current_animation(plot_data_structure);
plot_data_structure.cartesian_or_cylindrical  =  get(hObject,'Value');
plot_data_structure = reset_mesh_plots(plot_data_structure);

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % choose cartesian or cylindrical co ords for displacement calcs

function select_x_ordinate(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
plot_data_structure.x_index   = get(hObject,'Value');

if isstruct(plot_data_structure.reshaped_proc_data)
plot_data_structure       = set_scale_sliders(plot_data_structure)            ;    

[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function select_x_ordinate(hObject, ~)

function select_y_ordinate(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
order_ = [3,4,1,2];
temp_index  = get(hObject,'Value');
plot_data_structure.y_index =  order_(temp_index);

if isstruct(plot_data_structure.reshaped_proc_data)
    
plot_data_structure       = set_scale_sliders(plot_data_structure)           ;
[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;

end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function select_y_ordinate(hObject, ~)

function animation_view(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

[plot_data_structure]  = stop_current_animation(plot_data_structure);

choice_  =  get(hObject,'Value');
switch(choice_)
    case(1)    
plot_data_structure.mesh_view2 = [180 -90];        
    case(2)    
plot_data_structure.mesh_view2 = [ -37.5,-30];               

    case(3)    
plot_data_structure.mesh_view2 = [90 0];                               
end %switch(choice)

plot_data_structure = reset_mesh_plots(plot_data_structure);

if isstruct(plot_data_structure.reshaped_proc_data)
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end 


end % choose the view for the animation

function mesh_display(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

[plot_data_structure]  = stop_current_animation(plot_data_structure);
plot_data_structure.mode_shape_display_option  =  get(hObject,'Value');

plot_data_structure = reset_mesh_plots(plot_data_structure);

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % choose full mesh or outside edge to display

function slider_func_xl(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%disp(num2str(new_value))

if isstruct(plot_data_structure.reshaped_proc_data)
x_lims = plot_data_structure.lim_options{plot_data_structure.x_index}  ;

if new_value < x_lims(2)
x_lims(1) =  new_value                                                 ;
plot_data_structure.lim_options{plot_data_structure.x_index} = x_lims  ;
end %if new_value < x_lims(2)

[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function slider_func_xl (hObject, ~)  lower x limit

function slider_func_xh(hObject, ~)

new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%disp(num2str(new_value))

if isstruct(plot_data_structure.reshaped_proc_data)
x_lims = plot_data_structure.lim_options{plot_data_structure.x_index}  ;

if new_value > x_lims(1)
x_lims(2) =  new_value                                                 ;
plot_data_structure.lim_options{plot_data_structure.x_index} = x_lims  ;
end %if new_value < x_lims(2)

[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function slider_func_xh (hObject, ~) upper x limit

function slider_func_yl(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%disp(num2str(new_value))

if isstruct(plot_data_structure.reshaped_proc_data)
y_lims = plot_data_structure.lim_options{plot_data_structure.y_index}  ;

if new_value < y_lims(2)
y_lims(1) =  new_value                                                 ;
plot_data_structure.lim_options{plot_data_structure.y_index} = y_lims  ;
end %if new_value < y_lims(2)

[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function slider_func_yl (hObject, ~) lower y limit

function slider_func_yh(hObject, ~)
new_value =  get(hObject,'Value');
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%disp(num2str(new_value))

if isstruct(plot_data_structure.reshaped_proc_data)
y_lims = plot_data_structure.lim_options{plot_data_structure.y_index}  ;

if new_value > y_lims(1)
y_lims(2) =  new_value                                                 ;
plot_data_structure.lim_options{plot_data_structure.y_index} = y_lims  ;
end %if new_value < y_lims(2)

[plot_data_structure]  = stop_current_animation(plot_data_structure)          ;
plot_data_structure =  plot_dispersion_curves(plot_data_structure)            ;
plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure)    ;
[plot_data_structure] = reset_mesh_plots(plot_data_structure)                 ;
end %if isstruct(plot_data_structure.reshaped_proc_data)

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function slider_func_yh (hObject, ~) upper y limit
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
% other functions
%------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
function plot_data_structure       = set_scale_sliders(plot_data_structure)
switch( plot_data_structure.x_index) 
    case(1)    
x_vals     = plot_data_structure.reshaped_proc_data.freq(:,:);
    case(2)    
x_vals     = plot_data_structure.reshaped_proc_data.waveno(:,:);        
    case(3)    
x_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,:);        
    case(4)   
x_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,:);
end %switch( plot_data_structure.x_label_index) 

switch( plot_data_structure.y_index) 
    case(1)    
y_vals     = plot_data_structure.reshaped_proc_data.freq(:,:);
    case(2)    
y_vals     = plot_data_structure.reshaped_proc_data.waveno(:,:);        
    case(3)    
y_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,:);        
    case(4)   
y_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,:);
end %switch( plot_data_structure.x_label_index) 

x_lims = plot_data_structure.lim_options{plot_data_structure.x_index}  ;

y_lims = plot_data_structure.lim_options{plot_data_structure.y_index}  ;


x_min        =  100*floor(min(min(x_vals))/100) ;
if x_min > 0
x_min = 0;
end %if x_min > 0

x_min_def    = x_lims(1);
x_max        =  100*ceil(max(max(x_vals))/100)  ;
x_max_def    = x_lims(2);

y_min        =  100*floor(min(min(y_vals))/100) ;
if y_min > 0
y_min = 0;
end %if y_min > 0

y_min_def    = y_lims(1);
y_max        =  100*ceil(max(max(y_vals))/100)  ;
y_max_def    = y_lims(2);

set(plot_data_structure.slider_handle_xl,'Max'   , x_max);
set(plot_data_structure.slider_handle_xl,'Min'   , x_min);

set(plot_data_structure.slider_handle_xl,'Value' , x_min_def); % set to initial default value

set(plot_data_structure.slider_handle_xh,'Max'   , x_max);
set(plot_data_structure.slider_handle_xh,'Min'   , x_min);
set(plot_data_structure.slider_handle_xh,'Value' , x_max_def);

set(plot_data_structure.slider_handle_yl,'Max'   , y_max);
set(plot_data_structure.slider_handle_yl,'Min'   , y_min);
set(plot_data_structure.slider_handle_yl,'Value' , y_min_def);
set(plot_data_structure.slider_handle_yh,'Max'   , y_max);
set(plot_data_structure.slider_handle_yh,'Min'   , y_min);
set(plot_data_structure.slider_handle_yh,'Value' , y_max_def);
end

function plot_data_structure       = reset_mesh_plots(plot_data_structure)

if isstruct(plot_data_structure.reshaped_proc_data)
plot_data_structure              = plot_meshes(plot_data_structure)                                                ;

if (plot_data_structure.animate_button_value)
plot_data_structure = create_new_animation(plot_data_structure);
end %if make_new_animation == 1;

end %if isstruct(plot_data_structure.reshaped_proc_data)

end %  re initialises all the mesh plots-  (used after UI control interaction)

function plot_data_structure       = create_new_animation(plot_data_structure)

if isstruct(plot_data_structure.reshaped_proc_data) 
mult_factor_speed                             = plot_data_structure.mult_factor_speed;
mesh_axis2                                    = plot_data_structure.mesh_axis2;
mesh_axis1                                    = plot_data_structure.mesh_axis1;
undeformed_node_positions                     = plot_data_structure.undeformed_node_positions;
current_animation_angle                       = plot_data_structure.current_animation_angle;
mult_factor                                   = plot_data_structure.mult_factor;
ms_x                                          = plot_data_structure.reshaped_proc_data.ms_x(:,plot_data_structure.point_index,plot_data_structure.mode_index);
ms_y                                          = plot_data_structure.reshaped_proc_data.ms_y(:,plot_data_structure.point_index,plot_data_structure.mode_index);
ms_z                                          = plot_data_structure.reshaped_proc_data.ms_z(:,plot_data_structure.point_index,plot_data_structure.mode_index);
cartesian_or_cylindrical                      = plot_data_structure.cartesian_or_cylindrical;
mode_shape_display_option                     = plot_data_structure.mode_shape_display_option;  % wont plot meshes at present
ordered_node_lists                            = plot_data_structure.ordered_node_lists; 
element_nodes                                 = plot_data_structure.reshaped_proc_data.mesh.el.nds;
animation_view                                = plot_data_structure.mesh_view2;
undeformed_3d_mesh_properties                 = plot_data_structure.undeformed_3d_mesh_properties;
show_mesh                                     = plot_data_structure.show_mesh ;

if mode_shape_display_option == 3 
set(plot_data_structure.checkbox_handle_mesh,'visible', 'on')     
end    

animation_data_structure = struct('mesh_axis',mesh_axis2,'static_axis',mesh_axis1,'undeformed_node_positions', undeformed_node_positions,'current_animation_angle',current_animation_angle,'mult_factor',mult_factor,...
'ms_x', ms_x,'ms_y',ms_y,'ms_z',ms_z,'cartesian_or_cylindrical',cartesian_or_cylindrical,'mode_shape_display_option',mode_shape_display_option,...
'ordered_node_lists',{ordered_node_lists},'element_nodes',element_nodes,'def_plot_line_handle',-1,'un_plot_line_handle',-1,'reset_plot',1,'animation_view',animation_view,'mult_factor_speed',mult_factor_speed,...
'undeformed_3d_mesh_properties',undeformed_3d_mesh_properties,'show_mesh',show_mesh);

plot_data_structure.animation_timer_handle = timer('ExecutionMode', 'FixedRate','Period',0.15,'UserData',animation_data_structure,'TimerFcn', {@animation_timer_Callback});        

start(plot_data_structure.animation_timer_handle)
end %if isstruct(plot_data_structure.reshaped_proc_data)            

end % create a new anmimation (timer) object

function plot_data_structure       = stop_current_animation(plot_data_structure)

set(plot_data_structure.checkbox_handle_mesh,'visible', 'off')     

if isobject(plot_data_structure.animation_timer_handle)
animation_data_structure   = get(plot_data_structure.animation_timer_handle,'UserData');   
stop(plot_data_structure.animation_timer_handle)
plot_data_structure.current_animation_angle  = animation_data_structure.current_animation_angle;
delete(timerfind)
plot_data_structure.animation_timer_handle = -1;
end %if isobject(plot_data_structure.animation_timer_handle)

end % create a new anmimation (timer) object

function [xlim_,ylim_,zlim_]       = get_animation_limits(undeformed_node_positions, mult_factor,ms_x,ms_y,ms_z)

mesh_max_x =  max(undeformed_node_positions(:,1));
mesh_min_x =  min(undeformed_node_positions(:,1));
mesh_max_y =  max(undeformed_node_positions(:,2));
mesh_min_y =  min(undeformed_node_positions(:,2));
mesh_max_z =  max(undeformed_node_positions(:,3));
mesh_min_z =  min(undeformed_node_positions(:,3));

def_max_x =  max(abs(ms_x));
def_max_y =  max(abs(ms_y));
def_max_z =  max(abs(ms_z));
min_val = min( [mesh_min_x - def_max_x*mult_factor , mesh_min_y - def_max_y*mult_factor, mesh_min_z - def_max_z*mult_factor]);
max_val = max([mesh_max_x + def_max_x*mult_factor  , mesh_max_y + def_max_y*mult_factor, mesh_max_z + def_max_z*mult_factor]);
xlim_ = [min_val max_val];
ylim_ = [min_val max_val];
zlim_ = [min_val max_val];

end % for setting the animation plot limits (so it doesnt rescale during animation)

function plot_data_structure       = plot_meshes(plot_data_structure)
% make this plot everything except point
if plot_data_structure.show_displacement ==1
%clear and plot with displacements
plot_data_structure = plot_deformed_and_undeformed_mesh(plot_data_structure);
plot_data_structure = plot_displacement_vector(plot_data_structure);
else    
plot_data_structure = plot_deformed_and_undeformed_mesh(plot_data_structure);
end %if plot_data_structure.show_displacement ==1
end % 

function plot_data_structure       = put_node_positions_in_3space(plot_data_structure)
node_positions_old    =   plot_data_structure.reshaped_proc_data.mesh.nd.pos;
%  if only x and y then give a z position and set it to zero
if size(node_positions_old,2) == 2   % should be either 2 or 3
node_positions =  [node_positions_old, zeros(size(node_positions_old,1),1)];  
elseif size(node_positions_old,2) ==3
% do nothing as already in correct format    
node_positions =  node_positions_old;
else
node_positions = 'void';
disp('error node positions should be in either 2 or 3 d') 
end %if size(node_positions_old,2) ==2   % shoul be either 2 or 3    
plot_data_structure.undeformed_node_positions = node_positions;
end %function node_positions  =   put_node_positions_in_3space(mesh_.nd.pos);
         
function plot_line_handle          = plot_a_mesh (node_positions , ordered_node_lists, element_nodes, axis_handle, mesh_view, undef_def , mode_shape_display_option)
% node_positions  - this will be deformed or undeformed node positions
% mode_shape_display_option = plot_data_structure.mode_shape_display_option;

fig_handle = get(axis_handle,'parent');

if (undef_def)
color_ ='r';
else
color_ ='k';
end %if (undef_def)

%fig_handle      = plot_data_structure.fig_handle     ;

axes(axis_handle)
view(mesh_view)

set(gca, 'visible', 'off')

if get(axis_handle,'UserData')==1
axis equal
end % if get(axis_handle,'UserData',1)==1
hold on

switch(mode_shape_display_option)
    case(1) % full mesh        
fv.Faces       = element_nodes;
fv.Vertices    = node_positions;  
plot_line_handle{1} = patch(fv, 'EdgeColor',color_,'FaceColor','none');
%patch(fv, 'EdgeColor',color_,'FaceColor','none');
    case(2) %internal and external nodes 
% disp('skeleton here')        
for index = 1:size(ordered_node_lists,2)
plot_line_handle{index} =  plot3([node_positions(ordered_node_lists{index},1) ; node_positions(ordered_node_lists{index}(1),1)] ,[node_positions(ordered_node_lists{index},2); node_positions(ordered_node_lists{index}(1),2)],[node_positions(ordered_node_lists{index},3); node_positions(ordered_node_lists{index}(1),3)],color_);
end % for index = 1:size(ordered_node_lists,2)

    case(3) % 3d mesh
disp('In process of writing')
% this is handled elsewhere

end % outer switch
end % function

function plot_data_structure       = plot_deformed_and_undeformed_mesh(plot_data_structure)

cla(plot_data_structure.mesh_axis1)
cla(plot_data_structure.mesh_axis3)

axes(plot_data_structure.mesh_axis1)
hold on
axes(plot_data_structure.mesh_axis3)
hold on

% if choice is 1 or 2 plot def and undef - else just plot def
% ------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------
% plot_data_structure 

switch (plot_data_structure.mode_shape_display_option)
    
    case{1 2}
plot_data_structure = plot3meshes(plot_data_structure, 1);   %  1 = deformed
plot_data_structure = plot3meshes(plot_data_structure, 0);   %  0 = undeformed

    case(3)
% in this case just plot deformed  in the two axis - calculating the        

point_index  = plot_data_structure.point_index  ;
mode_index   = plot_data_structure.mode_index   ;

ms_x =  plot_data_structure.reshaped_proc_data.ms_x(:,point_index,mode_index);
ms_y =  plot_data_structure.reshaped_proc_data.ms_y(:,point_index,mode_index);
ms_z =  plot_data_structure.reshaped_proc_data.ms_z(:,point_index,mode_index);

[deformed_3d_mesh]               =     get_deformed_3d_mesh(ms_x , ms_y , ms_z , plot_data_structure.undeformed_3d_mesh_properties , plot_data_structure.ordered_node_lists , plot_data_structure.mult_factor, plot_data_structure.cartesian_or_cylindrical    );

axes(plot_data_structure.mesh_axis1)
view(plot_data_structure.mesh_view1)
patch(deformed_3d_mesh,'EdgeColor','none','FaceColor','g')
light('Position',[1 3 2]); light('Position',[-3 -1 3]); material shiny; alpha('color'); alpha('opaque'); alphamap('rampdown'); alphamap('vup'); camlight(45,45); lighting phong; set(gcf, 'Renderer', 'OpenGL')

axes(plot_data_structure.mesh_axis3)
view(plot_data_structure.mesh_view3)
patch(deformed_3d_mesh,'EdgeColor','none','FaceColor','g')
light('Position',[1 3 2]); light('Position',[-3 -1 3]); material shiny; alpha('color'); alpha('opaque'); alphamap('rampdown'); alphamap('vup'); camlight(45,45); lighting phong; set(gcf, 'Renderer', 'OpenGL')
end     % switch (plot_data_structure.mode_shape_display_option)

axes(plot_data_structure.mesh_axis1)
axes(plot_data_structure.mesh_axis3)

end % function plot_data_structure       = plot_deformed_and_undeformed_mesh(plot_data_structure)

function plot_data_structure       = plot3meshes(plot_data_structure, undeformed_or_deformed)      %   these are the static plots (2 at present)

undeformed_node_positions                      =   plot_data_structure.undeformed_node_positions;
ordered_node_lists                             =   plot_data_structure.ordered_node_lists;
element_nodes                                  =   plot_data_structure.reshaped_proc_data.mesh.el.nds;
mode_shape_display_option                      =   plot_data_structure.mode_shape_display_option;

switch (undeformed_or_deformed)
    case(0)   % undeformed case
        
%size(undeformed_node_positions)        
plot_a_mesh (undeformed_node_positions,ordered_node_lists, element_nodes,  plot_data_structure.mesh_axis1,  plot_data_structure.mesh_view1, undeformed_or_deformed , mode_shape_display_option);
plot_a_mesh (undeformed_node_positions,ordered_node_lists, element_nodes,  plot_data_structure.mesh_axis3,  plot_data_structure.mesh_view3, undeformed_or_deformed , mode_shape_display_option);

    case(1)   % deformed case
%plot_data_structure = get_deformed_node_positions(plot_data_structure);

point_index  = plot_data_structure.point_index  ;
mode_index   = plot_data_structure.mode_index   ;


[plot_data_structure.deformed_node_positions] = get_deformed_node_positions(plot_data_structure.reshaped_proc_data.ms_x(:,point_index,mode_index),...
plot_data_structure.reshaped_proc_data.ms_y(:,point_index,mode_index), plot_data_structure.reshaped_proc_data.ms_z(:,point_index,mode_index),...
plot_data_structure.mult_factor,plot_data_structure.cartesian_or_cylindrical,undeformed_node_positions);

plot_a_mesh (plot_data_structure.deformed_node_positions,ordered_node_lists, element_nodes, plot_data_structure.mesh_axis1,  plot_data_structure.mesh_view1, undeformed_or_deformed , mode_shape_display_option);
plot_a_mesh (plot_data_structure.deformed_node_positions,ordered_node_lists, element_nodes, plot_data_structure.mesh_axis3,  plot_data_structure.mesh_view3, undeformed_or_deformed , mode_shape_display_option);


    otherwise 
disp('invalid type of mesh plot')        
end %switch (undeformed_or_deformed)
end% function-  down to two at present

function deformed_node_positions   = get_deformed_node_positions(ms_x, ms_y, ms_z, mult_factor, cartesian_or_cylindrical , undeformed_node_positions)

% deformed_node_positions_abs is used for keeping a consistant scale on the animation axis  (i.e. for setting the XLim and Ylim values)
% This function doubles up for two different objects (figure and Timer) and
% so the entire structure cannot be passed in either case

switch(cartesian_or_cylindrical)
    case(1)   % cartesian
del_x  = real(ms_x)*mult_factor;del_y  = real(ms_y)*mult_factor;del_z  = real(ms_z)*mult_factor;
deformed_node_positions   =[undeformed_node_positions(:,1) + del_x , undeformed_node_positions(:,2) + del_y, undeformed_node_positions(:,3) + del_z];


    case(2)   % cylindrical
undeformed_node_positions_complex = undeformed_node_positions(:,1)  +  1i*undeformed_node_positions(:,2);      
deformed_node_positions_complex   = undeformed_node_positions(:,1)  + real(ms_x)  +  1i*(undeformed_node_positions(:,2)+real(ms_y));       

%------------------------------------------------------------------------------------
% the following loop is to deal with the flip in angle at -1+0i (-pi/pi)
for index = 1 : length(deformed_node_positions_complex)
if abs(angle(undeformed_node_positions_complex(index))) < 0.9*pi 
d_theta(index,:) =   angle(deformed_node_positions_complex(index)) -  angle(undeformed_node_positions_complex(index));
else
if sign(angle(deformed_node_positions_complex(index))) == sign(angle(undeformed_node_positions_complex(index)))    
d_theta(index,:) =   angle(deformed_node_positions_complex(index)) -  angle(undeformed_node_positions_complex(index));    
else
if sign(angle(undeformed_node_positions_complex(index))) == 1    
def_ang_temp     =   2*pi + angle(deformed_node_positions_complex(index));
d_theta(index,:) =   def_ang_temp -  angle(undeformed_node_positions_complex(index));    
else
undef_ang_temp   =   2*pi+angle(undeformed_node_positions_complex(index));    
d_theta(index,:) =   angle(deformed_node_positions_complex(index)) -  undef_ang_temp;    

end %if sign(angle(undeformed_node_positions_complex(index))) == 1    
end %if sign(angle(deformed_node_positions_complex)) == sign(angle(undeformed_node_positions_complex))    
end %if abs(angle(undeformed_node_positions_complex)) < 0.8*pi
end % for index = 1 : length(deformed_node_positions_complex)
%------------------------------------------------------------------------------------
d_r = abs(deformed_node_positions_complex) -  abs(undeformed_node_positions_complex);

magnified_deformed_node_positions_complex = (abs(undeformed_node_positions_complex)+d_r*mult_factor).*exp(1i*(angle(undeformed_node_positions_complex) + d_theta*mult_factor));

% check the COA is 0        
del_z  = real(ms_z)*mult_factor  ;        % cylindrical co-ords so no change

deformed_node_positions   =   [real(magnified_deformed_node_positions_complex) ,imag(magnified_deformed_node_positions_complex) , undeformed_node_positions(:,3) + del_z];
end %switch(cartesian_or_radial)
end % function%

function plot_data_structure       = plot_dispersion_curves(plot_data_structure)

% 'xlim_options',{[0  0.1E5],[0 0.1E5]}, 'ylim_options',{[0 10000],[0 10000]},[0,10000],'xlabels_options',{'Freq(Hz)','WaveNo.(1/m)'},...
% 'ylabel_options',{'Phase Velocity(m/s)','Group Velocity(m/s)'},'x_label_index',1,'x_label_index',1,

dispersion_axis = plot_data_structure.dispersion_axis;

switch( plot_data_structure.x_index) 
    case(1)    
x_vals     = plot_data_structure.reshaped_proc_data.freq(:,plot_data_structure.modes_to_plot)   ;
    case(2)    
x_vals     = plot_data_structure.reshaped_proc_data.waveno(:,plot_data_structure.modes_to_plot)   ;        
    case(3)    
x_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,plot_data_structure.modes_to_plot)   ;        
    case(4)   
x_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,plot_data_structure.modes_to_plot);
end %switch( plot_data_structure.x_label_index) 

switch( plot_data_structure.y_index) 
    case(1)    
y_vals     = plot_data_structure.reshaped_proc_data.freq(:,plot_data_structure.modes_to_plot)   ;
    case(2)    
y_vals     = plot_data_structure.reshaped_proc_data.waveno(:,plot_data_structure.modes_to_plot)   ;        
    case(3)    
y_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,plot_data_structure.modes_to_plot)   ;        
    case(4)   
y_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,plot_data_structure.modes_to_plot);
end %switch( plot_data_structure.x_label_index) 

xlim_    = plot_data_structure.lim_options{plot_data_structure.x_index};
ylim_    = plot_data_structure.lim_options{plot_data_structure.y_index};

xlabel_  = plot_data_structure.label_options{plot_data_structure.x_index};
ylabel_  = plot_data_structure.label_options{plot_data_structure.y_index};

cla(dispersion_axis)
axes(dispersion_axis)

plot(x_vals,y_vals,'x-')

hold on
xlim(xlim_);
ylim(ylim_);
xlabel(xlabel_)
ylabel(ylabel_)

end

function [plot_data_structure]     = find_closest_index(plot_data_structure)

selected_x      =   plot_data_structure.selected_x;
selected_y       =   plot_data_structure.selected_y;

modes_to_plot      = plot_data_structure.modes_to_plot;

switch( plot_data_structure.x_index) 
    case(1)    
x_vals     = plot_data_structure.reshaped_proc_data.freq(:,modes_to_plot)   ;
    case(2)    
x_vals     = plot_data_structure.reshaped_proc_data.waveno(:,modes_to_plot)   ;        
    case(3)    
x_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,modes_to_plot)   ;        
    case(4)   
x_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,modes_to_plot)   ;
end %switch( plot_data_structure.x_label_index) 

switch( plot_data_structure.y_index) 
    case(1)    
y_vals     = plot_data_structure.reshaped_proc_data.freq(:,modes_to_plot)   ;
    case(2)    
y_vals     = plot_data_structure.reshaped_proc_data.waveno(:,modes_to_plot)   ;        
    case(3)    
y_vals     = plot_data_structure.reshaped_proc_data.ph_vel(:,modes_to_plot)   ;        
    case(4)   
y_vals     = plot_data_structure.reshaped_proc_data.group_velocity(:,modes_to_plot) ;
end %switch( plot_data_structure.x_label_index) 

%freq__    = plot_data_structure.reshaped_proc_data.freq(:,modes_to_plot);
%ph_vel__  =  plot_data_structure.reshaped_proc_data.ph_vel(:,modes_to_plot);
%xlim_ = plot_data_structure.xlim_;
%ylim_ = plot_data_structure.ylim_;

xlim_    = plot_data_structure.lim_options{plot_data_structure.x_index};
ylim_    = plot_data_structure.lim_options{plot_data_structure.y_index};
min_index_v    = zeros(1,size(x_vals,2));
norm_dist_vals = zeros(1,size(x_vals,2));

for index = 1: size(x_vals,2)
x_norm_dis =  (x_vals(:,index)-selected_x) /(xlim_(2)*0.25) ;  % 0.25 is the aspect ratio of the dispersion figure
y_norm_dis  =  (y_vals(:,index)-selected_y) /(ylim_(2))      ;

temp_norm_dist_from_mouse_pos =   sqrt(x_norm_dis.^2 + y_norm_dis.^2);

[~,min_index] = min(abs(temp_norm_dist_from_mouse_pos));

min_index_v(index)        =     min_index;
norm_dist_vals(index)     =     temp_norm_dist_from_mouse_pos(min_index);
end % for index = 1: length(in_mode_index_list)

[~,min_dist_index] = min(abs(norm_dist_vals)) ;
plot_data_structure.mode_index   =  modes_to_plot(min_dist_index)          ;
plot_data_structure.point_index  =  min_index_v(min_dist_index)            ;
end % finds the closest point on the dispersion curve to that selected by the ginput command

function plot_data_structure       = plot_point_on_dispersion_curves(plot_data_structure)

point_index     = plot_data_structure.point_index                          ;
mode_index      = plot_data_structure.mode_index                           ;
freq            = plot_data_structure.reshaped_proc_data.freq              ;
ph_vel          = plot_data_structure.reshaped_proc_data.ph_vel            ;
gr_vel          = plot_data_structure.reshaped_proc_data.group_velocity    ;
waveno          = plot_data_structure.reshaped_proc_data.waveno            ;  

switch( plot_data_structure.x_index) 
    case(1)    
x_val     = freq(point_index,mode_index);
    case(2)    
x_val     = waveno(point_index,mode_index);
    case(3)    
x_val     = ph_vel(point_index,mode_index);
    case(4)   
x_val     = gr_vel(point_index,mode_index);
end %switch( plot_data_structure.x_label_index) 

switch( plot_data_structure.y_index) 
    case(1)    
y_val     = freq(point_index,mode_index);
    case(2)    
y_val     = waveno(point_index,mode_index);
    case(3)    
y_val     = ph_vel(point_index,mode_index);
    case(4)   
y_val     = gr_vel(point_index,mode_index);
end %switch( plot_data_structure.x_label_index) 
axes(plot_data_structure.dispersion_axis)
plot(x_val , y_val , 'o' ,'LineWidth',2,'MarkerEdgeColor','k','MarkerFaceColor','r','MarkerSize',10);

plot_data_structure.dis_title = title(['Current mode selected: Md ',num2str(mode_index) ,', Pt ',num2str(point_index),'. Mag = ',num2str(round(plot_data_structure.mult_factor/1E4)*10),'kX, Freq = ',...
num2str(  round(10*freq(point_index,mode_index)/1000)/10  ),' kHz, Vph = ', num2str(round(10*ph_vel(point_index,mode_index)/1000)/10) ,' m/ms, Vgr = ', num2str(round(10*gr_vel(point_index,mode_index)/1000)/10) ,...
' m/ms, K = ', num2str(waveno(point_index,mode_index)),'1/m'],'FontSize',18,'color','r'); 

end % plot_data_structure = plot_point_on_dispersion_curves(plot_data_structure);

function plot_data_structure       = plot_displacement_vector(plot_data_structure)
% plot all for now
undeformed_node_positions = plot_data_structure.undeformed_node_positions;
deformed_node_positions   = plot_data_structure.deformed_node_positions;
mesh_axis = plot_data_structure.mesh_axis1 ;
axes(mesh_axis)
for index  = 1:size(undeformed_node_positions,1) 
plot3([undeformed_node_positions(index,1), deformed_node_positions(index,1)],[undeformed_node_positions(index,2), deformed_node_positions(index,2)],[undeformed_node_positions(index,3), deformed_node_positions(index,3)],'k')
end % for index_2  = 1:length (nodes_to_plot) 
end %function plot_data_structure = plot_deformation_vector(plot_data_structure);

function plot_data_structure       = calculate_max_mult_factor(plot_data_structure)
undeformed_node_positions  = plot_data_structure.undeformed_node_positions;
disp(num2str(plot_data_structure.mode_index))
ms_x                       =  plot_data_structure.reshaped_proc_data.ms_x(:,plot_data_structure.point_index,plot_data_structure.mode_index);
ms_y                       =  plot_data_structure.reshaped_proc_data.ms_y(:,plot_data_structure.point_index,plot_data_structure.mode_index);
width_of_mesh              =  max(undeformed_node_positions(:,1)) -min(undeformed_node_positions(:,1));
height_of_mesh             =  max(undeformed_node_positions(:,2)) -min(undeformed_node_positions(:,2));
mesh_dim                   =  max([width_of_mesh,height_of_mesh])             ;
max_x_disp                 =  max(abs( ms_x))                                 ;
max_y_disp                 =  max(abs( ms_y))                                 ;
disp_dim                   =  max([max_x_disp,max_y_disp])                    ; 
ratio_                     =  get(plot_data_structure.slider_handle,'Value')/get(plot_data_structure.slider_handle,'Max');

plot_data_structure.max_mult_factor =  0.25*mesh_dim/disp_dim  ;
plot_data_structure.mult_factor     =  ratio_ * plot_data_structure.max_mult_factor;  
set(plot_data_structure.slider_handle,'Max',plot_data_structure.max_mult_factor )           ;
set(plot_data_structure.slider_handle,'Value',plot_data_structure.mult_factor)              ;

end  % calculate the maximum magnification factor based on the maxium node displacements

function plot_data_structure       = switch_real_and_complex_ms_z(plot_data_structure)

% if its a quad dont flip (fenel)  but for a triangle do flip(safe)

if size(plot_data_structure.reshaped_proc_data.mesh.el.nds,2)==3
    
 ms_z  = plot_data_structure.reshaped_proc_data.ms_z ;
 ms_z =  imag (ms_z)+ 1i*real(ms_z);
 plot_data_structure.reshaped_proc_data.ms_z = ms_z;
 
end %if size(plot_data_structure.reshaped_proc_data.mesh.el.nds,2)==3
 
 end %switch_real_and_complex_ms_z
  
function [gr_vel_all]              = calc_group_vel(freq_all,wn_all)
gap = 0.0000008             ; % these values seem to work best
points_for_spline_fit = -1   ; % this is for selecting the region of the piecwise spline fit , if -1 then whole region is used
gr_vel_all = zeros(size(freq_all));
for mode_index = 1 : size(freq_all,2) % for all modes
freq_ = freq_all(:,mode_index); 
wn_   = wn_all  (:,mode_index);
s_(1) = 0;
for index = 1: size(freq_,1)-1
s_(index + 1) = s_(index) + sqrt((freq_(index)-freq_(index+1))^2  + (wn_(index)-wn_(index+1))^2);       
end %for index = 1: size(freq_,1)
s_ = s_' ;
for index = 1: size(freq_,1)
if  points_for_spline_fit == -1  
    index_region = [1:size(freq_,1)];
else    
    if index <= points_for_spline_fit
    index_region = [1:index + points_for_spline_fit];    
    elseif  size(freq_,1) - index <= points_for_spline_fit
    index_region = [index- points_for_spline_fit:size(freq_,1)];    
    else
    index_region = [index- points_for_spline_fit : index + points_for_spline_fit];        
    end
end %if  points_for_spline_fit == -1  
df_ds(index)     =  (spline(s_(index_region) ,freq_(index_region)  , s_(index) + gap/2) - spline(s_,freq_ , s_(index) - gap/2))/gap ;
dwn_ds(index)    =  (spline(s_(index_region) ,wn_  (index_region)  , s_(index) + gap/2) - spline(s_,wn_   , s_(index) - gap/2))/gap ;
end  % for index = 1: size(freq_,1)

df_dwn           =   df_ds./dwn_ds ;
df_dk  = df_dwn' ;  %  this is what disperse gives (units check)
gr_vel_ = df_dk *2*pi ;
gr_vel_all(:,mode_index) = gr_vel_;
end % for mode_index = 1 : size(reshaped_proc_data.freq,2) % for all modes
end %calcuate the group velocity on the fly
%------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------
% These functions below for getting the external node lists in order
% the first is the outside linked nodes, any further lists are from internal voids  (e.g. pipes have 2 linked lists: 1 external, 1 internal)
%------------------------------------------------------------------------------------------------------------------------
%------------------------------------------------------------------------------------------------------------------------

function plot_data_structure       = get_ordered_external_nodes(plot_data_structure)
% function [ordered_node_lists, COA] = get_ordered_external_nodes(mesh) 

mesh                                     =  plot_data_structure.reshaped_proc_data.mesh                                                                        ; 
edge_list                                =  get_edge_list(mesh.el.nds)                                                                                         ;  
outside_edge_list                       =  get_inside_and_outside_edges(edge_list,mesh.el.nds)                                                                 ;   
node_lists                               =  find_connected_lists(outside_edge_list)                                                                            ;
ordered_node_lists                       =  organise_node_list(node_lists,mesh.nd.pos)                                                                         ;
plot_data_structure.COA                  =  [round(mean(mesh.nd.pos(ordered_node_lists{1},1))*1E9)/1E9 round(mean(mesh.nd.pos(ordered_node_lists{1},2)))/1E9]  ;
plot_data_structure.ordered_node_lists   =  ordered_node_lists;

end % function results = get_ordered_external_nodes(mesh)

function edge_list                 = get_edge_list(element_nodes)
% edge in this context means the edge of an individual element

edge_list        =  zeros(size(element_nodes,1)*size(element_nodes,2),2); 

for index = 1 : size(element_nodes,1)
for edge_index = 1:size(element_nodes,2)    
if  edge_index ~= size(element_nodes,2)    
temp_edge = [element_nodes(index,edge_index),element_nodes(index,edge_index+1)];
else
temp_edge = [element_nodes(index,edge_index),element_nodes(index,1)];    
end

edge_list((index-1)*size(element_nodes,2)+edge_index,:) = temp_edge ;  
end %for edge_index = 1:size(element_nodes,1)    
end %for index = 1 : size(element_nodes,2)
end %function edge_list = get_edge_list(element_nodes)

function [outside_edge_list]       = get_inside_and_outside_edges(edge_list,element_nodes)

edge_list_c = [ edge_list(:,1)+ 1i*edge_list(:,2)];
edge_list_c_reversed = [edge_list(:,2)+ 1i*edge_list(:,1)];

inside_edge_list = zeros(size(element_nodes,1)*size(element_nodes,2),2) ;
inside_edge_counter = 0;
outside_edge_list = zeros(size(element_nodes,1)*size(element_nodes,2),2) ;
outside_edge_counter = 0;

for index = 1: size(edge_list_c,1)
%length(find (edge_list_c_reversed == edge_list_c(index)))
if length(find (edge_list_c_reversed == edge_list_c(index)))==1  % its either 1 or 0
inside_edge_counter = inside_edge_counter   + 1 ;
inside_edge_list(inside_edge_counter,:)     = [real(edge_list_c(index)),imag(edge_list_c(index))];

% its an inside edge
else    
% its an outside edge
outside_edge_counter = outside_edge_counter + 1 ;
outside_edge_list(outside_edge_counter,:)   = [real(edge_list_c(index)),imag(edge_list_c(index))];
end %if length(find (edge_list_c_reversed == edge_list_c(index)))==1    
end %for index = 1 size(edge_list_c,1)

outside_edge_list = outside_edge_list(find(outside_edge_list(:,1)~=0),:);  % remove extra zeros
inside_edge_list = inside_edge_list(find(inside_edge_list(:,1)~=0),:);     % remove extra zeros

end %function [outside_edge_list,inside_edge_list] = get_inside_and_outside_edges(edge_list);

function node_list                 = find_connected_lists(external_edge_list)
 
total_node_count = 0;
total_length = length(external_edge_list);
current_external_edge_list = external_edge_list;
linked_edge_counter  =  0;

while total_node_count < total_length && linked_edge_counter <10  % to stop hanging
    
linked_edge_counter = linked_edge_counter + 1;
back_at_start = 0;

ordered_edge_list_t = zeros(size(current_external_edge_list)); %initialise then remove the zero rows when finished

ordered_edge_counter = 0;

ordered_edge_list_t(1,:) = current_external_edge_list(1,:);
in_index = [];

while back_at_start == 0
ordered_edge_counter = ordered_edge_counter + 1;
next_index_temp = find(current_external_edge_list(:,1) == ordered_edge_list_t(ordered_edge_counter,2));
in_index = [in_index ; next_index_temp];    
total_node_count = total_node_count  +1   ;

%------------------------------------------------------------    
%length(next_index_temp)
%------------------------------------------------------------    
%disp(num2str(next_index_temp))

if  next_index_temp ~= 1        %should have a single value 
%------------------------------------------------------------    
%size(ordered_edge_list_t(ordered_edge_counter + 1,:))
%size(current_external_edge_list(next_index_temp,:))    
%------------------------------------------------------------    

ordered_edge_list_t(ordered_edge_counter + 1,:) = current_external_edge_list(next_index_temp,:);

else    
back_at_start = 1;    
end %if  next_index_temp ~= 1

end %while back_at_start ==0

node_list{linked_edge_counter} = ordered_edge_list_t(find(ordered_edge_list_t(:,1)~=0),1);

current_external_edge_list(in_index,:) = [];  % removed the edges that have been used in this linked edge

end  %while total_node_count <= length(results.external_edge_list)
end %function

function [ordered_node_lists]      = organise_node_list(node_lists,node_pos)
for index = 1:size(node_lists,2)       %-------------------------
cx_list_temp = node_pos(node_lists{index},1) + 1i*node_pos(node_lists{index},2);
cx_list_temp = cx_list_temp - mean(cx_list_temp);
mean_rad(index) = mean(abs(cx_list_temp));
cx_list{index} = cx_list_temp;
end %for index = 1:size(aa,2)          %-------------------------
[~,outside_index] = max(mean_rad);     % this is the outside of the mesh linked node list
%----------------------------------------------------------------
for index = 1: size(cx_list,2)
% create an index    
temp__index  = ones(length(cx_list{index}),1).*(1:1:length(cx_list{index}))'            ; 
temp_pos_ang      = angle(cx_list{index}) +  abs(min(angle(cx_list{index})))            ;
[~,min_in]       = min(temp_pos_ang)                                                    ;
[~,max_in]       = max(temp_pos_ang)                                                    ;
switch (max_in - min_in) 
    case(1)
backwards = 1;        
    case(-1)         
backwards = 0;
    otherwise
if min_in ==1; backwards = 0;else backwards = 1;end;
end %switch (max_in - min_in)
if backwards == 1
temp_pos_ang = flipud(temp_pos_ang)  ;
temp__index = flipud(temp__index)    ;
[~,min_in]       = min(temp_pos_ang) ;  % will be in a diff pos
end %if backwars == 1    
if min_in~=1
node_order    = [temp__index(min_in:length(temp_pos_ang));temp__index(1:min_in-1)];
else
node_order    = [temp__index(min_in:length(temp_pos_ang  ))];
end %if min_in~=1
ordered_node_lists_temp{index} = node_lists{index}(node_order);
end %for index = 1: size(cx_list,2)
%  re-order the lists
ordered_node_lists{1} = ordered_node_lists_temp{outside_index};
counter_ = 1;
for index = 1: size(ordered_node_lists_temp,2)
if index ~= outside_index; counter_ = counter_ + 1 ;ordered_node_lists{counter_}= ordered_node_lists_temp{index};end;
end %for index = 1: size(ordered_node_lists_temp,2)
end %function  
%------------------------------------------------------------------------------------------------------------------------
% These functions below for creating a full 3d mesh for a full 3d plot or animation
% including longitudinal displacements
%------------------------------------------------------------------------------------------------------------------------
% whenever a new point on the graph is selected-  calculate the undeforemd
% mesh and store in the data structure
%------------------------------------------------------------------------------------------------------------------------
function plot_data_structure        = get_undeformed_3d_mesh_properties(plot_data_structure)

ordered_node_positions          = plot_data_structure.ordered_node_lists ;
front_properties.Vertices       = plot_data_structure.undeformed_node_positions                                                                                         ;    
front_properties.Faces          = make_quad(plot_data_structure.reshaped_proc_data.mesh.el.nds)                                                                         ;    %  add a 4th node to the triangular patches 'NaN'  so that quads can be added               
no_length_increments            = 20    ;
guide_length                    = 1     ;
current_ordered_node_positions =  ordered_node_positions;
mesh_ = front_properties                                   ;  % update this each time round the loop (BELOW)


for index = 1: no_length_increments
current_z = (index/no_length_increments) * guide_length ;    
    for index_2 = 1: size(current_ordered_node_positions,2)
last_node_index  = max(max(mesh_.Faces));
current_ring =  [mesh_.Vertices(ordered_node_positions{index_2},1)   ,  mesh_.Vertices(ordered_node_positions{index_2},2),ones(length(mesh_.Vertices(ordered_node_positions{index_2})),1)*current_z ];
mesh_.Vertices  =  [mesh_.Vertices ; current_ring] ;
current_ring_nodes            =  [last_node_index + 1 : 1 : last_node_index + length(current_ordered_node_positions{index_2})];
new_patches = zeros(length(current_ordered_node_positions{index_2}),4); % allocates space for this (or reinitialise)
for index_3 =  1:length(current_ordered_node_positions{index_2})
    if index_3 ~=  length(current_ordered_node_positions{index_2})
new_patches(index_3,:) = [current_ordered_node_positions{index_2}(index_3),current_ordered_node_positions{index_2}(index_3+1),current_ring_nodes(index_3+1),current_ring_nodes(index_3)];
else
new_patches(index_3,:) = [current_ordered_node_positions{index_2}(index_3),current_ordered_node_positions{index_2}(1),current_ring_nodes(1),current_ring_nodes(index_3)];
%end  % if index_2 ~=  end_index
    end  %if index_3 ~=  length(current_ordered_node_positions{index_2})
end  %for index_3 =  1:length(current_ordered_node_positions{index_2}
% loop for new faces
mesh_.Faces     =  [mesh_.Faces; new_patches ] ;
current_ordered_node_positions{index_2} =  current_ring_nodes ;  % update to the new positions (ready for the next increment of 'index' 
    end %for index_2 = 1: size(current_ordered_node_positions,2)    
end %for index = 1: no_length_increments    

% check dimensions and give some addtional info about the 3d mesh (below)

unique_z_values = unique(mesh_.Vertices(:,3));   % this should not be in the calculation part as it is the same every time - leave for now 
zero_indices = find(mesh_.Vertices(:,3) == unique_z_values(1));   % this may have more nodes than the non zero values and so is treated seperately
non_zero_length =  length(find(mesh_.Vertices(:,3) == unique_z_values(2)));
total_ordered_node_length = 0;
for index = 1: size(ordered_node_positions,2)
total_ordered_node_length = total_ordered_node_length + length(ordered_node_positions{index});
end %for index = 1: ordered_node_positions

if total_ordered_node_length == non_zero_length; correct_length = 1; else correct_length = 0;end %if total_ordered_node_length == non_zero_length

all_same = 1;
for index = 2:length(unique_z_values)
if  non_zero_length ~= length (find(mesh_.Vertices(:,3) == unique_z_values(index)));
all_same = 0;    
end % this should never happen!
end % Check dims are the same

if all_same ==1 && correct_length ==1
non_zero_indices = zeros(total_ordered_node_length,length(unique_z_values)-1);
for index = 2:length(unique_z_values)
non_zero_indices(:,index-1) = find(mesh_.Vertices(:,3) == unique_z_values(index))';
end

plot_data_structure.undeformed_3d_mesh_properties.mesh_                = mesh_                                             ;            % These are the undeformed mesh properties   
plot_data_structure.undeformed_3d_mesh_properties.non_zero_indices     = non_zero_indices                                  ;            % These are the undeformed mesh properties 
plot_data_structure.undeformed_3d_mesh_properties.zero_indices         = zero_indices                                      ;            % These are the undeformed mesh properties
plot_data_structure.undeformed_3d_mesh_properties.unique_z_values      = unique_z_values                                   ;            % These are the undeformed mesh properties   
%undeformed_3d_mesh_properties.phase_angles_shift   = 

else
disp(['error with the non zero length parts of the mesh, all_same = ',num2str(all_same),',correct_length = ',num2str(correct_length),'.'])
plot_data_structure.undeformed_3d_mesh_properties                      = -1                                                ;
end %if all_same ==1

end % function 

function face_patches               = make_quad(face_patches)

if size(face_patches,2) ==3

for index = 1 :size(face_patches,1)    
face_patches(index,4) = NaN;    
end %for index = 1 :size(face_patches,1)    

elseif size(face_patches,2) ==4
%do nothing    
else    
disp('error this function is hard wired for converting triangle patches to quads')    
end %if size(face_patches,2) ==3
        
end    % function face_patches = make_quad(face_patches);

function [deformed_3d_mesh]         = get_deformed_3d_mesh(ms_x , ms_y , ms_z , undeformed_3d_mesh_properties , ordered_node_lists , mult_factor, cartesian_or_cylindrical  )  
% ms_x , ms_y , ms_z , undeformed_3d_mesh_properties , ordered_node_lists , mult_factor , cartesian_or_cylindrical
% mult_factor, cartesian_or_cylindrical , undeformed_node_positions
all_nodes                            =    undeformed_3d_mesh_properties.mesh_.Vertices      ;
non_zero_indices                     =    undeformed_3d_mesh_properties.non_zero_indices    ;
zero_indices                         =    undeformed_3d_mesh_properties.zero_indices        ; 
unique_z_values                      =    undeformed_3d_mesh_properties.unique_z_values     ;
phase_angles_shift                  = 4*pi*(unique_z_values./ max(unique_z_values))         ;   % make 4pi an option later
deformed_mesh_Vertices               =    zeros(size(all_nodes))                            ; %allocate space for the deformed_mesh positions

switch(cartesian_or_cylindrical)
    case{1 2}   % cartesian (cylindrical defaulted to this at present)
% this has a loop where for the first index used would be the zero values and for all further iterations the nonzero values would be used.
for index = 1 : length(phase_angles_shift)
if index ==1 % use the zero values and the ms_deformations as they are, (no phase angle shift)
del_x  = real(ms_x)*mult_factor;
del_y  = real(ms_y)*mult_factor;
del_z  = real(ms_z)*mult_factor;
deformed_mesh_Vertices(zero_indices,:)  =  [ all_nodes(zero_indices,1)+ del_x  , all_nodes(zero_indices,2)+ del_y ,all_nodes(zero_indices,3)+ del_z ] ;

else          % use the non zero values and the ms_deformations as they are    
    
current_node_indices =  non_zero_indices(:,index-1) ;
ms_x_shifted  =  abs(ms_x).*exp(1i*(angle(ms_x)+phase_angles_shift(index)));
ms_y_shifted  =  abs(ms_y).*exp(1i*(angle(ms_y)+phase_angles_shift(index)));
ms_z_shifted  =  abs(ms_z).*exp(1i*(angle(ms_z)+phase_angles_shift(index)));
del_x  = real(ms_x_shifted)*mult_factor;
del_y  = real(ms_y_shifted)*mult_factor;
del_z  = real(ms_z_shifted)*mult_factor;

starting_index =  1; 
for index_2 = 1:size(ordered_node_lists,2) % go through each linked list
    counter_ = 0;
    for index_3  = starting_index : starting_index + length(ordered_node_lists{index_2})-1
    counter_ = counter_+1;
    deformed_mesh_Vertices(current_node_indices(index_3),:) =  [all_nodes(current_node_indices(index_3),1)+ del_x(ordered_node_lists{index_2}(counter_)) ,...
    all_nodes(current_node_indices(index_3),2)+ del_y(ordered_node_lists{index_2}(counter_)),all_nodes(current_node_indices(index_3),3)+ del_z(ordered_node_lists{index_2}(counter_))];

    end %for index_3  = starting_index: starting_index+ length(ordered_node_lists{index_2})-1
starting_index = starting_index + length(ordered_node_lists{index_2});
end %for index_2 = 1:size(ordered_node_lists,2) % go through each linked list
end %if index == 1 else....

end % for index = 1 : length(phase_angles_shift)    
deformed_3d_mesh.Faces = undeformed_3d_mesh_properties.mesh_.Faces     ;
deformed_3d_mesh.Vertices = deformed_mesh_Vertices                     ;
%    case(2)   % cylindrical
%disp('not done yet')        
end % switch(cartesian_or_cylindrical)
end %function
%--------------------------------------------------------------------------------------------------------------------------------
% ***DONE calculate group vel on the fly and use a piecewise spline
% ***DONE convergence studies on 2mm rod  --  compare for a number of frequencies
% ***DONE and mesh sizes................................................
% ***DONE  still need to be able to select from the graph
% ***DONE  set the limits of the dispersion curve
% ***DONE 'lim_values' ,      {[0  0.1E5] ,  [0  0.1E5] , [0 10000]  ,  [0 10000]} -
% ***DONE  these are the initial values but can be changed
% ***DONE 'labels_options',  {'Freq(Hz)','WaveNo.(1/m)','Phase Velocity(m/s)','Group Velocity(m/s)'}
% ***DONE  x_label_index     ->     1 , 2 , 3 or 4  // start with 1
% ***DONE  y_label_index     ->     1 , 2 , 3 or 4  // start with 3
% ***DONE  set limits should have 4 options:   freq , K , Vph , Vgr
% ***DONE  are  whole value ( nearest 1000 ? )  of the max value -  be able to set
% ***DONE  minimum and maximum values
% ***DONE  plot_data_structure.selected_x
% ***DONE  plot_data_structure.slected_pv
% ***DONE  finish off the 3d animation
% ***DONE  select  ------ modes to show from a drop box -- default  is all
% ***DONE have a selection drop box wich allows you to select 1 or more modes to
% ***DONE plot plus have the option of plotting all
% ***DONE plot a 3d (static) of the mode 
% ***DONE get the undeformed 3d mesh and add the deformed values to it for a the
% ***DONE relevent mode assume the length of the mesh is 1 wavenumber 
% ***DONE work out why the animation jumps 
% ***DONE select modes to show in the dispersion plots 
% ***DONE histogram of phase angle  -  mainly -80 180 0 small number -90 90  (300 time more 180 to  90) 
% ***DONE have a rest mesh plots (including animation) and a reset dispersion plots (including point on curves)
% ***DONE set up a button for number of angle_increments as a set for speed  go from 10 - 80 
% ***DONE create a function to inititialise the plots after any button or slider
% ***DONE has been activated
% ***DONE change the mesh view to a patch view
% ***DONE different views for the animation -- xy/xz/isometric
% ***DONE give animation_starting_angle and its aliases a more appropriate name -
% ***DONE make animation name current animation angle-  always start from this
% ***DONE value-  when animation is stopped save this value
% ***DONE  set the z scale in the animation
% ***DONE current animation angle- and store the value whenever that animation is stopped
% ***DONE get reshaped proc data to have group velocity and wavenumber in the
% ***DONE structure as well
% ***DONE  based on this
% ***DONE [deformed_3d_mesh]         = get_deformed_3d_mesh(ms_x, ms_y, ms_z, mult_factor, undeformed_3d_mesh ,cartesian_or_cylindrical, mult_factor)  
% ***DONE [deformed_node_positions]  = get_deformed_node_positions(ms_x, ms_y, ms_z, mult_factor, cartesian_or_cylindrical , undeformed_node_positions);
%***DONE Why does the fenel not animate
%--------------------------------------------------------------------------------------------------------------------------------

