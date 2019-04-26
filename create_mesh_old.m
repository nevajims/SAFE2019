% use plot_data_structure 
% **** The ize of the plot axis nees to always be the same  but the scaling can
% ****  change
% this is purely to crearte the mesh
% needs a figure for the equispaced external points and a figure for the
% mesh itself
% ----------------------------
% the required data
% ----------------------------
% for an circular cross sections
% inner_dia 
% thickness 
% no_points  -  common
% ----------------------------
% for the arbitary shape  
% ----------------------------
% external_points_file_name
% raw_data_
% height 
% width 
% no_points  -  common
% ------------------------------------------
% processed data as input to mesh generation 
% ------------------------------------------
% nodes_
% edge_  -  only  necesary if there are voids in the cross section
% data.hmax                      =     nom_el_size     ;
% ops.output                     =     false           ;
% ------------------------------------------
% [equispaced_points_mm, nom_el_size_mm]     =  get_outside_edge( data , 158.75 , 139.7 , 50 , 1); 
% nom_el_size                                =  0.5*nom_el_size_mm * 1E-3;
% nd_                                        =  [real(equispaced_points_mm )'*1E-3,imag(equispaced_points_mm )'*1E-3];
% for external voids syntax is as follows::
% [mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nodes_, edge_,hdata, ops);
% nom_el_size = rad/8;
% triangular_element_type = 2;
% --------------------------------------------------------------------------
% load('4-01-0A IM RAIL MODEL 56 E 1 (H 158_75 W 139_70).mat')
% load('5-01-0A IM RAIL MODEL 60 E 1 (H 172 W 150).mat')
% [equispaced_points_mm, nom_el_size_mm]     =  get_outside_edge( data , 172 , 150 , 100 , 1);
% [equispaced_points_mm, nom_el_size_mm]     =  get_outside_edge( data , 158.75 , 139.7 , 50 , 1); 
% nom_el_size = 0.5*nom_el_size_mm * 1E-3;
% nd_ = [real(equispaced_points_mm )'*1E-3,imag(equispaced_points_mm )'*1E-3];
% Data for Circular Cross section
% [nodes_,edge_]  =  create_arb_pipe(438.5 , 9.525 , 150);
% inner_dia , thickness , no_points
% Data for arbitary Cross section
% hdata.hmax                     =   nom_el_size;
% ops.output                     =   false;
% [mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(nd_, [], hdata, ops);
% need a status bar for calculating perimeter
% need a status bar for calculating mesh - maybe
% need some mesh stats once mesh has been calculated
% calculate mesh and plot mesh buttons

function [] =   create_mesh(default_settings_file_number)
% check whether boundary data can be calculated - if so calculate it
% now have a plot bounday button visible if the data file exists

if (nargin == 0) ; 
default_settings_file_name = ['default_settings_file_0.mat'];
else
default_settings_file_name = ['default_settings_file_',num2str(default_settings_file_number),'.mat'];
end %if (nargin == 0) ; 

mesh_input_settings  =  get_mesh_input_settings(default_settings_file_name) ;
% at this stage check existance of profiles diectory and the default
% prfiles file load it and process the data -  if possible    
% reprocess if any of the input parameters change (in each button)
boundary_points      = calculate_boundary_points(mesh_input_settings)       ;   

% recalculate if shape type is changed or any parameter is changed
fig_handle = figure('units','normalized','outerposition',[0.05 0.05 0.5 0.9],'DeleteFcn',@DeleteFcn_callback ,'UserData',struct('mesh_input_settings',mesh_input_settings,'boundary_points',boundary_points,'mesh',NaN));

% plot_data_structure                         = calculate_boundary_points(plot_data_structure);
plot_data_structure                           = get(fig_handle,'UserData')           ;
plot_data_structure.fig_handle                = fig_handle                           ;
plot_data_structure                           = set_UIcontrols (plot_data_structure) ;
plot_data_structure                           = fig_setup      (plot_data_structure) ;                           

set(fig_handle,'UserData',plot_data_structure)                                       ;

end %function [] =   create_mesh(initial_settings_data)


function DeleteFcn_callback(object_handle,~)
plot_data_structure = get(object_handle,'UserData');
end  % function Deletes any animation timer object that may exist at the time of closing the figure

function [boundary_points,mesh_input_settings] = calculate_boundary_points(mesh_input_settings)

%two posibilities
switch(mesh_input_settings.shape_type)
   
     case(1)
   if  ~isnan(mesh_input_settings.inner_dia) && ~isnan(mesh_input_settings.thickness) && ~isnan(mesh_input_settings.no_points)
[boundary_points.nodes_ , boundary_points.edge_] = create_arb_pipe(mesh_input_settings.inner_dia , mesh_input_settings.thickness , mesh_input_settings.no_points , 0 ) ;  

mesh_input_settings.nom_el_size{1}               = mesh_input_settings.thickness/4        ;
mesh_input_settings.min_el_size{1}               = mesh_input_settings.nom_el_size{1}/10  ;
mesh_input_settings.max_el_size{1}               = mesh_input_settings.nom_el_size{1}*10  ;

   else
boundary_points.nodes_ = NaN;
boundary_points.edge_  = NaN;
   end %   if  ~isnan(mesh_input_settings.inner_dia) && ~isnan(mesh_input_settings.thickness) && ~isnan(mesh_input_settings.no_points)         
   
    case(2)
   if  ~isnan(mesh_input_settings.height) && ~isnan(mesh_input_settings.width) && ~isnan(mesh_input_settings.no_points)&& isstruct(mesh_input_settings.raw_data_)
% [equispaced_points_mm , path_distance ]  = get_outside_edge_( data , height_ , width_ , no_of_points , 0); -  original
[boundary_points.nodes_ , boundary_points.edge_,nom_el_size] = get_outside_edge_(mesh_input_settings.raw_data_, mesh_input_settings.height , mesh_input_settings.width , mesh_input_settings.no_points , 0);        

mesh_input_settings.nom_el_size{2}               = floor(nom_el_size*10000)/10000         ; 
mesh_input_settings.min_el_size{2}               = mesh_input_settings.nom_el_size{2}/10  ;
mesh_input_settings.max_el_size{2}               = mesh_input_settings.nom_el_size{2}*10  ;

   else
boundary_points.nodes_ = NaN;
boundary_points.edge_  = NaN;
   end %   if  ~isnan(mesh_input_settings.inner_dia) && ~isnan(mesh_input_settings.thickness) && ~isnan(mesh_input_settings.no_points)         
   
%disp('to be written')

end %switch(plot_data_structure.mesh_input_settings.shape_type)

end %function plot_data_structure                         = calculate_boundary_points(plot_data_structure);

function plot_data_structure =  set_UIcontrols(plot_data_structure) 
button_handles.shape_choice_popup_txt = uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.95 0.2 0.03],'String','Select Shape Choice','HorizontalAlignment', 'left',  'visible', 'on');
button_handles.shape_choice_popup_handle =  uicontrol('Style', 'popup','units','normalized','String', {'circular','arbitary'} ,'Position'  , [0.25 0.95 0.2 0.03] ,'Value',plot_data_structure.mesh_input_settings.shape_type,'HorizontalAlignment', 'left', 'Callback' , @shape_choice_input);
button_handles.number_points_text =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.9 0.2 0.03],'String','#Points (min 10)','HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{1});
button_handles.number_points_edit_text_handle = uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.25 0.9 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.no_points),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{2}, 'Callback' , @select_number_points);
button_handles.Inner_Diameter_text =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.85 0.2 0.03],'String','Inner Diameter (mm)','HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{3});
button_handles.Inner_Diameter_edit_text_handle = uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.25 0.85 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.inner_dia*1000),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{4}, 'Callback' , @set_Inner_Diameter);
button_handles.Thickness_text      =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.8 0.2 0.03],'String','Thickness (mm)','HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{5});
button_handles.Thickness_edit_text_handle = uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.25 0.8 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.thickness*1000),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{6}, 'Callback' , @set_Thickness);

button_handles.height_text              =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.85 0.2 0.03],'String','Height (mm)','HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{7});
button_handles.height_edit_text_handle  =  uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.25 0.85 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.height*1000),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{8}, 'Callback' , @set_height);
button_handles.width_text      =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.8 0.2 0.03],'String','Width (mm)','HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{9});
button_handles.width_edit_text_handle = uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.25 0.8 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.width*1000),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{10}, 'Callback' , @set_width);
button_handles.select_profile_file_button_handle = uicontrol('Style','pushbutton','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.01,0.7 0.18 0.05],'String','Select File','HorizontalAlignment', 'left',  'visible', 'on', 'visible', plot_data_structure.mesh_input_settings.visible_handles{11},'Callback',@select_profile_file);     
button_handles.profile_file_text      =  uicontrol('Style','text','units','normalized','FontSize',8,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.21 0.7 0.32 0.02],'String',plot_data_structure.mesh_input_settings.external_points_file_name  ,'HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{12});
button_handles.plot_button_handle = uicontrol('Style','togglebutton','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.01,0.6 0.18 0.05],'String','Plot boundary points','HorizontalAlignment', 'left',  'visible', 'on','Callback' , @plot_points);     

%  create meshing buttons
temp_text = ['Element size (mm), (',num2str(plot_data_structure.mesh_input_settings.min_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000) ,', ',num2str(plot_data_structure.mesh_input_settings.max_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000),')'];
button_handles.mesh_size_text =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.01 0.5 0.35 0.03],'String',temp_text,'HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{13});
button_handles.mesh_size_edit_text_handle = uicontrol('Style','edit','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.35 0.5 0.05 0.03],'String',num2str(plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000),'HorizontalAlignment', 'right',  'visible', plot_data_structure.mesh_input_settings.visible_handles{14},'Callback',@set_element_size);
button_handles.calc_mesh_text =  uicontrol('Style','text','units','normalized','FontSize',12,'BackgroundColor',[0.8,0.8,0.8], 'Position',[0.25 0.4 0.3 0.03],'String',plot_data_structure.mesh_input_settings.mesh_calc_text,'HorizontalAlignment', 'left',  'visible', plot_data_structure.mesh_input_settings.visible_handles{13});
button_handles.calc_mesh_button_handle = uicontrol('Style','togglebutton','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.01,0.4 0.18 0.05],'String','Calculate mesh','HorizontalAlignment', 'left',  'visible', 'on','Callback' , @Calculate_mesh);     
button_handles.plot_mesh_button_handle = uicontrol('Style','togglebutton','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.01,0.15 0.18 0.05],'String','Plot mesh','HorizontalAlignment', 'left',  'visible', 'on','Callback' , @plot_mesh);     


button_handles.save_mesh_button_handle = uicontrol('Style','pushbutton','units','normalized','BackgroundColor',[0.85,0.85,0.85], 'Position',[0.01,0.1 0.18 0.05],'String','Save mesh','HorizontalAlignment', 'left',  'visible', 'on','Callback' , @save_mesh);     

%-----------------------------------------------------------------
%-----------------------------------------------------------------
%----------------- save mesh    if mesh exists -------------------
%-----------------------------------------------------------------
%-----------------------------------------------------------------

% create a button for plotting the outline-  should be greyd out unless certail criterial are met
plot_data_structure.button_handles = button_handles;
end %function plot_data_structure =  set_UIcontrols(plot_data_structure) 


function mesh_input_settings =  get_mesh_input_settings(default_settings_file_name)

if   exist(default_settings_file_name) ==2
load(default_settings_file_name) %  possibly put these in own directory or profiles firectory  
else     
    
mesh_input_settings.shape_choices                = {'circular','arbitary'}          ;
mesh_input_settings.shape_type                   = 1                                ;    % can be either   {'circular','arbitary'}
mesh_input_settings.visible_handles              = {'on','on','on','on','on','on','off','off','off','off','off','off','on','on'}  ;          % these should be in the data and then refered to after
% mesh_input_settings.visible_handles            ={'on','on','off','off','off','off','on','on','on','on','on','on','on','on'}  ;    
mesh_input_settings.inner_dia                    = 0                                             ;    % 
mesh_input_settings.thickness                    = 0.5e-3                                        ;    % 5 mm solid rod is original default 
mesh_input_settings.external_points_file_name    = 'profile_RAIL_56 E 1 (H 158_75 W 139_70).mat' ;    % if file dosen't  exist then make void
mesh_input_settings.height                       = 158.75e-3                                     ;
mesh_input_settings.width                        = 139.7e-3                                      ; 
mesh_input_settings.no_points                    = 40                                            ;    % number of equispaced points round the outside
mesh_input_settings.mesh_calc_text               = 'Mesh not Calculated yet'                     ;
mesh_input_settings.nom_el_size{1}               = mesh_input_settings.thickness/4               ;
mesh_input_settings.nom_el_size{2}               = 16.5E-3                                       ; 
mesh_input_settings.min_el_size{1}               = mesh_input_settings.nom_el_size{1}/10  ;
mesh_input_settings.max_el_size{1}               = mesh_input_settings.nom_el_size{1}*10  ;
mesh_input_settings.min_el_size{2}               = mesh_input_settings.nom_el_size{2}/10  ;
mesh_input_settings.max_el_size{2}               = mesh_input_settings.nom_el_size{2}*10  ;

mesh_input_settings.display_boundary_points      = 0                                             ;

% mesh_input_settings.mesh_size                    =    ; 
end % if   exist('default_settings_file_name') ==2    

if  ~isempty(dir('profiles\profile*.*'))
mesh_input_settings.profiles_folder_exists       = 1;
load(['profiles\',mesh_input_settings.external_points_file_name])                                ;
mesh_input_settings.raw_data_                    = data                                          ;    % simply called data----------------
else
mesh_input_settings.profiles_folder_exists       = 0;
mesh_input_settings.external_points_file_name    = 'no profiles directory' ;    % if file dosen't  exist then make void
mesh_input_settings.raw_data_                    = NaN;
end %if  ~isempty(dir('profiles\profile*.*'))

end %function mesh_input_settings =  get_mesh_input_settings(value_);


function plot_data_structure = fig_setup(plot_data_structure )
%(fig_handle,button_handles)
% put in axis labels and figure titles here
plot_data_structure.outside_points_axis     = subplot(2,2,2)             ;
axis equal
plot_data_structure.mesh_axis               = subplot(2,2,4)             ;
axis equal
set(plot_data_structure.outside_points_axis,'UserData',1)                ;
set(plot_data_structure.mesh_axis          ,'UserData',2)                ;    
end  % set the figure up with axis and plot data if it exists


function set_visable_handles(plot_data_structure)
set(plot_data_structure.button_handles.number_points_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{1});
set(plot_data_structure.button_handles.number_points_edit_text_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{2}); 
set(plot_data_structure.button_handles.Inner_Diameter_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{3}); 
set(plot_data_structure.button_handles.Inner_Diameter_edit_text_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{4}); 
set(plot_data_structure.button_handles.Thickness_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{5});   
set(plot_data_structure.button_handles.Thickness_edit_text_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{6}); 
set(plot_data_structure.button_handles.height_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{7}); 
set(plot_data_structure.button_handles.height_edit_text_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{8}); 
set(plot_data_structure.button_handles.width_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{9});   
set(plot_data_structure.button_handles.width_edit_text_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{10}); 
set(plot_data_structure.button_handles.profile_file_text, 'visible', plot_data_structure.mesh_input_settings.visible_handles{11});   
set(plot_data_structure.button_handles.select_profile_file_button_handle, 'visible', plot_data_structure.mesh_input_settings.visible_handles{12}); 
set(plot_data_structure.button_handles.mesh_size_text , 'visible', plot_data_structure.mesh_input_settings.visible_handles{13});   
set(plot_data_structure.button_handles.mesh_size_edit_text_handle , 'visible', plot_data_structure.mesh_input_settings.visible_handles{14}); 
temp_text = ['Element v size (mm), (',num2str(plot_data_structure.mesh_input_settings.min_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000) ,', ',num2str(plot_data_structure.mesh_input_settings.max_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000),')'];
set(plot_data_structure.button_handles.mesh_size_text,'String',temp_text)
set(plot_data_structure.button_handles.mesh_size_edit_text_handle,'String',num2str(plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000))
set(plot_data_structure.button_handles.calc_mesh_text,'String',plot_data_structure.mesh_input_settings.mesh_calc_text)

end %function set_visable_handles(plot_data_structure)


function plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure)

[plot_data_structure.boundary_points,plot_data_structure.mesh_input_settings]   = calculate_boundary_points(plot_data_structure.mesh_input_settings);
plot_data_structure.mesh_input_settings.mesh_calc_text                          = 'Mesh not calculated'                                             ;
plot_data_structure.mesh                                                        = nan                                                               ;

set(plot_data_structure.button_handles.calc_mesh_button_handle,'Value',0)
set(plot_data_structure.button_handles.plot_mesh_button_handle,'Value',0)

set(plot_data_structure.fig_handle,'CurrentAxes',plot_data_structure.mesh_axis)
cla
set_visable_handles(plot_data_structure)

if  get(plot_data_structure.button_handles.plot_button_handle,'Value') ==1
set(plot_data_structure.fig_handle,'CurrentAxes',plot_data_structure.outside_points_axis)
cla
plot(plot_data_structure.boundary_points.nodes_(:,1)*1000,plot_data_structure.boundary_points.nodes_(:,2)*1000,'.')
axis equal
end % if get(plot_data_structure.button_handles.plot_button_handle,'Value') == 1
end % function plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure)

%---------------------------------------------------------------------
%------------------%%%% CallBack Functions %%%% ----------------------
%---------------------------------------------------------------------

function save_mesh(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
val_ = get(hObject,'Value');
disp(num2str(val_))

if exist('meshes','dir') ==7
if isstruct(plot_data_structure.mesh)
   
cd('meshes')     
mesh_file_name       =   create_mesh_file_name(plot_data_structure) ;
mesh                 =   plot_data_structure.mesh                   ;
mesh_input_settings  =   plot_data_structure.mesh_input_settings    ;
save(mesh_file_name, 'mesh', 'mesh_input_settings');
cd('..')

else
msgbox('mesh doesnt exist')       
end

else
msgbox('cannot save file as there is no mesh directory')   
end    

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function save_mesh(hObject, ~)


function Calculate_mesh(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
val_ = get(hObject,'Value');
disp(num2str(val_))

switch(val_  )
    case(1)
if isstruct(plot_data_structure.boundary_points)
hdata.hmax                     =    plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type};
ops.output                     =    false;
[mesh.nd.pos, mesh.el.nds, mesh.el.fcs] = mesh2d(plot_data_structure.boundary_points.nodes_,[], hdata, ops);    
plot_data_structure.mesh = mesh;
plot_data_structure.mesh_input_settings.mesh_calc_text               = 'Mesh Calculated'                                 ;
else
plot_data_structure.mesh_input_settings.mesh_calc_text               = 'Mesh not calculated'                             ;
set(hObject,'Value',0);
end %if isstruct(plot_data_structure.boundary_points)
    case(0)
plot_data_structure.mesh_input_settings.mesh_calc_text               = 'Mesh not calculated'                             ;
plot_data_structure.mesh        = nan;
end %switch(val_  )
set_visable_handles(plot_data_structure)
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function Calculate_mesh(hObject, ~)

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------

function plot_mesh(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
val_ = get(hObject,'Value');
set(plot_data_structure.fig_handle,'CurrentAxes',plot_data_structure.mesh_axis)

switch(val_)
    
    case(1)
    if isstruct(plot_data_structure.mesh)    
    cla
    fv.Vertices = plot_data_structure.mesh.nd.pos;
    fv.Faces =    plot_data_structure.mesh.el.nds;
    patch(fv, 'FaceColor', 'c');
    axis equal;
    axis off;
    else    
    cla    
    set(hObject,'Value',0);        
    end  %if ~isnan(boundary_points.nodes_)    
    
    case(0)
    cla
    
end %switch(val_)


set(get(hObject,'Parent'),'UserData',plot_data_structure);

end %function plot_mesh(hObject, ~)

%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------


function set_element_size(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
old_value = plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type};
but_val = str2num(get(hObject,'String'));
% mesh_input_settings.min_el_size{1}
% mesh_input_settings.max_el_size{1}
min_val = plot_data_structure.mesh_input_settings.min_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000;
max_val = plot_data_structure.mesh_input_settings.max_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000;

if but_val > min_val  &&  but_val < max_val
plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type} = but_val /1000;
plot_data_structure.mesh_input_settings.mesh_calc_text               = 'Mesh not calculated'                             ;
plot_data_structure.mesh        = nan;
set(plot_data_structure.button_handles.calc_mesh_button_handle,'Value',0)
set_visable_handles(plot_data_structure)
else
set(plot_data_structure.button_handles.mesh_size_edit_text_handle, 'String',num2str(old_value*1000));
end %if but_val > min_val && but_val < max_valbut_val
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function select_profile_file (hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
but_val = get(hObject,'Value');
disp(num2str(but_val));

if (plot_data_structure.mesh_input_settings.profiles_folder_exists)
cd('profiles')
files_ = dir('profile*.mat');
files_str = {files_.name};
[selection_,ok_] = listdlg('PromptString','Select a file:','SelectionMode','single', 'ListString',files_str);

if(ok_)
plot_data_structure.mesh_input_settings.external_points_file_name = files_str{selection_}               ;
load(plot_data_structure.mesh_input_settings.external_points_file_name)                                 ;
plot_data_structure.mesh_input_settings.raw_data_                    = data                                                 ;    
set(plot_data_structure.button_handles.profile_file_text, 'String',plot_data_structure.mesh_input_settings.external_points_file_name)
set_visable_handles(plot_data_structure)                                                                ;
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);
cd('..')
end %if(ok_)
else
mesh_input_settings.external_points_file_name    = 'no profiles directory' ;    % if file dosen't  exist then make void
mesh_input_settings.raw_data_                    = NaN;
end %if (mesh_input_settings.profiles_folder_exists)
%[modes_to_plot,ok] = listdlg('PromptString','Select modes to display:','SelectionMode','single','ListString',arrayfun(@num2str,(1:size(plot_data_structure.reshaped_proc_data.freq,2)  ),'unif',0));

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end


function shape_choice_input(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
% this should just display one of the two options for display of inputs
plot_data_structure.mesh_input_settings.shape_type  =  get(hObject,'Value');

%disp(plot_data_structure.mesh_input_settings.shape_type)

switch(plot_data_structure.mesh_input_settings.shape_type )
    case(1)
plot_data_structure.mesh_input_settings.visible_handles              = {'on','on','on','on','on','on','off','off','off','off','off','off','on','on'}  ;        
% reset the current value of

    case(2)        
plot_data_structure.mesh_input_settings.visible_handles              = {'on','on','off','off','off','off','on','on','on','on','on','on','on','on'}  ;    
end %switch(plot_data_structure.mesh_input_settings.shape_type )

set (plot_data_structure.button_handles.mesh_size_edit_text_handle,'String',num2str(plot_data_structure.mesh_input_settings.nom_el_size{plot_data_structure.mesh_input_settings.shape_type}*1000))
% if its changed reset boundary conditions
set_visable_handles(plot_data_structure);

plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % function shape_choice_input(hObject, ~)

function select_number_points(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
num_val = str2num(get(hObject,'String'));

old_value =  plot_data_structure.mesh_input_settings.no_points;

if isempty(num_val)
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.no_points));
else
rounded_num_val = floor(num_val);
if num_val > 10  
set(hObject,'String',num2str(rounded_num_val));
plot_data_structure.mesh_input_settings.no_points = rounded_num_val;
else    
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.no_points));    
end %if num_val > 10    
end %if isempty(num_val)

% if value changed do this

if plot_data_structure.mesh_input_settings.no_points ~= old_value
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);
end

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function select_number_points(hObject, ~)

function set_Inner_Diameter(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
num_val = str2num(get(hObject,'String'));
%plot_data_structure.mesh_input_settings.inner_dia*1000
old_value = plot_data_structure.mesh_input_settings.inner_dia;

if isempty(num_val)
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.inner_dia*1000));
else
if num_val >=  0
set(hObject,'String',num2str(num_val));
plot_data_structure.mesh_input_settings.inner_dia = num_val/1000;
else    
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.inner_dia*1000));    
end %if num_val >=  0
end %if isempty(num_val)

if old_value ~= plot_data_structure.mesh_input_settings.inner_dia
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);
end %~if old_value ~= plot_data_structure.mesh_input_settings.inner_dia

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end


function set_Thickness(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
num_val = str2num(get(hObject,'String'));

old_value = plot_data_structure.mesh_input_settings.thickness;

if isempty(num_val)
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.thickness*1000));
else
if num_val >=  0.01
set(hObject,'String',num2str(num_val));
plot_data_structure.mesh_input_settings.thickness = num_val/1000;
else    
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.thickness*1000));    
end %if num_val >=  0
end %if isempty(num_val)
% now recalc boundary and clear figure if necessary

if old_value ~= plot_data_structure.mesh_input_settings.inner_dia
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);
end %~if old_value ~= plot_data_structure.mesh_input_settings.inner_dia

set(get(hObject,'Parent'),'UserData',plot_data_structure);
end



function set_width(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
num_val = str2num(get(hObject,'String'));

old_value = plot_data_structure.mesh_input_settings;

if isempty(num_val)
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.width*1000));
else
if num_val >=  0.01
set(hObject,'String',num2str(num_val));
plot_data_structure.mesh_input_settings.width = num_val/1000;
else    
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.width*1000));    
end %if num_val >=  0
end %if isempty(num_val)
% now recalc boundary and clear figure if necessary

if old_value ~= plot_data_structure.mesh_input_settings
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);    
end%if old_value ~= plot_data_structure.mesh_input_settings    

set(get(hObject,'Parent'),'UserData',plot_data_structure);
%end
end

function set_height(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
num_val = str2num(get(hObject,'String'));

old_value = plot_data_structure.mesh_input_settings.height;

if isempty(num_val)
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.height*1000));
else
if num_val >=  0.01
set(hObject,'String',num2str(num_val));
plot_data_structure.mesh_input_settings.height = num_val/1000;
else    
set(hObject,'String',num2str(plot_data_structure.mesh_input_settings.height*1000));    
end %if num_val >=  0
end %if isempty(num_val)


if old_value ~= plot_data_structure.mesh_input_settings.height
plot_data_structure = recalc_boundary_points_and_plot(plot_data_structure);       
end %if old_value ~= plot_data_structure.mesh_input_settings.height
    
set(get(hObject,'Parent'),'UserData',plot_data_structure);

end


function plot_points(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
but_val = get(hObject,'Value');
%disp(num2str(but_val));

set(plot_data_structure.fig_handle,'CurrentAxes',plot_data_structure.outside_points_axis)
if but_val == 1
if ~isnan(plot_data_structure.boundary_points.nodes_)    
cla
plot(plot_data_structure.boundary_points.nodes_(:,1)*1000,plot_data_structure.boundary_points.nodes_(:,2)*1000,'.')
axis equal
else    
cla    
set(hObject,'Value',0);        
end %if ~isnan(boundary_points.nodes_)    
else
cla
end %if but_val == 1


set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function plot_points(hObject, ~)

%%%% Functions
%---------------------------------------------------------------------

function mesh_file_name =   create_mesh_file_name(plot_data_structure)

mesh_file_name = 'MESH_';

switch(plot_data_structure.mesh_input_settings.shape_type)

case(1)
if plot_data_structure.mesh_input_settings.inner_dia == 0   
mesh_file_name = [mesh_file_name,'ROD_D',num2str(plot_data_structure.mesh_input_settings.thickness*1000*2),'_mm_'];  %rod
else
mesh_file_name = [mesh_file_name,'PIPE_D_',num2str(plot_data_structure.mesh_input_settings.inner_dia*1000),'_T_',num2str(plot_data_structure.mesh_input_settings.thickness*1000),'mm_'] ;   %pipe        
end %if mesh_input_settings.inner_dia ==0   
   
case(2)
mesh_file_name = [mesh_file_name,get_name_part(plot_data_structure.mesh_input_settings.external_points_file_name),'_' ];
end %switch(plot_data_structure.mesh_input_settings.shape_type)

dir_deets = dir([mesh_file_name,'*.mat']);
all_names = {dir_deets.name};
if isempty(all_names)
mesh_file_name = [mesh_file_name,'1.mat'];
else
start_ind  = length(mesh_file_name)+1;
for index = 1:length(all_names)
current_name = all_names{index};
end_ind = length(current_name)-4;
numbers_(index)  =  str2num((current_name(start_ind:end_ind)));
end  %for index = 1:length all_names       
largest_number = max(numbers_);
mesh_file_name = [mesh_file_name,num2str(largest_number+1),'.mat'];
end %if isempty(all_names)

end %function mesh_file_name =   create_mesh_file_name(plot_data_structure)

function name_part_ = get_name_part(external_points_file_name)
counter = 0; 
space_found = 0;
while (space_found == 0)
    counter = counter + 1; 
    if strcmp(external_points_file_name,' ') ==1
       space_found = 1 ;
       end_point = counter-1
    end %if strcmp(external_points_file_name,' ') ==1
end %while space_found == 0    
name_part_ = external_points_file_name(9:end_point );
end %function get_name_part(mesh_input_settings.external_points_file_name)


function [nodes_,edge_] = create_arb_pipe(inner_dia , thickness , no_points , do_plot)
if inner_dia ~=0  
internal_rad = inner_dia/2           ;
external_rad = inner_dia/2+thickness ;
circumfence_ratio = external_rad/internal_rad;
divisor_ = circumfence_ratio + 1;
number_external_nodes =  floor(circumfence_ratio*no_points/divisor_)   +1  ;
number_internal_nodes =  ceil(no_points/divisor_) +1;
angle_external = linspace(0, 2 * pi, number_external_nodes);
angle_external  = angle_external(1:end - 1)';
angle_internal = linspace(0, 2 * pi, number_internal_nodes);
angle_internal  = angle_internal(1:end - 1)';
outer_nodes  = [cos(angle_external), sin(angle_external)] * external_rad;    
inner_nodes  = [cos(angle_internal), sin(angle_internal)] * internal_rad;    
nodes_ =  [ inner_nodes ; outer_nodes ];
n_inner_nodes = size(inner_nodes,1);
n_outer_nodes = size(outer_nodes,1);
c_inner_nodes = [(1:n_inner_nodes-1)', (2:n_inner_nodes)'; n_inner_nodes, 1];
c_outer_nodes = [(1:n_outer_nodes-1)', (2:n_outer_nodes)'; n_outer_nodes, 1];
edge_ = [c_inner_nodes ; c_outer_nodes + n_inner_nodes ] ;
else    
angle_ = linspace(0, 2 * pi, no_points+1);    
angle_  = angle_(1:end - 1)';
nodes_  = [cos(angle_), sin(angle_)] * thickness;     
n_nodes = size(nodes_,1);
c_nodes = [(1:n_nodes-1)', (2:n_nodes)'; n_nodes, 1] ;
edge_ = [c_nodes] ;
end %if inner_dia ~=0  

if do_plot ==1
plot(nodes_(:,1),nodes_(:,2),'.')
axis equal
end % if do_plot ==1
%size(nodes_)
end  % function [nodes_,edge_] = create_arb_pipe(inner_dia , thickness , no_points , do_plot)


%function [equispaced_points_mm , path_distance ]  = get_outside_edge_( data , height_ , width_ , no_of_points , do_plot); 
function [nodes_ , edge_ , nom_el_size ]  = get_outside_edge_( data , height_ , width_ , no_of_points , do_plot)

horz_mm_p_pix = width_/max(data.x_);
vert_mm_p_pix = height_/max(data.y_);
complex_p                                    =   data.x_+  1i*data.y_            ;
ordered_complex_p                            =   put_points_in_order(complex_p)  ;
%if length(complex_p) == length(ordered_complex_p)
path_length                                  =   get_path_length(ordered_complex_p);
ordered_complex_p                            =   [ordered_complex_p;ordered_complex_p(1)] ;
[equispaced_points,equispaced_path_length]   =   get_equispaced_points(path_length(1:1:length(path_length)), ordered_complex_p(1:1:length(path_length)), no_of_points);
equispaced_points_mm                         =  equispaced_points       *  horz_mm_p_pix  ;
equispaced_path_length_mm                    =  equispaced_path_length  *  horz_mm_p_pix  ; 
equispaced_points_mm                         =  equispaced_points_mm -mean(equispaced_points_mm)  ;
opp_mmm                                      =  (ordered_complex_p- mean(ordered_complex_p)) * horz_mm_p_pix    ;

nom_el_size =  mean(diff(equispaced_path_length_mm));
disp (['suggested element_size',num2str(nom_el_size*1000),'mm'])

if do_plot == 1
figure
hold on
subplot(2,1,1)
plot(equispaced_points_mm,'.')
hold on
axis equal
subplot(2,1,2)
plot(opp_mmm(1:10:length(opp_mmm)),'r.')
axis equal 
title(['Horz mm per pixel =' , num2str(horz_mm_p_pix), ', Vert mm per pixel =' , num2str(vert_mm_p_pix),'.']) 
end %if do_plot == 1

%else
%disp('The ordered points are not the same size as the unordered ones-  investigate the function  ~~put_points_in_order~~ ')
%disp([num2str( length(complex_p)),'/',num2str( length(ordered_complex_p))])
%end %if length(complex_p) == length(ordered_complex_p)
nodes_ = [real(equispaced_points_mm )',imag(equispaced_points_mm )'];
n_nodes = size(nodes_,1);
c_nodes = [(1:n_nodes-1)', (2:n_nodes)'; n_nodes, 1] ;
edge_ = [c_nodes] ;

end 

%----------------------------------------------------------------------------------------------------------
function ordered_complex_p = put_points_in_order(complex_p) ;
% puts points in order around the edge
[current_val , start_ind] = min(complex_p);
ordered_indices = [start_ind] ;  % start off the ordered list 
more_points = 1;

total_number_of_points = length(complex_p);
total_number_of_found_points = 0;

while more_points == 1
dist_to_current = abs((complex_p - current_val));
[sort_v_dummy,sorted_ind] = sort(dist_to_current);
total_number_of_found_points = total_number_of_found_points + 1;
aaa = waitbar(total_number_of_found_points/total_number_of_points );
% the first value sorted_ind(1)is the distance to current val(0).

if isempty(find(ordered_indices == sorted_ind(2)))
ordered_indices = [ordered_indices,sorted_ind(2)];
current_val = complex_p(sorted_ind(2));

elseif isempty(find(ordered_indices == sorted_ind(3)))
ordered_indices = [ordered_indices,sorted_ind(3)];    
current_val = complex_p(sorted_ind(3));

elseif isempty(find(ordered_indices == sorted_ind(4)))
ordered_indices = [ordered_indices,sorted_ind(4)];    
current_val = complex_p(sorted_ind(4));

elseif isempty(find(ordered_indices == sorted_ind(5)))
ordered_indices = [ordered_indices,sorted_ind(5)];    
current_val = complex_p(sorted_ind(5));

elseif isempty(find(ordered_indices == sorted_ind(6)))
ordered_indices = [ordered_indices,sorted_ind(6)];    
current_val = complex_p(sorted_ind(6));

elseif isempty(find(ordered_indices == sorted_ind(7)))
ordered_indices = [ordered_indices,sorted_ind(7)];    
current_val = complex_p(sorted_ind(7));

elseif isempty(find(ordered_indices == sorted_ind(8)))
ordered_indices = [ordered_indices,sorted_ind(8)];    
current_val = complex_p(sorted_ind(8));

elseif isempty(find(ordered_indices == sorted_ind(9)))
ordered_indices = [ordered_indices,sorted_ind(9)];    
current_val = complex_p(sorted_ind(9));


else
more_points   = 0;
end

end % while more_points ==1
close(aaa)

ordered_complex_p =  complex_p(ordered_indices);

end %function ordered_complex_p = put_points_in_order(complex_p);
%----------------------------------------------------------------------------------------------------------
function path_length =  get_path_length(ordered_complex_p);
% path legth (1) = 0
% path legth (2) = dist(1-2)
% path legth (3) = % path legth (2)+ dist(2-3)
% etc
path_length = zeros(1,length(ordered_complex_p));

for index = 2 : length(ordered_complex_p) + 1

if index  ==length(ordered_complex_p) + 1
current_val = ordered_complex_p(1);
else
current_val = ordered_complex_p(index);
end
path_length(index) = path_length(index-1)+  abs(current_val-ordered_complex_p(index-1));

end %for index = 2 : length(ordered_complex_p)
end %function path_length =  get_path_length = (ordered_complex_p);
%----------------------------------------------------------------------------------------------------------

function [equispaced_points,equispaced_path_length]   = get_equispaced_points(path_length, ordered_complex_p, no_of_points); 
distance_per_point = max(path_length)/(no_of_points-1);
% for each path length use a spline to calculate the value
equispaced_points         =  zeros(1,no_of_points);
equispaced_path_length    =  zeros(1,no_of_points);
triple_path_length        =  [path_length(1:length(path_length)-1) - max(path_length) , path_length(1:length(path_length)) , path_length(2:length(path_length)) + max(path_length)];
triple_ordered_complex_p  =  [ordered_complex_p(1:length(ordered_complex_p)-1)' , ordered_complex_p(1:length(ordered_complex_p))' , ordered_complex_p(2:length(ordered_complex_p))'];

for index = 1 : no_of_points 
% find the relavent index
equispaced_path_length(index) =   distance_per_point*(index-1)                                    ;
[dummy,closest_ind] = min(abs((path_length - equispaced_path_length(index))))                     ;
rel_indices =  length(path_length) + closest_ind - 20 : length(path_length) + closest_ind + 20    ;  
% plot(triple_path_length(rel_indices),'.')
% disp (num2str(length(rel_indices)))
equispaced_points(index)      =  -1 * spline(triple_path_length(rel_indices) , triple_ordered_complex_p(rel_indices) , distance_per_point*(index-1));

end %for index = 2 : no_of_points 

end % function










