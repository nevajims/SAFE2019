function draw_mesh(data_nodes,data_els,marked_nodes,numbered_els,numbered_nodes,use_tx_labels,scale,handle,view_pos,chart_title);
axes(handle);
axis auto;
zoom on;
cla;
hold on;
view(view_pos);
axis equal;
no_data_els=size(data_els,1);
no_data_nodes=size(data_nodes,1);
els_centre=zeros(size(data_els,1),3);
%first plot elements
for count=1:no_data_els;
	temp=[	data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3);
  				data_nodes(data_els(count,2),1),data_nodes(data_els(count,2),2),data_nodes(data_els(count,2),3);
         	data_nodes(data_els(count,4),1),data_nodes(data_els(count,4),2),data_nodes(data_els(count,4),3);
         	data_nodes(data_els(count,3),1),data_nodes(data_els(count,3),2),data_nodes(data_els(count,3),3);
       		data_nodes(data_els(count,1),1),data_nodes(data_els(count,1),2),data_nodes(data_els(count,1),3)];   
   plot3(temp(:,1),temp(:,2),temp(:,3),'g');
   els_centre(count,:)=mean(data_nodes(data_els(count,:),:));
end;
%plot the marked nodes
if min(marked_nodes)>0 & max(marked_nodes)<=no_data_nodes
   plot3(data_nodes(marked_nodes(:),1),data_nodes(marked_nodes(:),2),data_nodes(marked_nodes(:),3),'r.');
end;
%number the elements 
if min(numbered_els)>0 & max(numbered_els)<=no_data_els
	text(els_centre(numbered_els(:),1),els_centre(numbered_els(:),2),els_centre(numbered_els(:),3),num2str(numbered_els(:)),'r');
end;   
%number the nodes
if min(numbered_nodes)>0 & max(numbered_nodes)<=no_data_nodes
   if use_tx_labels==0
      text(data_nodes(numbered_nodes(:),1),data_nodes(numbered_nodes(:),2),data_nodes(numbered_nodes(:),3),num2str(numbered_nodes(:)));
   else
      for count=1:length(numbered_nodes)
		   t=text(data_nodes(numbered_nodes(count),1),data_nodes(numbered_nodes(count),2),data_nodes(numbered_nodes(count),3),strcat('Tx',num2str(count)));
           set(t,'HorizontalAlignment','center');
           set(t,'VerticalAlignment','bottom');
           set(t,'Color','red')
      end
   end;
   
end;

xlabel('X');
ylabel('Y');
zlabel('Z');
title(chart_title);
%axis off
return;