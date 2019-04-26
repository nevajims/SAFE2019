% option to edit the transducer points
% display the transducer points in a ui display and on each point
%--------------------------------------------------------------------------------------------
% TYPES OF SYMMETRY
%--------------------------------------------------------------------------------------------
% (1) x axis  (e.g. rail on its side)
% the mesh can have a number of types of symmetry:
% (2) y axis  (e.g  rail)
% (3) x and y axis   (e.g. H section)
% (4) quasi - axi (e.g. octagon)
% (5) axi  (circle)
% (6) none (none of the above)
% simpler idea is to simply define the number of axis of symetry
% This should be defined , but rail is type 2 -  currently everything is written for type 2
% --------------------------------------------------------------
% angle not working properly for plot 
% --------------------------------------------------------------

%----------------------------------
% Have export and display values
%---------------------------------


%------------------------------------------------------------------------------------------------------------------
% option to load a particular set of transucer locations previously set --
% load to snap to nearet nodes for all nodes if this is what is set -  so
% go through every point and moke sure 
%------------------------------------------------------------------------------------------------------------------
% button -  export to CPP file
% put zeros in when frequency is not in range
% option to simply select the node-  toggle switch -- nodes or sub node
% precision
%---------------------------------------------------
% on hold  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
%---------------------------------------------------
% 1/ Pu a spline through 5 points 2-CP-2
% 2/ create a parametric variable- path length
% 3/ evaluate at N equispaced points
% 4/ find the closest to the point
% 5/ work out the two stradleing points get % dist (by path length from 1>2
% gpoing in a CW directin (number should always be +ve
% how can it have a Y value of NaN with everything else  there     ??????????????
% why is the distance along the length sometimes           -ve     ??????????????
% for the moment concentrate on snap on options     ----------------
% first work out why it doesnt always work (doest select the symmetrical point)
% why is it not always close
% if snap is on -  have an option to toggle (cw/acw) a particular chosen node point
% if snap is off -  have option to toggle around (cw/acw) the path length by a set
% percentage of the entire path length
% do the option for finding the closest node
% if snap on ---- only 3 values needed --  x,y and node the other two can be NAN
% -- recalculate all the interpolated to snap to the nearest value-- On hold
%-------------------------------------------------------------- -------------------------------
% exports:
% freq   / phase velocity /  Att -- always set to zero / group velocity /  then axial -z- displacement for the selected nodes
%--------------------------------------------------------------------------------------------
% button-  choose the current node which can be incremented  --  display this value beside the button (only snapped points are available)

function select_transducer_points(reshaped_proc_data)
if (nargin ~= 1) ; disp('This function requires ''reshaped_proc_data'' as an input -- terminating early'); run_prog = 0; else  run_prog = 1; end

%if isstruct(reshaped_proc_data);if length(fields(reshaped_proc_data))==7; else disp('The input structure has the wrong number of fields ',num2str( length(fields(reshaped_proc_data))));...
%run_prog = 0;end ; else disp('The input variable is not a structure ');run_prog = 0;end
run_prog = 1;

if run_prog ==1
[reshaped_proc_data , mesh_properties] = get_ordered_external_nodes(reshaped_proc_data);
default_frequency_range = [10,20,0.5];

handles.fig_handle = figure('units','normalized','outerposition',[0.05 0.05 0.9 0.9],'DeleteFcn',@DeleteFcn_callback ,'UserData',struct('reshaped_proc_data',reshaped_proc_data,'mesh_properties',mesh_properties,...
'Trans_points',NaN,'chosen_frequency',NaN,'chosen_mode',NaN,'handles',NaN,'Mirroring',1,'Plot_limits',NaN,'Modes_to_output',NaN , 'frequency_range', default_frequency_range ,'snap_on',2, 'chosen_snapped_trans',NaN,'no_2_incr',1,...
'mode_to_display',NaN,'display_points',NaN, 'display_freq',NaN ));

handles.pushbutton_1 = uicontrol('Style', 'pushbutton', 'String', 'Choose location','Position', [10 800 120 50],'Callback' , @but_func_1) ;   % select point on dispersion curve       
handles.pushbutton_2 = uicontrol('Style', 'pushbutton', 'String', 'Delete location','Position', [10 750 120 50],'Callback' , @but_func_2) ;   % select point on dispersion curve       
handles.pushbutton_9 = uicontrol('Style', 'pushbutton', 'String', 'Open configurtion file','Position', [200 800 120 50],'Callback' , @but_func_9) ;   % select point on dispersion curve       
handles.pushbutton_14 = uicontrol('Style', 'pushbutton', 'String', 'Save configurtion file','Position', [200 750 120 50],'Callback' , @but_func_14) ;   % select point on dispersion curve       

% Mode EXPORT----------------------------------------------------------------------------------------------------
handles.EXPORT_title1 = uicontrol('style','text','position',[10 410 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','EXPORT');
handles.EXPORT_modes_display = uicontrol('style','text','position',[140 340 300 50],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','None');
handles.pushbutton_3  = uicontrol('Style', 'pushbutton', 'String', 'Modes to export','Position', [10 350 120 50],'Callback'    , @but_func_3) ;   % select point on dispersion curve        

handles.pushbutton_8  = uicontrol('Style', 'pushbutton', 'String', 'To Text(C++)format','Position', [10 300 120 50],'Callback' , @but_func_8) ;   % select point on dispersion curve        

handles.pushbutton_15  = uicontrol('Style', 'pushbutton', 'String', 'To .mat format','Position', [230 300 120 50],'Callback' , @but_func_15) ;   % select point on dispersion curve        

% EXPORT---------------------------------------------------------------------------------------------------------

% Mode DISPLAY----------------------------------------------------------------------------------------------------
handles.DISPLAY_title1 = uicontrol('style','text','position',[10 250 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','DISPLAY');
handles.DISPLAY_mode   = uicontrol('style','text','position',[140 220 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','None');
handles.DISPLAY_freq   = uicontrol('style','text','position',[140 170 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','None');
handles.DISPLAY_node   = uicontrol('style','text','position',[140 120 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','None');

handles.pushbutton_10  = uicontrol('Style', 'pushbutton', 'String', 'Select mode','Position', [10 200 120 50],'Callback' , @but_func_10) ;   % select point on dispersion curve        
handles.pushbutton_11  = uicontrol('Style', 'pushbutton', 'String', 'Select Frequency','Position', [10 150 120 50],'Callback' , @but_func_11) ;   % select point on dispersion curve        
handles.pushbutton_12  = uicontrol('Style', 'pushbutton', 'String', 'Select Points','Position', [10 100 120 50],'Callback' , @but_func_12) ;   % select point on dispersion curve        
handles.pushbutton_13  = uicontrol('Style', 'pushbutton', 'String', 'Plot','Position', [230 200 120 50],'Callback' , @but_func_13) ;   % select point on dispersion curve        


% DISPLAY---------------------------------------------------------------------------------------------------------
handles.pushbutton_4 = uicontrol('Style', 'pushbutton', 'String', 'Node to increment','Position', [10 500 120 50],'Callback' , @but_func_4) ;   % select point on dispersion curve        
handles.pushbutton_5 = uicontrol('Style', 'pushbutton', 'String', 'Up'   , 'Position' , [260 525 50 20] , 'Callback' , @but_func_5) ;   % select point on dispersion curve        
handles.pushbutton_6 = uicontrol('Style', 'pushbutton', 'String', 'Down' , 'Position' , [260 500 50 20] , 'Callback' , @but_func_6) ;   % select point on dispersion curve        
handles.edit_title6  = uicontrol('style','text','position',[145 530 90 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','# to increment');
handles.edit_title7  = uicontrol('style','text','position',[15 470 90 20],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','None Selected');
handles.popup_1      =  uicontrol('Style', 'popup','String', {'1','2','3','4','5','6','7','8','9','10'},  'Position', [145 500 60 30],'Callback' , @select_no_nodes_to_increment); % select_no_nodes_to_increment
handles.edit_title1  = uicontrol('style','text','position',[10 640 150 20] , 'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','Frequency Range (KHz):');
handles.edit_title2  = uicontrol('style','text','position',[10 620 70 20]  , 'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','Minimun');
handles.edit_title3  = uicontrol('style','text','position',[80 620 70 20]  , 'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','Maximum');
handles.edit_title4  = uicontrol('style','text','position',[150 620 70 20] , 'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','Increment');
handles.edit_title5  = uicontrol('style','text','position',[220 620 70 20] , 'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String','#Increments');

handles.edit1 = uicontrol('Style', 'edit', 'String', num2str(default_frequency_range(1)),'Position', [10 600 70 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback'   , @edit_func_1) ;   % select point on dispersion curve         
handles.edit2 = uicontrol('Style', 'edit', 'String', num2str(default_frequency_range(2)),'Position', [80 600 70 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback'   , @edit_func_2) ;   % select point on dispersion curve         
handles.edit3 = uicontrol('Style', 'edit', 'String', num2str(default_frequency_range(3)),'Position', [150 600 70 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback' , @edit_func_3) ;   % select point on dispersion curve         
handles.edit4 = uicontrol('Style', 'edit', 'String', num2str((default_frequency_range(2)-default_frequency_range(1))/default_frequency_range(3)),'Position', [220 600 70 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback'  , @edit_func_4) ;   % select point on dispersion curve         

handles.tog1 = uicontrol('Style' , 'togglebutton' , 'String','Snap to nodes ','Position', [10 870 80 20],'BackgroundColor',[1 1 1],'HorizontalAlignment','left','Callback',@tog_but_1,'Value',1);   % select point on dispersion curve         
handles.tog_title1 = uicontrol('style','text','position',[100 870 80 15],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 10,'String','Snap on');
% num2str((frequency_range(2)-frequency_range(1))/frequency_range(3))

setup_figure(handles)
end  %  if run_prog ==1    
end  %  function

%------------------------------------------------------------------------------------------------------------------------------------------------------
% Callbacks
%------------------------------------------------------------------------------------------------------------------------------------------------------
function but_func_13(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end
% handles.pushbutton_12
function but_func_12(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
%------------------------------------------------------------------------------------------------------------------------------------------------------

if size(plot_data_structure.Trans_points,2)==10
snapped_points = zeros(1:size(plot_data_structure.Trans_points,1));
count = 0;

for index = 1 : size(plot_data_structure.Trans_points,1)
if sum(isnan(plot_data_structure.Trans_points(index , 4:5)))==2
count = count + 1;
snapped_points(count) = index;
end %if sum(isnan(plot_data_structure.Trans_points(index , 4:5)))==2
end %for index = 1 :size(plot_data_structure.Trans_points,1)
snapped_points = snapped_points(find(snapped_points ~=0));
strValues = strtrim(cellstr(num2str([snapped_points],'Node %d')));
%strValues = strtrim(cellstr(num2str([Trans_point_indices'],'Point %d')));

[temp_vals,ok]                            =  listdlg('PromptString','Select Node to toggle :','SelectionMode','multiple','ListString',strValues);    

if ok ==1
plot_data_structure.display_points =  snapped_points(temp_vals) ;
else    
plot_data_structure.display_points =  NaN                       ;    
end %if ok ==1
else
plot_data_structure.display_points =  NaN                       ;
end %if size(plot_data_structure.Trans_points,2)==10


if isnan(plot_data_structure.chosen_snapped_trans )
set (plot_data_structure.handles.edit_title7,'String','None Selected')

else    
    
set (plot_data_structure.handles.edit_title7,'String',['Node ',num2str(plot_data_structure.chosen_snapped_trans)])    



end %if isnan(plot_data_structure.chosen_snapped_trans )
plot_data_structure = reset_plot_axis(plot_data_structure);


set(get(hObject,'Parent'),'UserData',plot_data_structure);

%------------------------------------------------------------------------------------------------------------------------------------------------------
end

function but_func_14(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function but_func_15(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function but_func_11(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function but_func_10(hObject, ~)
plot_data_structure         =          get(get(hObject,'Parent'),'UserData')                                                             ;
strValues                   =          strtrim(cellstr(num2str([1:size(plot_data_structure.reshaped_proc_data.freq,2)]','Mode %d')))     ;
[temp_val,ok]               =          listdlg('PromptString','Select Modes to output:','SelectionMode','single','ListString',strValues) ;    

if (ok)
set(plot_data_structure.handles.DISPLAY_mode,'String',['Mode ',num2str(temp_val)])  
plot_data_structure.mode_to_display = temp_val                                        ;
set(get(hObject,'Parent'),'UserData',plot_data_structure)                             ;
end % if (ok)

end % function but_func_10(hObject, ~)

function but_func_9(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function but_func_8(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
disp('to be written')
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function tog_but_1(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
tog_text = {'Snap off','Snap on'};
new_value =  get(hObject,'Value');
set(plot_data_structure.handles.tog_title1,'String',tog_text{new_value+1}) 
plot_data_structure.snap_on = new_value + 1;
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end

function but_func_1(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
[chosen_x,chosen_y] = ginput(1) ;
plot_data_structure  =  find_positions_on_outside(plot_data_structure,chosen_x,chosen_y);
plot_data_structure = reset_plot_axis(plot_data_structure);
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end % 

function but_func_2(hObject, ~)

plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
Trans_points       = plot_data_structure.Trans_points ;

if size(Trans_points,2) == 10 
Trans_point_indices = [1:size(Trans_points,1)];
strValues = strtrim(cellstr(num2str([Trans_point_indices'],'Point %d')));
[temp_vals,ok]              =          listdlg('PromptString','Select Fenel file to convert:','SelectionMode','multiple','ListString',strValues);    

if (ok)
Trans_points(temp_vals,:) =[];
plot_data_structure.Trans_points =  Trans_points;
plot_data_structure =  reset_plot_axis(plot_data_structure);

set (plot_data_structure.handles.edit_title7,'String','None Selected')
plot_data_structure.chosen_snapped_trans =  NaN;
set(get(hObject,'Parent'),'UserData',plot_data_structure)    ;
end %if (ok)
end %if size(Trans_points,2) == 10 

end % 

function but_func_3(hObject, ~)

plot_data_structure         =          get(get(hObject,'Parent'),'UserData')                                                                ;
strValues                   =          strtrim(cellstr(num2str([1:size(plot_data_structure.reshaped_proc_data.freq,2)]','Mode %d')))        ;
[temp_vals,ok]              =          listdlg('PromptString','Select Modes to output:','SelectionMode','multiple','ListString',strValues)  ;    

if (ok)
set(plot_data_structure.handles.EXPORT_modes_display,'String',regroup_cell_string_array(cellstr(num2str(temp_vals)),10))    
plot_data_structure.Modes_to_output = temp_vals                                                                                             ;
set(get(hObject,'Parent'),'UserData',plot_data_structure)                                                                                   ;
end % if (ok)

end % function but_func_3(hObject, ~)

function but_func_4(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
% plot_data_structure.Trans_points 


if size(plot_data_structure.Trans_points,2)==10
snapped_points = zeros(1:size(plot_data_structure.Trans_points,1));
count = 0;

for index = 1 : size(plot_data_structure.Trans_points,1)
if sum(isnan(plot_data_structure.Trans_points(index , 4:5)))==2
count = count + 1;
snapped_points(count) = index;
end %if sum(isnan(plot_data_structure.Trans_points(index , 4:5)))==2
end %for index = 1 :size(plot_data_structure.Trans_points,1)
snapped_points = snapped_points(find(snapped_points ~=0));
strValues = strtrim(cellstr(num2str([snapped_points],'Node %d')));
%strValues = strtrim(cellstr(num2str([Trans_point_indices'],'Point %d')));
[temp_val,ok]                            =  listdlg('PromptString','Select Node to toggle :','SelectionMode','single','ListString',strValues);    
if ok ==1
plot_data_structure.chosen_snapped_trans =  snapped_points(temp_val);
else    
plot_data_structure.chosen_snapped_trans =  NaN;    
end %if ok ==1
else
plot_data_structure.chosen_snapped_trans =  NaN;
end %if size(plot_data_structure.Trans_points,2)==10

if isnan(plot_data_structure.chosen_snapped_trans )
set (plot_data_structure.handles.edit_title7,'String','None Selected')
else    
set (plot_data_structure.handles.edit_title7,'String',['Node ',num2str(plot_data_structure.chosen_snapped_trans)])    
end %if isnan(plot_data_structure.chosen_snapped_trans )
plot_data_structure = reset_plot_axis(plot_data_structure);
set(get(hObject,'Parent'),'UserData',plot_data_structure);

end %function but_func_4(hObject, ~)

function but_func_5(hObject, ~)

plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
% up button
if ~isnan(plot_data_structure.chosen_snapped_trans)

node_positions        = plot_data_structure.reshaped_proc_data.mesh.nd.pos                                 ;
chosen_trans_array     =  plot_data_structure.Trans_points(plot_data_structure.chosen_snapped_trans,: )    ;
original_node_number   =  chosen_trans_array(3)                                                            ;
outside_node_list      =  plot_data_structure.mesh_properties.ordered_node_lists{1}                        ;
initial_index_in_external = find(outside_node_list == original_node_number)                                ;
no_2_incr              = plot_data_structure.no_2_incr                                                     ;

temp_new_index = initial_index_in_external + no_2_incr;

if temp_new_index > length(outside_node_list)
temp_new_index =  length(outside_node_list)- temp_new_index ;
end

if node_positions(outside_node_list(temp_new_index),1)  >  0
point_array_1        =   [node_positions(outside_node_list(temp_new_index) ,1),node_positions(outside_node_list(temp_new_index),2),outside_node_list(temp_new_index),NaN,NaN]                          ;
point_array_2        =   get_single_location(plot_data_structure , -node_positions(outside_node_list(temp_new_index),1) , node_positions(outside_node_list(temp_new_index),2),2);
total_point_array    =   [point_array_1,point_array_2]                                                                                        ;    
plot_data_structure.Trans_points(plot_data_structure.chosen_snapped_trans,:)    =   total_point_array ;
else
% do nothing as its out of range    
end    % if node_positions(temp_new_index,1) > 0    

plot_data_structure =  reset_plot_axis(plot_data_structure);
end %if ~isnan(plot_data_structure.chosen_snapped_trans)     
set(get(hObject,'Parent'),'UserData',plot_data_structure);

end %function but_func_4(hObject, ~)

function but_func_6(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
% up button
if ~isnan(plot_data_structure.chosen_snapped_trans)
node_positions        = plot_data_structure.reshaped_proc_data.mesh.nd.pos                                 ;
chosen_trans_array     =  plot_data_structure.Trans_points(plot_data_structure.chosen_snapped_trans,: )    ;
original_node_number   =  chosen_trans_array(3)                                                            ;
outside_node_list      =  plot_data_structure.mesh_properties.ordered_node_lists{1}                        ;
initial_index_in_external = find(outside_node_list == original_node_number)                                ;
no_2_incr              = plot_data_structure.no_2_incr                                                     ;
temp_new_index = initial_index_in_external - no_2_incr;
if temp_new_index < 1
temp_new_index =  length(outside_node_list) + temp_new_index;
end

if node_positions(outside_node_list(temp_new_index),1)  >  0
point_array_1        =   [node_positions(outside_node_list(temp_new_index) ,1),node_positions(outside_node_list(temp_new_index),2),outside_node_list(temp_new_index),NaN,NaN]                          ;
point_array_2        =   get_single_location(plot_data_structure , -node_positions(outside_node_list(temp_new_index),1) , node_positions(outside_node_list(temp_new_index),2),2);
total_point_array    =   [point_array_1,point_array_2]                                                                                        ;    
plot_data_structure.Trans_points(plot_data_structure.chosen_snapped_trans,:)    =   total_point_array ;
else

end    % if node_positions(temp_new_index,1) > 0    

plot_data_structure =  reset_plot_axis(plot_data_structure);
end %if ~isnan(plot_data_structure.chosen_snapped_trans)     

set(get(hObject,'Parent'),'UserData',plot_data_structure);

end %function but_func_4(hObject, ~)

function select_no_nodes_to_increment(hObject, ~)
plot_data_structure            =    get(get(hObject,'Parent'),'UserData')   ;
plot_data_structure.no_2_incr  =    get(hObject,'Value')                    ;
set(get(hObject,'Parent'),'UserData',plot_data_structure);
end %function but_func_4(hObject, ~)

function edit_func_1(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

frequency_range = plot_data_structure.frequency_range;
temp_value_string  =    get(hObject,'String');
no_increments = (frequency_range(2)-frequency_range(1))/frequency_range(3); 

if length(str2num(temp_value_string))~= 0
new_value_num = str2num(temp_value_string);
if new_value_num >= 0 && new_value_num < frequency_range(2)
set( hObject,'String',  temp_value_string )         
plot_data_structure.frequency_range(1) = new_value_num; 
plot_data_structure.frequency_range(3) =  (plot_data_structure.frequency_range(2) - plot_data_structure.frequency_range(1))/no_increments;

set(plot_data_structure.handles.edit3,'String', num2str(plot_data_structure.frequency_range(3)))         

set(get(hObject,'Parent'),'UserData',plot_data_structure);
else
set( hObject,'String',   num2str(frequency_range(1)) )     
end %if new_value_num >= 0 && new_value_num < frequency_range(2)

else
set( hObject,'String',num2str(frequency_range(1)) )     
end

end % select minimum frequency (kHz)

function edit_func_2(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');
% must be < total max freq  and more than selected minimum
frequency_range = plot_data_structure.frequency_range;
temp_value_string  =    get(hObject,'String');
max_freq_value = max(max(plot_data_structure.reshaped_proc_data.freq))/1E3;
no_increments = (frequency_range(2)-frequency_range(1))/frequency_range(3); 

if length(str2num(temp_value_string))~= 0
new_value_num =   str2num(temp_value_string);
if new_value_num > frequency_range(1) && new_value_num < max_freq_value
set (hObject,'String',  temp_value_string)         
plot_data_structure.frequency_range(2) = new_value_num; 

plot_data_structure.frequency_range(3) =  (plot_data_structure.frequency_range(2) - plot_data_structure.frequency_range(1))/no_increments;
set (plot_data_structure.handles.edit3,'String', num2str(plot_data_structure.frequency_range(3)))         

set (get(hObject,'Parent'),'UserData',plot_data_structure);


else
set(hObject,'String', num2str(frequency_range(2)))     

end %if new_value_num >= 0 && new_value_num < frequency_range(2)

else
    
set(hObject,'String',num2str(frequency_range(2)))     
end

end % select minimum frequency (kHz)

function edit_func_3(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

frequency_range = plot_data_structure.frequency_range;
temp_value_string  =    get(hObject,'String');


if length(str2num(temp_value_string))~= 0
new_value_num =   str2num(temp_value_string);

if new_value_num <= frequency_range(2) - frequency_range(1)&& new_value_num > 0
    
rounded_no_increments = round((frequency_range(2)-frequency_range(1))/new_value_num);     
corrected_increment  = (frequency_range(2)-frequency_range(1))/rounded_no_increments;
set( hObject,'String',num2str(corrected_increment));
set( plot_data_structure.handles.edit4,'String',num2str(rounded_no_increments));

plot_data_structure.frequency_range(3) = corrected_increment;
set(get(hObject,'Parent'),'UserData',plot_data_structure);

else    
set( hObject,'String',num2str((frequency_range(3))))         
end
    
else
set( hObject,'String',num2str((frequency_range(3))))     
end
end % select frequency increment (kHz)

function edit_func_4(hObject, ~)
plot_data_structure  =  get(get(hObject,'Parent'),'UserData');

frequency_range = plot_data_structure.frequency_range;
temp_value_string  =    get(hObject,'String');
old_increment = (frequency_range(2)-frequency_range(1))/frequency_range(3);


if length(str2num(temp_value_string))~= 0
new_value_num =   str2num(temp_value_string);
rounded_no_increments = round(new_value_num);

if new_value_num  >= 1
    
corrected_increment  =  (frequency_range(2)-frequency_range(1))/rounded_no_increments;
set( hObject,'String',num2str(rounded_no_increments));
set( plot_data_structure.handles.edit3,'String',num2str(corrected_increment));
plot_data_structure.frequency_range(3) = corrected_increment;
set(get(hObject,'Parent'),'UserData',plot_data_structure);
    
else    
set( hObject,'String',num2str(old_increment))         
end

else
set( hObject,'String',num2str((old_increment)))     
end

end % select number of increments

function DeleteFcn_callback(object_handle,~)
plot_data_structure = get(object_handle,'UserData');
delete(plot_data_structure.handles.fig_handle) 
end  % function Deletes any animation timer object that may exist at the time of closing the figure

%------------------------------------------------------------------------------------------------------------------------------------------------------
% Callbacks
%------------------------------------------------------------------------------------------------------------------------------------------------------

function plot_data_structure  =  find_positions_on_outside(plot_data_structure,chosen_x,chosen_y)
Plot_limits           = plot_data_structure.Plot_limits                           ;

if chosen_x > Plot_limits(1,1) && chosen_x < Plot_limits(1,2) && chosen_y > Plot_limits(2,1) && chosen_y < Plot_limits(2,2)
   
point_array =   get_single_location(plot_data_structure , chosen_x , chosen_y,plot_data_structure.snap_on);

if length(point_array) ==5
if plot_data_structure.Mirroring  == 1
    
point_array_2 =   get_single_location(plot_data_structure , -point_array(1) , point_array(2),plot_data_structure.snap_on);

if length (point_array_2) == 1
point_array_2 = NaN(1,5) ;       
disp( 'problem with mirroring' )
end

else
point_array_2 = NaN(1,5) ;
disp( 'mirroring off' )
end

if chosen_x > 0
total_point_array = [point_array,point_array_2];    
else
total_point_array = [point_array_2,point_array];        
end %if chosen_x > 0

Trans_points = plot_data_structure.Trans_points;

if size(Trans_points,2) ==10
Trans_points(size(Trans_points,1)+1,:) = total_point_array;

else
Trans_points = total_point_array;    

end %if size(Trans_points,2) ==10
plot_data_structure.Trans_points = Trans_points;

else
% dont do anything because the pointer is out of range

end% if length(point_array) ==5

else
% do nothing
disp('chosen point is out of range') 

end %if chosen_x > Plot_limits(1,1) && chosen_x < Plot_limits(1,2) && chosen_y > Plot_limits(2,1) && chosen_y < Plot_limits(2,2)


end %function plot_data_structure  =  find_position_on_outside(plot_data_structure,chosen_x,chosen_y)

function point_array  =   get_single_location(plot_data_structure , chosen_x , chosen_y, snap_on) 

outside_node_indices  = plot_data_structure.mesh_properties.ordered_node_lists{1}   ;
node_positions        = plot_data_structure.reshaped_proc_data.mesh.nd.pos          ;
Plot_limits           = plot_data_structure.Plot_limits                             ;

% two options here- snap on and snap off-  work on snap on for now
% keep the stuff that is common before the switch

distance_to_nodes = zeros(size(outside_node_indices));
for index = 1:length (outside_node_indices)
distance_to_nodes(index) =   sqrt((chosen_x -  node_positions(outside_node_indices(index),1))^2  + (chosen_y -  node_positions(outside_node_indices(index),2))^2 );
end %for index = 1:length (outside_node_indices)

[min_dist, temp_index]   =  min(distance_to_nodes);
distance_to_nodes_index =  1:length(distance_to_nodes);

[min_dist_2,~] = min(distance_to_nodes(find(distance_to_nodes_index~=temp_index)));
temp_index_2 = find(distance_to_nodes == min_dist_2 )                             ;
min_index = outside_node_indices(temp_index)                                      ;
min_index_2 = outside_node_indices(temp_index_2)                                  ;

if min_dist < plot_data_structure.mesh_properties.mesh_stats.mean_len * 3
    
switch(snap_on)
    
case (2) %  i.e. snap on   
% simply take the closest node and snap to it set the array as [x , y , node_no , NaN , NaN]
x_on_node =  node_positions(min_index,1) ;
y_on_node =  node_positions(min_index,2) ; 
point_array  =  [x_on_node,y_on_node,min_index,NaN,NaN];


case (1)  % i.e. snap off    
temp_point_array  = [-1,-1,min_index,min_index_2,-1];  % the -1 values are simply placemarkers and are not used

[edge_angle] = get_angle(plot_data_structure,temp_point_array);

pt1_x = node_positions(min_index  ,1);
pt1_y = node_positions(min_index  ,2);
pt2_x = node_positions(min_index_2,1);
pt2_y = node_positions(min_index_2,2);

disp(num2str(edge_angle))
disp(['*',num2str(pt1_x),'*', num2str(pt1_y),'*',num2str(pt2_x),'*', num2str(pt2_y),'*cx',num2str(chosen_x),'*cy',num2str(chosen_y)])

if edge_angle <= 45
x_on_edge = chosen_x;
if pt1_y ~= pt2_y
y_on_edge = interp1([pt1_x,pt2_x],[pt1_y,pt2_y] , x_on_edge);
if isnan(y_on_edge)
disp('problem with interp (<= 45)')
end

else
y_on_edge = pt1_y;
end
fraction_along_length  =   (pt1_x-x_on_edge)/(pt1_x-pt2_x);

else
y_on_edge = chosen_y;
if pt1_x ~= pt2_x
x_on_edge = interp1([pt1_y,pt2_y],[pt1_x,pt2_x] , y_on_edge);
if isnan(x_on_edge)
disp('problem with interp (> 45)')
end

else
x_on_edge = pt1_x;    
end
fraction_along_length  =   (pt1_y-y_on_edge)/(pt1_y-pt2_y);
end %if edge_angle <= 45

%disp(['fraction along length = ', num2str(fraction_along_length)])
point_array  =  [x_on_edge,y_on_edge,min_index,min_index_2,fraction_along_length];

end   %switch(snap_on)
else    
   
point_array  =  NaN;
disp('not close enough to mesh')    
end
end %function point_array =   get single location(plot_data_structure , chosen_x , chosen_y)

function [edge_angle] = get_angle(plot_data_structure,point_array)

% two options  =    snap on and snap off 
% point_array  =    only index   3 (snap on) or 3,4  (snap off) are used in the point array
node_positions      =  plot_data_structure.reshaped_proc_data.mesh.nd.pos         ;          %  node positions  ;
ordered_node_list   =  plot_data_structure.mesh_properties.ordered_node_lists{1}  ;          %  cell structure where the first is the external-  assume the format is correct for now  ;

if sum(isnan(point_array (4:5))) == 2
point_snap_on = 2;
elseif sum(isnan(point_array (4:5))) == 0        
point_snap_on = 1;    
else
disp('This point does not appear to have the correct format for (i.e. either snap on or snap off)')  
end % if sum(isnan(point_array (4:5))) == 2

switch(point_snap_on)
    
     case(2)
         
%disp('in snap on mode')
index_in_outside_nodes = find(ordered_node_list == point_array(3));
if index_in_outside_nodes == 1                                
pt1_index =   ordered_node_list(length(ordered_node_list)) ;
pt2_index =   ordered_node_list(index_in_outside_nodes +1 ) ;
elseif index_in_outside_nodes == length(ordered_node_list)
pt1_index =   ordered_node_list(index_in_outside_nodes -1 ) ;
pt2_index =   ordered_node_list(1) ;
else
pt1_index =   ordered_node_list(index_in_outside_nodes - 1) ;
pt2_index =   ordered_node_list(index_in_outside_nodes + 1) ;
end %if index_in_outside_nodes == 1                            ;    

pt1_x     =  node_positions(pt1_index,1);
pt1_y     =  node_positions(pt1_index,2);
pt2_x     =  node_positions(pt2_index,1);
pt2_y     =  node_positions(pt2_index,2);
if (pt2_x - pt1_x)~=0;edge_angle =abs(180/pi * atan((pt2_y - pt1_y)/(pt2_x - pt1_x)));else edge_angle = 90; end

    case(1)
        
%disp('in snap off mode')
pt1_x = node_positions(point_array(3),1);
pt1_y = node_positions(point_array(3),2);
pt2_x = node_positions(point_array(4),1);
pt2_y = node_positions(point_array(4),2);
if (pt2_x - pt1_x)~=0;edge_angle =abs(180/pi * atan((pt2_y - pt1_y)/(pt2_x - pt1_x)));else edge_angle = 90; end

end %switch(snap_on)

end %function [edge_angle] = get_angle(plot_data_structure)

function setup_figure(handles)
plot_data_structure                         = get(handles.fig_handle,'UserData');
handles.Trans_TextBox = NaN;

plot_data_structure.handles = handles;
plot_data_structure =  reset_plot_axis(plot_data_structure)  ;
set(handles.fig_handle,'UserData',plot_data_structure)       ;
end %function setup_figure(handles)

function plot_data_structure = reset_plot_axis(plot_data_structure)
Trans_points       = plot_data_structure.Trans_points ;
mesh_properties    = plot_data_structure.mesh_properties;
reshaped_proc_data = plot_data_structure.reshaped_proc_data;

node_positions    = plot_data_structure.reshaped_proc_data.mesh.nd.pos        ;

plot_data_structure = get_Plot_limits (plot_data_structure);
figure(plot_data_structure.handles.fig_handle) 
cla
hold on
axis equal
for index = 1: length(mesh_properties.ordered_node_lists)
plot(reshaped_proc_data.mesh.nd.pos(mesh_properties.ordered_node_lists{index},1),reshaped_proc_data.mesh.nd.pos(mesh_properties.ordered_node_lists{index},2),'.')
end %for index = 1: length(mesh_properties.ordered_node_lists)
xlabel('mm')
ylabel('mm')

xlim(plot_data_structure.Plot_limits(1,:))
ylim(plot_data_structure.Plot_limits(2,:))
plot(mesh_properties.COA(1),mesh_properties.COA(2),'r+','markersize',20)
plot(mesh_properties.COA(1),mesh_properties.COA(2),'ro','markersize',10)
plot([ mesh_properties.COA(1),mesh_properties.COA(1)],[plot_data_structure.Plot_limits(2,1),plot_data_structure.Plot_limits(2,2)],':') 
range_ =  plot_data_structure.Plot_limits(1,2) - plot_data_structure.Plot_limits(1,1);

if isobject(plot_data_structure.handles.Trans_TextBox)
delete(plot_data_structure.Trans_TextBox)
end %if isobject(plot_data_structure.mesh_convergence_TextBox)

if size(Trans_points,2) == 10 
text_box_temp{1} = 'Transducer locations:'  ;
text_box_temp{2} = ''                       ;

% ------------------------------------------------------------------------------------------------------------
% ------------------------------------------------------------------------------------------------------------

for index = 1 : size(Trans_points,1)
              
    
if  ~isnan(Trans_points(index,1))
    
if isnan(plot_data_structure.chosen_snapped_trans)
plot (Trans_points(index,1),Trans_points(index,2),'co','markersize', 8,'MarkerFaceColor','g','MarkerEdgeColor','g')
plot (Trans_points(index,1),Trans_points(index,2),'r+','markersize', 12)
else
   
if plot_data_structure.chosen_snapped_trans ==  index  
plot (Trans_points(index,1),Trans_points(index,2),'co','markersize', 8,'MarkerFaceColor','y','MarkerEdgeColor','y')
plot (Trans_points(index,1),Trans_points(index,2),'r+','markersize', 12)
   
else
plot (Trans_points(index,1),Trans_points(index,2),'co','markersize', 8,'MarkerFaceColor','g','MarkerEdgeColor','g')
plot (Trans_points(index,1),Trans_points(index,2),'r+','markersize', 12)
   
end
    
    
    
    
end %if isnan(plot_data_structure.chosen_snapped_trans)

%[edge_angle,~,~,~,~] = get_angle(node_positions,Trans_points(index,3),Trans_points(index,4));
[edge_angle] = get_angle(plot_data_structure , Trans_points(index,1:5));

if edge_angle > 45
text(Trans_points(index,1)+range_ /30,Trans_points(index,2),[num2str(index),'a'])
else
text(Trans_points(index,1)-range_ /120,Trans_points(index,2)+range_ /30,[num2str(index),'a'])
end %if edge_angle < 45

% combine left and right into a loop and half the code

if sum(isnan(Trans_points(index,4:5))) == 2
    
interp_text    =  '' ;

elseif sum(isnan(Trans_points(index,4:5))) == 0
    
interp_text    =  [',',num2str(Trans_points(index,4)),', ' , num2str( round(Trans_points(index,5)*100)/100)];

else
    
disp('point array format seemms to be non standard (i.e. either snap on or snap off) ' )
interp_text  = '*ERROR*';
end %if sum(isnan(point_array (4:5))) == 2



text_box_temp_1 = [num2str(index), 'a: (x,y): (',num2str(  round(Trans_points(index,1)*100)/100  ), ',',num2str(round(Trans_points(index,2)*100)/100),...
    '),(' , num2str(Trans_points(index,3)),interp_text,')'];

else
text_box_temp_1 = '';

end %if  ~isnan(Trans_points(index,1))
if  ~isnan(Trans_points(index,6))
    
    
    
if isnan(plot_data_structure.chosen_snapped_trans)
plot (Trans_points(index,6),Trans_points(index,7),'co','markersize', 8,'MarkerFaceColor','g','MarkerEdgeColor','g')
plot (Trans_points(index,6),Trans_points(index,7),'r+','markersize', 12)
else
   
if plot_data_structure.chosen_snapped_trans ==  index  
plot (Trans_points(index,6),Trans_points(index,7),'co','markersize', 8,'MarkerFaceColor','y','MarkerEdgeColor','y')
plot (Trans_points(index,6),Trans_points(index,7),'r+','markersize', 12)
   
else
plot (Trans_points(index,6),Trans_points(index,7),'co','markersize', 8,'MarkerFaceColor','g','MarkerEdgeColor','g')
plot (Trans_points(index,6),Trans_points(index,7),'r+','markersize', 12)
   
end
end


%[edge_angle,~,~,~,~] = get_angle(node_positions,Trans_points(index,8),Trans_points(index,9));
[edge_angle] = get_angle(plot_data_structure , Trans_points(index,6:10));

if edge_angle > 45
text (Trans_points(index,6)-range_ /17,Trans_points(index,7),[num2str(index),'b'])
else
text (Trans_points(index,6)-range_ /120,Trans_points(index,7)+range_ /30,[num2str(index),'b'])
end %if edge_angle < 45

if sum(isnan(Trans_points(index,9:10))) == 2
interp_text    =  '' ;
elseif sum(isnan(Trans_points(index,9:10))) == 0
interp_text    =  [',',num2str(Trans_points(index,4)),', ' , num2str( round(Trans_points(index,5)*100)/100)];
else
disp('point array format seemms to be non standard (i.e. either snap on or snap off) ' )
interp_text  = '*ERROR*';
end %if sum(isnan(point_array (4:5))) == 2

text_box_temp_2 = [' b: (x,y):',num2str(  round(Trans_points(index,6)*100)/100  ), ',',num2str(round(Trans_points(index,7)*100)/100),...
    '),(' , num2str(Trans_points(index,8)),interp_text,').'];
else
text_box_temp_2 ='';

end %if  ~isnan(Trans_points(index,6))


text_box_temp{index+2} = [text_box_temp_1,text_box_temp_2]; 
end %for index = 1 : size(Trans_points,1)
% split this into two textboxes   --------------

plot_data_structure.handles.Trans_TextBox = uicontrol('style','text','position',[1220 410 520 430],'BackgroundColor',[0.8 0.8 0.8],'HorizontalAlignment','left','FontSize', 9,'String',text_box_temp);
%set(Trans_TextBox,'position',[1250 410 450 430])
%set(Trans_TextBox,'BackgroundColor',[0.8 0.8 0.8])
%set(Trans_TextBox,'HorizontalAlignment','left')
%set(Trans_TextBox,'FontSize', 9)
%set(Trans_TextBox,'String',text_box_temp);                      
%plot_data_structure.handles.Trans_TextBox = Trans_TextBox;
end %if size(Trans_points,2) == 10 

end % function plot_data_structure = reset_plot_axis(plot_data_structure)

function plot_data_structure = get_Plot_limits (plot_data_structure)

node_positions = plot_data_structure.reshaped_proc_data.mesh.nd.pos;
max_x = max(node_positions(:,1));
min_x = min(node_positions(:,1));
max_y = max(node_positions(:,2));
min_y = min(node_positions(:,2));
range_x = max_x-min_x;
range_y = max_y-min_y;

Plot_limits(1,:) = [min_x - range_x *0.05  max_x + range_x * 0.05];
Plot_limits(2,:) = [min_y - range_y *0.05  max_y + range_y * 0.05];

plot_data_structure.Plot_limits = Plot_limits;
end %function plot_data_structure = get_Plot_limits (plot_data_structure);

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

%------------------------------------------------------------------------------------------------------------------------------------------------
% mesh outside edge points
%------------------------------------------------------------------------------------------------------------------------------------------------
function [reshaped_proc_data , mesh_properties]           = get_ordered_external_nodes(reshaped_proc_data)
% function [ordered_node_lists, COA] = get_ordered_external_nodes(mesh) 

mesh                                     = reshaped_proc_data.mesh;

edge_list                                =  get_edge_list(mesh.el.nds)                                                                                         ;  
outside_edge_list                        =  get_inside_and_outside_edges(edge_list,mesh.el.nds)                                                                ;   
node_lists                               =  find_connected_lists(outside_edge_list)                                                                            ;
ordered_node_lists                       =  organise_node_list(node_lists,mesh.nd.pos)                                                                         ;
mesh_properties.COA                      =  [round(mean(mesh.nd.pos(ordered_node_lists{1},1))*1E9)/1E9 round(mean(mesh.nd.pos(ordered_node_lists{1},2)))/1E9]  ;

mesh_properties.ordered_node_lists       =  ordered_node_lists;

reshaped_proc_data.mesh.nd.pos           = reshaped_proc_data.mesh.nd.pos * 1000;

mesh_properties.COA                      =  mesh_properties.COA * 1000;
mesh_properties.COA(2)                   =  mesh_properties.COA(2)-min(reshaped_proc_data.mesh.nd.pos(:,2));

reshaped_proc_data.mesh.nd.pos(:,2)      = reshaped_proc_data.mesh.nd.pos(:,2)-min(reshaped_proc_data.mesh.nd.pos(:,2));
[mesh_stats]                             = get_mesh_stats(reshaped_proc_data.mesh);

mesh_properties.mesh_stats               = mesh_stats ;

end % function results = get_ordered_external_nodes(mesh)

function edge_list                                        = get_edge_list(element_nodes)
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

function [outside_edge_list]                              = get_inside_and_outside_edges(edge_list,element_nodes)

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

function node_list                                        = find_connected_lists(external_edge_list)
 
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

if  next_index_temp ~= 1        %should have a single value 
ordered_edge_list_t(ordered_edge_counter + 1,:) = current_external_edge_list(next_index_temp,:);
else    
back_at_start = 1;    
end %if  next_index_temp ~= 1

end %while back_at_start ==0

node_list{linked_edge_counter} = ordered_edge_list_t(find(ordered_edge_list_t(:,1)~=0),1);

current_external_edge_list(in_index,:) = [];  % removed the edges that have been used in this linked edge

end  %while total_node_count <= length(results.external_edge_list)
end %function

function [ordered_node_lists]                             = organise_node_list(node_lists,node_pos)
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



%***DONE 0ption to increment snapped points up or down
%***DONE 
%***DONE display the modes to export


