%% --------------------------------------------------------------------- %%
% Function to merge PointClouds
%
% Author: Lars Erik Gangsei
% Date: ver1: 23th of february 2022
% Innput:
%       - PCs: a structure with pointclouds and possibly meshes
%       - CT(optional): Array (3D) with HU units or similar
%       - SoftPred
%       - Parts (optional): names on Parts to be shown
%       - SoftPredLabels
%       - HUlim (optional): lower and upper limit when showing HU units
% Output:
%       - Just a viewer.

function PC_out = Atlas_Viewer(PCs,CT,SoftPred,Parts,SoftPredLabels,PredCol,HUlim)
PC_org = PCs;

if ~exist('CT','var');CT = [];end
if ~exist('SoftPred','var');SoftPred = [];else;nn4 = size(SoftPred,4);end
if ~exist('Parts','var');Parts = fieldnames(PCs);end
if ~exist('SoftPredLabels','var')
    if~isempty(SoftPred)
        SoftPredLabels = cell(nn4,1);
        for jj=1:nn4
            SoftPredLabels{jj} = strjoin({'Prediction',num2str(jj)},'');
        end
    end
end
if ~exist('SoftPredLabels','var')&&exist('nn4','var')
    PredCol = distinguishable_colors(nn4);
end
if ~exist('HUlim','var');HUlim = [min(CT(:)) max(CT(:))];end

minCT = single(min(CT(:)));
maxCT = single(max(CT(:)));
meanCT = (minCT+maxCT)/2;
%minVal = (HUlim(1)-minCT)/(maxCT-minCT);
%maxVal = 1-(-HUlim(2)+maxCT)/(maxCT-minCT);
mm = length(Parts);
%CMat = distinguishable_colors(mm);

%% 1) Open figure with 4 panels

fignum = figure('Units', 'normal', 'Position', [0.1 0.1 .8 .8]);
cameratoolbar('Show')

% Panels to place different figures
subgroup.ShowSurf = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [0 0.95 1/6 0.05],'BackgroundColor','white');
if isempty(SoftPred)
    subgroup.Active = uipanel('Parent', fignum, 'Units', 'normal', ...
        'Position', [0 0 1/6 0.95]);
else
    subgroup.Active = uipanel('Parent', fignum, 'Units', 'normal', ...
        'Position', [0 0.5 1/6 0.45]);
    subgroup.SoftPred = uipanel('Parent', fignum, 'Units', 'normal', ...
        'Position', [0 0 1/6 0.5]);
end
subgroup.CT = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [5/6 0 1/6 1],'BackgroundColor','white');
subgroup.show3D = uipanel('Parent', fignum, 'Units', 'normal', ...
    'Position', [1/6 0 2/3 1]);
Ax.show3D = axes(subgroup.show3D,'Position',[0 0 1 1]);
hold(Ax.show3D,'on')
axis(Ax.show3D,'image')

PlotInst.light = camlight(Ax.show3D,'headlight');
set(PlotInst.light,'style','local');    % Set style
PlotInst.rot3d = rotate3d;                 % Create rotate3d-handle
PlotInst.rot3d.ActionPostCallback = @RotationCallback; % assign callback-function
PlotInst.rot3d.Enable = 'on';              % no need to click the UI-button


%% 2) Plot surfaces and sliders.
Slider.ShowSurf = uicontrol('Style','checkbox',...
    'Parent',subgroup.ShowSurf,...
    'Units', 'normal', 'Position', [0 0.2 1 0.8],...
    'String','Show Surfaces','FontSize',12,...
    'Callback',@Show_surf,'Value',1);

for ii = 1:mm
    subgroup.slider.(Parts{ii}) = uipanel('Parent', subgroup.Active,...
        'Units', 'normal','Position', [0 (mm-ii)/mm 1 1/mm],...
        'BackgroundColor','white');

    Slider.text1.(Parts{ii}) = uicontrol('Style','text',...
        'Parent',subgroup.slider.(Parts{ii}),...
        'Units', 'normal', 'Position', [0 1/2 1 1/3],...
        'String',Parts{ii},'Tag',Parts{ii},'FontSize',10);


    Slider.Transparency.(Parts{ii}) = uicontrol('Style','slider',...
        'Parent',subgroup.slider.(Parts{ii}), 'Callback',@Transperancy_adj,...
        'Units', 'normal', 'Position', [0 1/6 1 1/3],'Value',1,...
        'String','Skel','Tag',Parts{ii},'Enable','on','Min',0,'Max',1);


    SurfPl.(Parts{ii}) = patch(Ax.show3D,'Vertices',...
        PCs.(Parts{ii}).vertices,...
        'Faces',PCs.(Parts{ii}).faces,'FaceAlpha',...
        Slider.Transparency.(Parts{ii}).Value,...
        'FaceColor',PCs.(Parts{ii}).Color,'EdgeColor','none');

    if isfield(PCs.(Parts{ii}),'normals')
    SurfPl.(Parts{ii}).VertexNormals = PCs.(Parts{ii}).normals;
    end

    SurfPl.(Parts{ii}).FaceLighting = 'gouraud';
    if ~strcmp(Parts{ii},'Skin')
        material(SurfPl.(Parts{ii}),'shiny')
    else
        material(SurfPl.(Parts{ii}),'dull')
    end

    %  Light.(Parts{ii}).lgt = lightangle(45,45);
end

%% CT bilder
if~isempty(CT)
    [nn1,nn2,nn3] = size(CT);
    nn_vec = [nn3 nn2 nn1];
    ViewDir = {'Transverse','Coronal','Saggital'};
    for ii = 1:3
        subgroup.slider.(ViewDir{ii})= uipanel('Parent', subgroup.CT,...
            'Units', 'normal','Position', [0 1/50+(3-ii)/3 1 1/3-1/25]);

        Slider.text1.(ViewDir{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Units', 'normal', 'Position', [0 8/9 1 1/9],...
            'String',strjoin({'CT ',ViewDir{ii}},''),'Tag',ViewDir{ii},...
            'FontSize',16,'FontWeight','bold');

        Slider.textTransp.(ViewDir{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Units', 'normal', 'Position', [0 7/9 1 1/9-1/25],...
            'String','Transparancy','Tag',ViewDir{ii},'FontSize',10);



        Slider.Transparency.(ViewDir{ii}).CT = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(ViewDir{ii}), 'Callback',@Transperancy_adj,...
            'Units', 'normal', 'Position', [0 6/9+1/50 1 1/9-1/25],'Value',1,...
            'String','CT','Tag',ViewDir{ii},'Enable','on','Min',0,'Max',1);


        Slider.textPos.(ViewDir{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Units', 'normal', 'Position', [0 5/9 1 1/9-1/25],...
            'String','Position','Tag',ViewDir{ii},'FontSize',10);

        Slider.ViewSlide.(ViewDir{ii}).CT = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(ViewDir{ii}),'Callback',@MoveSlider_Callback,...
            'Units', 'normal', 'Position', [0 4/9+1/50 1 1/9-1/25],'Value',round(nn_vec(ii)/2),...
            'String','CT','Tag',ViewDir{ii},'Enable','on',...
            'Min',0,'Max',nn_vec(ii),'SliderStep',[1/nn_vec(ii) 10/nn_vec(ii)]);

        Slider.ExplGrayscale.(ViewDir{ii}) = uicontrol('Style', 'text',...
            'Units', 'normal', 'Position', [0 3/9 1 1/9-1/25],...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'String','HU min - max',...
            'FontSize',10,'Hittest','off');

        Slider.GrayscaleMin.(ViewDir{ii}) = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Callback',@GrayscaleSlider_Callback,...
            'Units', 'normal', 'Position', [0 2/9+1/50 0.5 1/9-1/25],'Value',minCT,...
            'Min',minCT,'Max',meanCT,'String','Minimum','Hittest','off','Tag',ViewDir{ii});

        Slider.GrayscaleMax.(ViewDir{ii}) = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Callback',@GrayscaleSlider_Callback,...
            'Units', 'normal', 'Position', [0.5 2/9+1/50 0.5 1/9-1/25],'Value',maxCT,...
            'Min',meanCT,'Max',maxCT,'String','Maximum','Hittest','off','Tag',ViewDir{ii});


        Slider.Smooth_Grayscale_txt.(ViewDir{ii}) = uicontrol('Style', 'text',...
            'Units', 'normal', 'Position', [0 1/9 1 1/9-1/25],...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'String','Bluring',...
            'FontSize',10,'Hittest','off');

        Slider.Smooth_Grayscale.(ViewDir{ii}) = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(ViewDir{ii}),...
            'Callback',@GrayscaleSmoother_Callback,...
            'Units', 'normal', 'Position', [0 0/9+1/50 1 1/9-1/25],'Value',1,...
            'Min',0.01,'Max',1,'String','SmothGrayscale','Hittest','off',...
            'Tag',ViewDir{ii});

        %SurfPl.(ViewDir{ii}).CT = surf(Ax.show3D,...
        %    CT.(ViewDir{ii}).XX,CT.(ViewDir{ii}).YY,...
        %    CT.(ViewDir{ii}).ZZ,CT.(ViewDir{ii}).CC,...
        %    'EdgeColor','none','AlphaData',CT.(ViewDir{ii}).AA,...
        %    'FaceAlpha',0);

        switch ViewDir{ii}
            case 'Transverse'
                im = squeeze(CT(:,:,round(Slider.ViewSlide.(ViewDir{ii}).CT.Value)));
                [XX,YY] = meshgrid(1:nn1,1:nn2);
                ZZ = round(Slider.ViewSlide.(ViewDir{ii}).CT.Value)*ones(nn1,nn2);
            case 'Saggital'
                im = squeeze(CT(:,round(Slider.ViewSlide.(ViewDir{ii}).CT.Value),:));
                [ZZ,YY] = meshgrid(1:nn3,1:nn1);
                XX = round(Slider.ViewSlide.(ViewDir{ii}).CT.Value)*ones(nn1,nn3);
            case 'Coronal'
                im = squeeze(CT(round(Slider.ViewSlide.(ViewDir{ii}).CT.Value),:,:))';
                [XX,ZZ] = meshgrid(1:nn2,1:nn3);
                YY = round(Slider.ViewSlide.(ViewDir{ii}).CT.Value)*ones(nn3,nn2);
        end
        im(im<HUlim(1)) = HUlim(1);
        im(im>HUlim(2)) = HUlim(2);
        Show2D.(ViewDir{ii}) = surf(Ax.show3D,XX,YY,ZZ,im,...
            'EdgeColor','none',...%'AlphaData',CT.(PartsCT{ii}).AA,...
            'FaceAlpha',Slider.Transparency.(ViewDir{ii}).CT.Value);
        %Show2D.(ViewDir{ii}).CData = Show2D.(ViewDir{ii}).CData-min(Show2D.(ViewDir{ii}).CData(:));
        %Show2D.(ViewDir{ii}).CData = 1000*Show2D.(ViewDir{ii}).CData/max(Show2D.(ViewDir{ii}).CData(:));
        colormap(Ax.show3D,'gray')
        material(Show2D.(ViewDir{ii}),'dull')
        caxis(Ax.show3D,HUlim)
        % Light.(PartsCT{ii}).Mask.lgt = lightangle(45,45);
    end
end

%% 4) Soft Predictions
if~isempty(SoftPred)
    for ii = 1:nn4
        subgroup.slider.(SoftPredLabels{ii})= uipanel(...
            'Parent', subgroup.SoftPred,...
            'Units', 'normal','Position', [0 1/50+(nn4-ii)/nn4 1 1/nn4-1/25]);

        Slider.text1.(SoftPredLabels{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(SoftPredLabels{ii}),...
            'Units', 'normal', 'Position', [0 0.6 1 0.3],...
            'String',SoftPredLabels{ii},...
            'Tag',SoftPredLabels{ii},'FontSize',16,'FontWeight','bold');

        Slider.text2.(SoftPredLabels{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(SoftPredLabels{ii}),...
            'Units', 'normal', 'Position', [0 0.45 1 0.15],...
            'String','Transparency',...
            'Tag',SoftPredLabels{ii},'FontSize',10);

        Slider.Transparency.(SoftPredLabels{ii}) = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(SoftPredLabels{ii}), 'Callback',@Transperancy_adj,...
            'Units', 'normal', 'Position', [0 0.3 1 0.15],'Value',0.5,...
            'String','Skel','Tag',SoftPredLabels{ii},'Enable','on','Min',0,'Max',1);
        
        TmpVol = squeeze(SoftPred(:,:,:,ii));
        if sum(TmpVol(:)>0&TmpVol(:)<1)>0
        Slider.text3.(SoftPredLabels{ii}) = uicontrol('Style','text',...
            'Parent',subgroup.slider.(SoftPredLabels{ii}),...
            'Units', 'normal', 'Position', [0 0.15 1 0.15],...
            'String','Fuzzy Limit',...
            'Tag',SoftPredLabels{ii},'FontSize',10);

        Slider.FuzzyLim.(SoftPredLabels{ii}) = uicontrol('Style','slider',...
            'Parent',subgroup.slider.(SoftPredLabels{ii}), 'Callback',@Fuzzy_adj,...
            'Units', 'normal', 'Position', [0 0 1 0.15],'Value',0.5,...
            'String','CT','Tag',SoftPredLabels{ii},'Enable','on','Min',0,'Max',1);
        
        TmpSurf = isosurface(TmpVol,Slider.FuzzyLim.(SoftPredLabels{ii}).Value);
        EdCol =  'none';
        else
            TmpSurf = isosurface(TmpVol,0.5);
            EdCol =  'k';
        end
        SurfPl.(SoftPredLabels{ii}) = patch(Ax.show3D,'Vertices',...
        TmpSurf.vertices,'Faces',TmpSurf.faces,'FaceAlpha',...
        Slider.Transparency.(SoftPredLabels{ii}).Value,...
        'FaceColor',PredCol(ii,:),'EdgeColor',EdCol);

        SurfPl.(SoftPredLabels{ii}).FaceLighting = 'gouraud';

        % Light.(PartsCT{ii}).Mask.lgt = lightangle(45,45);
    end
end


%% 5) Callback functions

% Sub function for callback
    function RotationCallback(~,~)
        PlotInst.light = camlight(PlotInst.light,'headlight');
    end

%Function for changing transperancy of surfaces
    function Transperancy_adj(source,~)
        if strcmp(source.String,'Skel')
            if source.Value <0.05
                SurfPl.(source.Tag).Visible ='off';
            else
                SurfPl.(source.Tag).Visible ='on';
                SurfPl.(source.Tag).FaceAlpha=source.Value;
            end
        else
            if source.Value <0.05
                Show2D.(source.Tag).Visible ='off';
            else
                Show2D.(source.Tag).Visible ='on';
                Show2D.(source.Tag).FaceAlpha=source.Value;
            end
        end
        lighting(Ax.show3D,'gouraud')
    end

%Function for fuzzy value of surfaces
    function Fuzzy_adj(source,~)
        lab = find(strcmp(SoftPredLabels,source.Tag));
        TmpSurf = isosurface(squeeze(SoftPred(:,:,:,lab)),source.Value);

        SurfPl.(source.Tag).Vertices = TmpSurf.vertices;
        SurfPl.(source.Tag).Faces = TmpSurf.faces;
    end

    function GrayscaleSlider_Callback(source,~)
        switch source.String
            case 'Minimum'
                %HUlim(1) = minCT + source.Value*(maxCT-minCT);
                %HUlim(2) = maxCT - (1-Slider.GrayscaleMax.(source.Tag).Value)*(maxCT-minCT);
                HUlim(1) = source.Value;
                HUlim(2) = Slider.GrayscaleMax.(source.Tag).Value;
            case 'Maximum'
                %HUlim(1) = minCT + Slider.GrayscaleMin.(source.Tag).Value*(maxCT-minCT);
                %HUlim(2) = maxCT - (1-source.Value)*(maxCT-minCT);
                HUlim(1) = Slider.GrayscaleMin.(source.Tag).Value;
                HUlim(2) = source.Value;
        end

        caxis(Ax.show3D,HUlim)
        lighting(Ax.show3D,'flat')
%         switch source.Tag
%             case 'Transverse'
%                 Show2D.(source.Tag).CData = squeeze(CT(:,:,round(Slider.ViewSlide.(source.Tag).CT.Value)));
%             case 'Coronal'
%                 Show2D.(source.Tag).CData = squeeze(CT(round(Slider.ViewSlide.(source.Tag).CT.Value),:,:))';
%             case 'Saggital'
%                 Show2D.(source.Tag).CData = squeeze(CT(:,round(Slider.ViewSlide.(source.Tag).CT.Value),:));
%         end
        %Show2D.(source.Tag).CData(Show2D.(source.Tag).CData<HUlim(1)) = HUlim(1);
        %Show2D.(source.Tag).CData(Show2D.(source.Tag).CData>HUlim(2)) = HUlim(2);
        %Show2D.(source.Tag).CData = Show2D.(source.Tag).CData-min(Show2D.(source.Tag).CData(:));
        %Show2D.(source.Tag).CData = 1000*Show2D.(source.Tag).CData/max(Show2D.(source.Tag).CData(:));
        %colormap(Ax.show3D,'gray')
        %material(Show2D.(source.Tag),'dull')
    end

    function GrayscaleSmoother_Callback(source,~)
        GrayscaleSlider_Callback(Slider.GrayscaleMin.(source.Tag));
        Show2D.(source.Tag).CData = imgaussfilt(Show2D.(source.Tag).CData,1/source.Value);
    end

    function MoveSlider_Callback(source,~)
        %Show2D.(source.Tag).Visible = 'off';
        %Show2D = rmfield(Show2D,source.Tag);
        switch source.Tag
            case 'Transverse'
                im = squeeze(CT(:,:,round(Slider.ViewSlide.(source.Tag).CT.Value)));
                [XX,YY] = meshgrid(1:nn1,1:nn2);
                ZZ = round(source.Value)*ones(nn1,nn2);
            case 'Saggital'
                im = squeeze(CT(:,round(Slider.ViewSlide.(source.Tag).CT.Value),:));
                [ZZ,YY] = meshgrid(1:nn3,1:nn1);
                XX = round(source.Value)*ones(nn1,nn3);
            case 'Coronal'
                im = squeeze(CT(round(Slider.ViewSlide.(source.Tag).CT.Value),:,:))';
                [XX,ZZ] = meshgrid(1:nn2,1:nn3);
                YY = round(source.Value)*ones(nn3,nn2);
        end
        Show2D.(source.Tag).XData = XX;
        Show2D.(source.Tag).YData = YY;
        Show2D.(source.Tag).ZData = ZZ;
        Show2D.(source.Tag).CData = im;
        GrayscaleSmoother_Callback(Slider.Smooth_Grayscale.(source.Tag));
    end


    function Show_surf(source,~)
        if(source.Value==1);SurfStat='on';else;SurfStat='off';end
        for ii = 1:mm
            SurfPl.(Parts{ii}).Visible = SurfStat;
        end
    end


waitfor(fignum)

end