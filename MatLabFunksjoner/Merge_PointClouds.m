%% --------------------------------------------------------------------- %%
% Function to merge PointClouds
%
% Author: Lars Erik Gangsei
% Date: ver1: 23th of mars 2020
%       ver2: 16th of june 2020
%
% Innput:
%       - PCs: a structure with pointclouds and possibly meshes
%       - Parts (optional): names on Parts to be shown
%
% Output:
%       - PCs: the same structure, but with new position for points
%       (vertices)

function PC_out = Merge_PointClouds(PCs,Parts)
PC_org = PCs;

if ~exist('Parts','var')
    Parts = fieldnames(PCs);
end
mm = length(Parts);
CMat = distinguishable_colors(mm);

%% 1) Open figure with 4 panels

fignum = figure('Units', 'normal', 'Position', [0.1 0.1 .8 .8]);

% Panels to place different figures
subgroup.Active = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [0 0 1/6 1]);
subgroup.Control = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [1/6 0 1/6 1]);
subgroup.show3D = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [1/3 0 2/3 1]);
Ax.show3D = axes(subgroup.show3D,'Position',[0 0 1 1]);
hold(Ax.show3D,'on')
axis(Ax.show3D,'image')


%% 2) Plot figues.
for ii = 1:length(Parts)
    subgroup.slider.(Parts{ii}) = uipanel('Parent', subgroup.Active,...
        'Units', 'normal','Position', [0 (mm-ii)/mm 1 1/mm]);
    RadioB.Active.(Parts{ii}) = uicontrol('Style','radiobutton',...
        'Parent',subgroup.slider.(Parts{ii}),...% 'Callback',@ActivePC,...
        'Units', 'normal', 'Position', [0 0 0.1 1],'Value',0,...
        'String','','Tag',Parts{ii},'BackgroundColor',CMat(ii,:));
    
    Slider.text.(Parts{ii}) = uicontrol('Style','text',...
        'Parent',subgroup.slider.(Parts{ii}),...
        'Units', 'normal', 'Position', [0.1 3/5 0.9 2/5],...
        'String',Parts{ii},'Tag',Parts{ii},'BackgroundColor',CMat(ii,:),...
        'ForegroundColor',[1 1 1]-CMat(ii,:),'FontSize',14);
    
    
    Slider.PointSize.(Parts{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.slider.(Parts{ii}), 'Callback',@PointSize_adj,...
        'Units', 'normal', 'Position', [0.1 2/5 0.9 1/5],'Value',6,...
        'String','Vert','Tag',Parts{ii},'Min',0,'Max',20);
    
    if isfield(PCs.(Parts{ii}),'faces');tenab='on';else;tenab = 'off';end
    
    Slider.Transparency.(Parts{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.slider.(Parts{ii}), 'Callback',@PointSize_adj,...
        'Units', 'normal', 'Position', [0.1 1/5 0.9 1/5],'Value',0.5,...
        'String','SurfPl','Tag',Parts{ii},'Enable',tenab,'Min',0,'Max',1);
    
    Slider.PointSizeMP_F.(Parts{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.slider.(Parts{ii}), 'Callback',@PointSize_adj,...
        'Units', 'normal', 'Position', [0.1 0 0.9 1/5],'Value',0.5,...
        'String','MP_F','Tag',Parts{ii},'Enable',tenab,'Min',0,'Max',20);
    
    Plo.(Parts{ii}) = plot3(Ax.show3D,PCs.(Parts{ii}).vertices(:,1),...
        PCs.(Parts{ii}).vertices(:,2),PCs.(Parts{ii}).vertices(:,3),...
        'MarkerSize',Slider.PointSize.(Parts{ii}).Value,...
        'MarkerFaceColor',CMat(ii,:),'MarkerEdgeColor',CMat(ii,:),...
        'LineStyle','none','Marker','.');
    
    if isfield(PCs.(Parts{ii}),'faces')
        SurfPl.(Parts{ii}) = patch(Ax.show3D,'Vertices',PCs.(Parts{ii}).vertices,...
            'Faces',PCs.(Parts{ii}).faces,'FaceAlpha',...
            Slider.Transparency.(Parts{ii}).Value,...
            'FaceColor',CMat(ii,:));
        
        MP_F.(Parts{ii}) = FaceMP_calc(PCs.(Parts{ii}).vertices,PCs.(Parts{ii}).faces);
        MP_FPlot.(Parts{ii}) = plot3(Ax.show3D,MP_F.(Parts{ii})(:,1),...
            MP_F.(Parts{ii})(:,2),MP_F.(Parts{ii})(:,3),...
            'MarkerSize',Slider.PointSizeMP_F.(Parts{ii}).Value,...
            'MarkerFaceColor',CMat(ii,:),'MarkerEdgeColor','k',...
            'LineStyle','none','Marker','o');
    end
end

    function MP = FaceMP_calc(VV,FF)
        MP = zeros(size(FF));
        for ll = 1:size(FF,1)
            MP(ll,:) = mean(VV(FF(ll,:),:));
        end
    end

    function PointSize_adj(source,~)
        switch source.String
            case 'Vert'
                if round(source.Value)==0
                    Plo.(source.Tag).Visible ='off';
                else
                    Plo.(source.Tag).Visible ='on';
                    Plo.(source.Tag).MarkerSize = round(source.Value);
                end
            case 'MP_F'
                if round(source.Value)==0
                    MP_FPlot.(source.Tag).Visible ='off';
                else
                    MP_FPlot.(source.Tag).Visible ='on';
                    MP_FPlot.(source.Tag).MarkerSize = round(source.Value);
                end
            case 'SurfPl'
                if source.Value <0.05
                    SurfPl.(source.Tag).Visible ='off';
                    MP_FPlot.(source.Tag).Visible ='off';
                else
                    SurfPl.(source.Tag).Visible ='on';
                    SurfPl.(source.Tag).FaceAlpha=source.Value;
                end
            otherwise
        end
    end

%% 3) Transformasjons - funksjoner.
% Flip
subgroup.Flip = uipanel('Parent', subgroup.Control, 'Units', 'normal', ...
    'Position', [0 9/10 1 1/10]);

PushB.Flip.Text = uicontrol('Style','text',...
    'Parent',subgroup.Flip,...
    'Units', 'normal', 'Position', [0 1/2 1 1/2],...
    'String','Flip Active PointClouds','BackgroundColor','g',...
    'FontSize',14);

% Move
subgroup.Move = uipanel('Parent', subgroup.Control, 'Units', 'normal', ...
    'Position', [0 13/20 1 2/10]);

Slider.Move.Text = uicontrol('Style','text',...
    'Parent',subgroup.Move,...
    'Units', 'normal', 'Position', [0 3/4 1/2 1/4],...
    'String','Move Active PointClouds','BackgroundColor','g',...
    'FontSize',14);

PushB.Move.Reset = uicontrol('Style','pushbutton',...
    'Parent',subgroup.Move,...
    'Units', 'normal', 'Position', [1/2 3/4 1/2 1/4],...
    'String','Reset','BackgroundColor','r',...
    'FontSize',14,'Callback',@ResetSliders);

% Rotate
subgroup.Rot = uipanel('Parent', subgroup.Control, 'Units', 'normal', ...
    'Position', [0 4/10 1 2/10]);

Slider.Rot.Text = uicontrol('Style','text',...
    'Parent',subgroup.Rot,...
    'Units', 'normal', 'Position', [0 3/4 1/2 1/4],...
    'String','Rotate Active PointClouds','BackgroundColor','g',...
    'FontSize',12);

PushB.Rot.Reset = uicontrol('Style','pushbutton',...
    'Parent',subgroup.Rot,...
    'Units', 'normal', 'Position', [1/2 3/4 1/2 1/4],...
    'String','Reset','BackgroundColor','r',...
    'FontSize',14,'Callback',@ResetSliders);


    function ResetSliders(~,~)
        for jj = 1:length(Parts)
            if RadioB.Active.(Parts{jj}).Value==1
                PCs.(Parts{jj}).vertices(:,1) = Plo.(Parts{jj}).XData;
                PCs.(Parts{jj}).vertices(:,2) = Plo.(Parts{jj}).YData;
                PCs.(Parts{jj}).vertices(:,3) = Plo.(Parts{jj}).ZData;
            end
        end
        
        for ii = 1:length(Directions)
            Slider.movePC.(Directions{ii}).Value = 0;
            Slider.rotPC.(Directions{ii}).Value = 0;
        end
        PushB.Move.Reset.Value = 0;
        Rot_mat_x = eye(3);
        Rot_mat_y = eye(3);
        Rot_mat_z = eye(3);
    end


Directions = {'X','Y','Z'};
for ii= 1:length(Directions)
    PushB.Flip.(Directions{ii}) = uicontrol('Style','pushbutton',...
        'Parent',subgroup.Flip,'Callback',@FlipPC,...
        'Units', 'normal', 'Position', [(ii-1)/3 0 1/3 1/2],'Value',0,...
        'String',Directions{ii});
    
    Slider.movePC.(Directions{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.Move, 'Callback',@PoinCloudMove,...
        'Units', 'normal', 'Position', [0 (3-ii)/4 1 1/8],'Value',0,...
        'String','','Tag',Directions{ii},'Min',-100,'Max',100,...
        'SliderStep',[0.01 0.1]);
    
    Slider.rotPC.(Directions{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.Rot, 'Callback',@PoinCloudRot,...
        'Units', 'normal', 'Position', [0 (3-ii)/4 1 1/8],'Value',0,...
        'String','','Tag',Directions{ii},'Min',-pi,'Max',pi,...
        'SliderStep',[0.001 0.1]);
    %-0.5*(max(PCs.(Parts{1}).vertices(:,ii))-min(PCs.(Parts{1}).vertices(:,ii))),...
    %'Max',0.5*max(PCs.(Parts{1}).vertices(:,ii))-min(PCs.(Parts{1}).vertices(:,ii)));
    
    Slider.moveSt.(Directions{ii}) = uicontrol('Style','text',...
        'Parent',subgroup.Move,...
        'Units', 'normal', 'Position', [0 (3-ii)/4+1/8 1 1/8],...
        'String',Directions{ii},'FontSize',10);
    
    Slider.trotSt.(Directions{ii}) = uicontrol('Style','text',...
        'Parent',subgroup.Rot,...
        'Units', 'normal', 'Position', [0 (3-ii)/4+1/8 1 1/8],...
        'String',Directions{ii},'FontSize',16);
end

Rot_mat_x = eye(3);
Rot_mat_y = eye(3);
Rot_mat_z = eye(3);

    function PoinCloudRot(source,~)
        for jj = 1:length(Parts)
            if RadioB.Active.(Parts{jj}).Value==1
                switch source.Tag
                    case 'X'
                        Rot_mat_x = [1 0 0;...
                            0 cos(source.Value) -sin(source.Value);...
                            0  sin(source.Value) cos(source.Value)];
                    case 'Y'
                        Rot_mat_y = [cos(source.Value) 0 sin(source.Value);...
                            0 1 0;...
                            -sin(source.Value) 0 cos(source.Value)];
                    case 'Z'
                        Rot_mat_z = [cos(source.Value) -sin(source.Value) 0;...
                            sin(source.Value) cos(source.Value) 0;...
                            0 0 1];
                    otherwise
                end
                Rot_mat = Rot_mat_x*Rot_mat_y*Rot_mat_z;
                t_mat = PCs.(Parts{jj}).vertices;
                t_mean = ones(size(t_mat,1),1)*mean(t_mat);
                t_mat = (t_mat-t_mean)*Rot_mat + t_mean;
                Plo.(Parts{jj}).XData = t_mat(:,1);
                Plo.(Parts{jj}).YData = t_mat(:,2);
                Plo.(Parts{jj}).ZData = t_mat(:,3);
                 if isfield(PCs.(Parts{jj}),'faces')
                    [tVV,tXdata,tYdata,tZdata] = surf_update([Plo.(Parts{jj}).XData' ...
                        Plo.(Parts{jj}).YData' ...
                        Plo.(Parts{jj}).ZData'],SurfPl.(Parts{jj}).Faces);
                    SurfPl.(Parts{jj}).Vertices = tVV;
                    MP_FPlot.(Parts{jj}).XData = tXdata;
                    MP_FPlot.(Parts{jj}).YData = tYdata;
                    MP_FPlot.(Parts{jj}).ZData = tZdata;
                        
                end
            end
        end
    end


    function PoinCloudMove(source,~)
        for jj = 1:length(Parts)
            if RadioB.Active.(Parts{jj}).Value==1
                switch source.Tag
                    case 'X'
                        Plo.(Parts{jj}).XData = PCs.(Parts{jj}).vertices(:,1) + source.Value;
                        % PCs.(Parts{jj}).vertices(:,1) = Plo.(Parts{jj}).XData;
                    case 'Y'
                        Plo.(Parts{jj}).YData = PCs.(Parts{jj}).vertices(:,2) + source.Value;
                        % PCs.(Parts{jj}).vertices(:,2) = Plo.(Parts{jj}).YData;
                    case 'Z'
                        Plo.(Parts{jj}).ZData = PCs.(Parts{jj}).vertices(:,3) + source.Value;
                        %  PCs.(Parts{jj}).vertices(:,3) = Plo.(Parts{jj}).ZData;
                    otherwise
                end
                if isfield(PCs.(Parts{jj}),'faces')
                 
                    [tVV,tXdata,tYdata,tZdata] = surf_update([Plo.(Parts{jj}).XData' ...
                        Plo.(Parts{jj}).YData' ...
                        Plo.(Parts{jj}).ZData'],SurfPl.(Parts{jj}).Faces);
                    SurfPl.(Parts{jj}).Vertices = tVV;
                    MP_FPlot.(Parts{jj}).XData = tXdata;
                    MP_FPlot.(Parts{jj}).YData = tYdata;
                    MP_FPlot.(Parts{jj}).ZData = tZdata;
                        
       
                end
            end
        end
    end


    function [vert,xdata,ydata,zdata] = surf_update(VV,FF)
        vert = VV;
        MP = FaceMP_calc(VV,FF);
        xdata = MP(:,1);
        ydata = MP(:,2);
        zdata = MP(:,3);
    end

    function FlipPC(source,~)
        for jj = 1:length(Parts)
            if RadioB.Active.(Parts{jj}).Value==1
                switch source.String
                    case 'X'
                        Plo.(Parts{jj}).XData = -PCs.(Parts{jj}).vertices(:,1)...
                            +mean(PCs.(Parts{jj}).vertices(:,1));
                        PCs.(Parts{jj}).vertices(:,1) = Plo.(Parts{jj}).XData;
                    case 'Y'
                        Plo.(Parts{jj}).YData = -PCs.(Parts{jj}).vertices(:,2)...
                            +mean(PCs.(Parts{jj}).vertices(:,2));
                        PCs.(Parts{jj}).vertices(:,2) = Plo.(Parts{jj}).YData;
                    case 'Z'
                        Plo.(Parts{jj}).ZData = -PCs.(Parts{jj}).vertices(:,3)...
                            +mean(PCs.(Parts{jj}).vertices(:,3));
                        PCs.(Parts{jj}).vertices(:,3) = Plo.(Parts{jj}).ZData;
                    otherwise
                end
            end
        end
    end


%% 4) Move vertices
% fignum.KeyPressFcn=@KeyCallback;
% %fignum.KeyReleaseFcn=@KeyRelCallBack;
% %fignum.HitTest = 'off';
% %Org_clickCallback = get(fignum,'WindowButtonDownFcn');
% %Org_clickRelCallback = get(fignum,'WindowButtonUpFcn');
% 
% Active_point_roi = drawcuboid(Ax.show3D,...
%                     'InteractionsAllowed','none',...
%                     'LineWidth',5,'Selected',false,'Visible','off',...
%                     'SelectedColor','y','StripeColor','r');
% 
%     function KeyCallback(~,evt)
%         
%         switch evt.Key
%             case 'm'
%                 %datacursormode on
%                 datacursormode on;
%                 waitforbuttonpress()
%                 t_pos = get(Ax.show3D,'CurrentPoint');
%                 Active_point_roi.Position = [t_pos(1,:)-2 4 4 4];
%                 Active_point_roi.Selected= true;
%                 Active_point_roi.Visible= 'on';
%                 %fignum.WindowButtonDownFcn = @ClickCallback;
%                 %fignum.WindowButtonUpFcn = @ClickRelCallback;             
%             otherwise
%                 [];
%         end
%     end
% 
% %  function ClickCallback(~,~)
%      t_pos = get(Ax.show3D,'CurrentPoint');
%                 t_pos = t_pos(1,:);
%  end
% 
%     function ClickRelCallback(~,~)
%         t_pos
%         datacursormode off;
% fignum.WindowButtonDownFcn = Org_clickCallback;
% fignum.WindowButtonUpFcn = Org_clickRelCallback;
%     end



%% 5) Save and Close options
subgroup.Save = uipanel('Parent', subgroup.Control, 'Units', 'normal', ...
    'Position', [0 0 1 1/10]);

PushB.Save.Save = uicontrol('Style','pushbutton',...
        'Parent',subgroup.Save,'Callback',@SaveAsShown,...
        'Units', 'normal', 'Position', [0 0 1/3 1],'Value',0,...
        'String','Save','BackgroundColor','g');
    
% PushB.Save.Save_Close = uicontrol('Style','pushbutton',...
%         'Parent',subgroup.Save,'Callback',@SaveAsShown,...
%         'Units', 'normal', 'Position', [1/3 0 1/3 1],'Value',0,...
%         'String','Save and Close','BackgroundColor','y');
    
PushB.Save.Close = uicontrol('Style','pushbutton',...
        'Parent',subgroup.Save,'Callback',@SaveAsShown,...
        'Units', 'normal', 'Position', [2/3 0 1/3 1],'Value',0,...
        'String','Close no Save','BackgroundColor','r');

    function SaveAsShown(source,~)
        for jj = 1:length(Parts)
           % if RadioB.Active.(Parts{jj}).Value==1
                PCs.(Parts{jj}).vertices(:,1) = Plo.(Parts{jj}).XData';
                PCs.(Parts{jj}).vertices(:,2) = Plo.(Parts{jj}).YData';
                PCs.(Parts{jj}).vertices(:,3) = Plo.(Parts{jj}).ZData';
            %end
        end
        switch(source.String)
            case 'Save'
                PC_out = PCs;
            case 'Save and Close'
                PC_out = PCs;
                close(fignum)
            case 'Close no Save'
                PC_out = PC_org;
                close(fignum)
            otherwise
        end
    end




waitfor(fignum)
 
end