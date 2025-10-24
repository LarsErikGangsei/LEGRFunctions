%% --------------------------------------------------------------------- %%
% Function to crop pointclouds
%
% Author: Lars Erik Gangsei
% Date: 1th of April 2020
%


function IndPC = Crop_PC_LEG(PC,BBox)

if~exist('BBox','var');BBox = [min(PC)' max(PC)'];end

[nn,~] = size(PC);
IndPC = logical(zeros(nn,1));
%% 1) Open figure with 4 panels

fignum = figure('Units', 'normal', 'Position', [0.1 0.1 .8 .8]);

% Panels to place different figures
subgroup.dir1 = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [0 1/2 1/2 1/2]);
subgroup.dir2 = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [0 0 1/2 1/2]);
subgroup.dir3 = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [1/2 1/2 1/2 1/2]);
subgroup.show3D = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [1/2 0 1/2 1/2]);


%% 2) Plot figues.
DNames = {'dir1','dir2','dir3'};
for ii = 1:3
    Ax.(DNames{ii}) = axes(subgroup.(DNames{ii}),'Position',[0.2 0.1 0.7 0.8]);
    Ax.(DNames{ii}).Tag = DNames{ii};
   % set(Ax.(DNames{ii}),'PickableParts','none')
     %Ax.(DNames{ii}).NextPlot = 'replacechildren';
    
    %Ax.(DNames{ii}).Toolbar.Visible = 'off';
    
    % b) Intensity images and their position
    switch ii
        case 1
            Plot.dir1.Outside = plot(Ax.dir1,PC(:,2),PC(:,3),'Marker','.',...
                'MarkerFaceColor','b','LineStyle','none','Hittest','off',...
                'MarkerSize',1);
            xlim(BBox(2,:));ylim(BBox(3,:));
            hold on
            Plot.dir1.Inside = plot(Ax.dir1,PC(:,2),PC(:,3),'Marker','.',...
                'MarkerFaceColor','r','LineStyle','none','Hittest','off',...
                'MarkerSize',1,'Visible','off');
        case 2
            Plot.dir2.Outside = plot(Ax.dir2,PC(:,1),PC(:,3),'Marker','.',...
                'MarkerFaceColor','b','LineStyle','none','Hittest','off',...
                'MarkerSize',1);
                xlim(BBox(1,:));ylim(BBox(3,:));
                 hold on
            Plot.dir2.Inside = plot(Ax.dir2,PC(:,1),PC(:,3),'Marker','.',...
                'MarkerFaceColor','r','LineStyle','none','Hittest','off',...
                'MarkerSize',1,'Visible','off');
        case 3
           Plot.dir3.Outside = plot(Ax.dir3,PC(:,1),PC(:,2),'Marker','.',...
                'MarkerFaceColor','b','LineStyle','none','Hittest','off',...
                'MarkerSize',1);
            xlim(BBox(1,:));ylim(BBox(2,:));
                hold on
            Plot.dir3.Inside = plot(Ax.dir3,PC(:,1),PC(:,2),'Marker','.',...
                'MarkerFaceColor','r','LineStyle','none','Hittest','off',...
                'MarkerSize',1,'Visible','off');
    end
    
    Fhand.(DNames{ii}) = images.roi.Freehand(Ax.(DNames{ii}),...
        'Color','g','LineWidth',1,'Visible','off',...
        'close',true,'FaceAlpha',0.2,'Selected',false);
    
    PushB.Add.(DNames{ii}) = uicontrol('Style','pushbutton',...
        'Parent',subgroup.(DNames{ii}), 'Callback',@Draw_remove_roi,...
        'Units', 'normal', 'Position', [0 0.9 0.1 0.1],'Value',0,...
        'String','Add','Tag',DNames{ii});
    
    PushB.Remove.(DNames{ii}) = uicontrol('Style','pushbutton',...
        'Parent',subgroup.(DNames{ii}), 'Callback',@Draw_remove_roi,...
        'Units', 'normal', 'Position', [0 0.8 0.1 0.1],'Value',0,...
        'String','Remove','Tag',DNames{ii});
end

function Draw_remove_roi(source,~)
         dir = source.Tag;
        if source.Value ==1
            Fhand.(dir).Selected = true;
            bringToFront(Fhand.(dir));
            waitforbuttonpress
             Fhand.(dir).Visible = 'on';
            PosB = get(Ax.(dir), 'CurrentPoint');
            beginDrawingFromPoint(Fhand.(dir),PosB(1,1:2))
            source.Value = 0;
        else
            Fhand.(dir).Selected = false;
            Fhand.(dir).Visible = 'off';
        end
        
        switch dir
            case 'dir1'
                ind_tmp = inROI(Fhand.(dir),PC(:,2),PC(:,3));
            case 'dir2'
                ind_tmp = inROI(Fhand.(dir),PC(:,1),PC(:,3));
            case 'dir3'
                ind_tmp = inROI(Fhand.(dir),PC(:,1),PC(:,2));
            otherwise
        end
        switch source.String
            case 'Add'
                IndPC(ind_tmp==1)=1;
            case 'Remove'
                IndPC(ind_tmp==1)=0;                
        end
       for ii = 1:3
           switch ii
               case 1
                   XX = PC(:,2);
                   YY = PC(:,3);
               case 2
                    XX = PC(:,1);
                   YY = PC(:,3);
               case 3
                    XX = PC(:,1);
                   YY = PC(:,2);
           end
            Plot.(DNames{ii}).Inside.XData = XX(IndPC==1);
            Plot.(DNames{ii}).Inside.YData = YY(IndPC==1);
            Plot.(DNames{ii}).Outside.XData = XX(IndPC==0);
            Plot.(DNames{ii}).Outside.YData = YY(IndPC==0);
       end
       Plot.P3D.Outside.XData = PC(IndPC==0,1);
       Plot.P3D.Outside.YData = PC(IndPC==0,2);
       Plot.P3D.Outside.ZData = PC(IndPC==0,3);
       Plot.P3D.Inside.XData = PC(IndPC==1,1);
       Plot.P3D.Inside.YData = PC(IndPC==1,2);
       Plot.P3D.Inside.ZData = PC(IndPC==1,3);
       
              Plot.dir1.Inside.Visible = 'on';
        Plot.dir2.Inside.Visible = 'on';
        Plot.dir3.Inside.Visible = 'on';
        Plot.P3D.Inside.Visible = 'on';
        Fhand.(dir).Visible = 'off';
end
 

Ax.show3D = axes(subgroup.show3D,'Position',[0.1 0.1 0.8 0.8]);
    Ax.show3D.Tag = 'show3D';
    Ax.show3D.DataAspectRatio = [1 1 1];

Plot.P3D.Outside = plot3(Ax.show3D,PC(:,1),PC(:,2),PC(:,3),'Marker','.',...
                'MarkerFaceColor','b','LineStyle','none',...
                'MarkerSize',1);
            xlim(BBox(1,:));ylim(BBox(2,:));zlim(BBox(3,:));
  
            hold on
Plot.P3D.Inside = plot3(Ax.show3D,PC(:,1),PC(:,2),PC(:,3),'Marker','.',...
                'MarkerFaceColor','r','LineStyle','none','MarkerSize',1,...
                'Visible','off');
            
RadiB.showNoInd = uicontrol('Style','radiobutton',...
        'Parent',subgroup.show3D, 'Callback',@showNoInd,...
        'Units', 'normal', 'Position', [0 0.9 0.1 0.1],'Value',1,...
        'String','Show All');
    
    function showNoInd(source,~)
        if source.Value==1
            Plot.P3D.Outside.Visible = 'on';
            Plot.dir1.Outside.Visible = 'on';
            Plot.dir2.Outside.Visible = 'on';
            Plot.dir3.Outside.Visible = 'on';
        else
            Plot.P3D.Outside.Visible = 'off';
            Plot.dir1.Outside.Visible = 'off';
            Plot.dir2.Outside.Visible = 'off';
            Plot.dir3.Outside.Visible = 'off';
        end
    end
            
  waitfor(fignum)

end