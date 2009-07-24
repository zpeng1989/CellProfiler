function handles = FilterByObjectMeasurement(handles)

% Help for the Filter by Object Measurement module:
% Category: Object Processing
%
% SHORT DESCRIPTION:
% Eliminates objects based on their measurements (e.g. area, shape,
% texture, intensity).
% *************************************************************************
%
% This module removes objects based on their measurements produced by
% another module (e.g. MeasureObjectAreaShape, MeasureObjectIntensity,
% MeasureTexture). All objects outside of the specified parameters will be
% discarded.
%
% Feature Number or Name:
% The feature number specifies which feature from the Measure module will
% be used for filtering. See each Measure module's help for the numbered
% list of the features measured by that module. Additionally, you can
% specify the Feature Name explicitly, which is useful in special cases
% such as filtering by Location, which is created by a few modules, and 
% has a Feature Name of either 'X' or 'Y'.
%
% Special note on saving images: Using the settings in this module, object
% outlines can be passed along to the module OverlayOutlines and then saved
% with the SaveImages module. Objects themselves can be passed along to the
% object processing module ConvertToImage and then saved with the
% SaveImages module. This module produces several additional types of
% objects with names that are automatically passed along with the following
% naming structure: (1) The unedited segmented image, which includes
% objects on the edge of the image and objects that are outside the size
% range, can be saved using the name: UneditedSegmented + whatever you
% called the objects (e.g. UneditedSegmentedNuclei). (2) The segmented
% image which excludes objects smaller than your selected size range can be
% saved using the name: SmallRemovedSegmented + whatever you called the
% objects (e.g. SmallRemovedSegmented Nuclei).
%
% See also MeasureObjectAreaShape, MeasureObjectIntensity, MeasureTexture,
% MeasureCorrelation, CalculateRatios, and MeasureObjectNeighbors modules.

% CellProfiler is distributed under the GNU General Public License.
% See the accompanying file LICENSE for details.
%
% Developed by the Whitehead Institute for Biomedical Research.
% Copyright 2003,2004,2005.
%
% Please see the AUTHORS file for credits.
%
% Website: http://www.cellprofiler.org
%
% $Revision$

% MBray 2009_03_26: Comments on variables for pyCP upgrade
%
% Recommended variable order (setting, followed by current variable in MATLAB CP)
% (1) What do you want to call the filtered objects? (TargetName)
% (2) Which object would you like to filter by, or if using a Ratio, what 
%   is the numerator object? (ObjectName)
% (3) What measurement do you want to use (MeasurementCategory/MeasurementFeature/SizeScale,ImageName)
% (4a) What is the minimum value of the measurement? (MinValue1)
% (4b) What is the maxmimum value of the measurement? (MaxValue1)
% (5) What additional object do you want to receive the same labels as the
% filtered objects? (See notes below)
% (6) What do you want to call the outlines of the identified objects? Type
%   "Do not use" to ignore. (SaveOutlines)
%
% (i) The Measurements for the filtered objects should be inherited from
% the original objects, otherwise the user must add the same modules again 
% to obtain  measurements which already exist.
% (ii) Setting (3): Ideally, the Measurement category/feature/image/scale 
% settings should be drop-downs that fill in the appropriate
% category/feature/image/scale names based on (a) the hierarchy specific
% to the measurement type (i.e, features unique to Intensity, AreaShape,
% etc) and (b) whether a prior Measurement module actually took the 
% measurements (i.e, don't show all possible features for a measurement, 
% only those for which we actually have values).
% (iii) Buttons are needed after setting (4) to let the user add/subtract 
% additional Measurements to measure against. The filtered objects should 
% be those that satisfy all constraints simultaneously.
% (iv) Notes on option (5): This was added to the 5811Bugfix branch for
% a one-off user request from Ray but not incorporated in the main trunk. 
% Description: In order to insure that correspondences are maintained 
% between objects after filtering, a user can select an additional object 
% to receive the same post-filtering labels. This removes the need to use 
% IDSecondary to regenerate the 2ndary objects, or the problem of 
% relabelling primary objects if the 2ndary/tertiary objects have been 
% filtered. This should only be performed on object pairs that are 
% primary/secondary/tertiary to each other since there is a 
% guaranteed one-to-one correspondence between them. This option could
% probably be expanded to auto-fill with primary/secondary/tertiary objects
% to the input object as long as pyCP keeps track of these relationships.

%%%%%%%%%%%%%%%%%
%%% VARIABLES %%%
%%%%%%%%%%%%%%%%%
drawnow

[CurrentModule, CurrentModuleNum, ModuleName] = CPwhichmodule(handles);

%textVAR01 = What do you want to call the filtered objects?
%defaultVAR01 = FilteredNuclei
%infotypeVAR01 = objectgroup indep
TargetName = char(handles.Settings.VariableValues{CurrentModuleNum,1});

%textVAR02 = Which object would you like to filter by, or if using a Ratio, what is the numerator object?
%infotypeVAR02 = objectgroup
%inputtypeVAR02 = popupmenu
ObjectName = char(handles.Settings.VariableValues{CurrentModuleNum,2});

%textVAR03 = Which category of measurements would you want to filter by?
%inputtypeVAR03 = popupmenu category
Category = char(handles.Settings.VariableValues{CurrentModuleNum,3});

%textVAR04 = Which feature do you want to use? (Enter the feature number or name - see help for details)
%defaultVAR04 = 1
%inputtypeVAR04 = popupmenu measurement
FeatureNumOrName = handles.Settings.VariableValues{CurrentModuleNum,4};

%textVAR05 = For INTENSITY, AREAOCCUPIED or TEXTURE features, which image's measurements do you want to use (for other measurements, this will only affect the display)?
%infotypeVAR05 = imagegroup
%inputtypeVAR05 = popupmenu
ImageName = char(handles.Settings.VariableValues{CurrentModuleNum,5});

%textVAR06 = For TEXTURE, RADIAL DISTRIBUTION, OR NEIGHBORS features, what previously measured size scale (TEXTURE OR NEIGHBORS) or previously used number of bins (RADIALDISTRIBUTION) do you want to use?
%defaultVAR06 = 1
%inputtypeVAR06 = popupmenu scale
SizeScale = str2double(handles.Settings.VariableValues{CurrentModuleNum,06});

%textVAR07 = Minimum value required:
%choiceVAR07 = No minimum
%inputtypeVAR07 = popupmenu custom
MinValue1 = char(handles.Settings.VariableValues{CurrentModuleNum,7});

%textVAR08 = Maximum value allowed:
%choiceVAR08 = No maximum
%inputtypeVAR08 = popupmenu custom
MaxValue1 = char(handles.Settings.VariableValues{CurrentModuleNum,8});

%textVAR09 = What do you want to call the outlines of the identified objects? Type "Do not use" to ignore.
%defaultVAR09 = Do not use
%infotypeVAR09 = outlinegroup indep
SaveOutlines = char(handles.Settings.VariableValues{CurrentModuleNum,9});

%%%VariableRevisionNumber = 6

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% PRELIMINARY CALCULATIONS & FILE HANDLING %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

if isempty(FeatureNumOrName)
    error(['Image processing was canceled in the ', ModuleName, ' module because your entry for feature number is not valid.']);
end

if strcmp(Category,'Intensity') || strcmp(Category,'Texture')
    OrigImage = CPretrieveimage(handles,ImageName,ModuleName,'MustBeGray','CheckScale');
else
    OrigImage = CPretrieveimage(handles,ImageName,ModuleName,'DontCheckColor','CheckScale');
end
LabelMatrixImage = CPretrieveimage(handles,['Segmented' ObjectName],ModuleName,'MustBeGray','DontCheckScale');

try
    FeatureName = CPgetfeaturenamesfromnumbers(handles, ObjectName, ...
        Category, FeatureNumOrName, ImageName, SizeScale);

catch
    error([lasterr '  Image processing was canceled in the ', ModuleName, ...
        ' module (#' num2str(CurrentModuleNum) ...
        ') because an error ocurred when retrieving the data.  '...
        'Likely the category of measurement you chose, ',...
        Category, ', was not available for ', ...
        ObjectName,' with feature ' num2str(FeatureNumOrName) ...
        ', possibly specific to image ''' ImageName ''' and/or ' ...
        'Texture Scale = ' num2str(SizeScale) '.']);
end
MeasureInfo = handles.Measurements.(ObjectName).(FeatureName){handles.Current.SetBeingAnalyzed};

if strcmpi(MinValue1, 'No minimum')
    MinValue1 = -Inf;
else
    MinValue1 = str2double(MinValue1);
end

if strcmpi(MaxValue1, 'No maximum')
    MaxValue1 = Inf;
else
    MaxValue1 = str2double(MaxValue1);
end

if strcmpi(MinValue1, 'No minimum') && strcmpi(MaxValue1, 'No maximum')
    CPwarndlg(['No objects are being filtered with the default settings in ' ...
        ModuleName ' (module #' num2str(CurrentModuleNum) ')'])
end

%%%%%%%%%%%%%%%%%%%%%%
%%% IMAGE ANALYSIS %%%
%%%%%%%%%%%%%%%%%%%%%%
drawnow
% Do Filtering
Filter = find((MeasureInfo < MinValue1) | (MeasureInfo > MaxValue1));
FinalLabelMatrixImage = LabelMatrixImage;

FinalLabelMatrixImage(ismember(LabelMatrixImage(:),Filter(:))) = 0;

% Renumber Objects
x = sortrows(unique([LabelMatrixImage(:) FinalLabelMatrixImage(:)],'rows'),1);
x(x(:,2) > 0,2) = 1:sum(x(:,2) > 0);
LookUpColumn = x(:,2);

FinalLabelMatrixImage = LookUpColumn(FinalLabelMatrixImage+1);

%%%% Find outlines (should work for both primary and secondary objects)
MaxFilteredImage = ordfilt2(FinalLabelMatrixImage,9,ones(3,3),'symmetric');
IntensityOutlines = FinalLabelMatrixImage - MaxFilteredImage;
LogicalOutlines = logical(IntensityOutlines);
%LogicalOutlines = bwperim(FinalLabelMatrixImage);

%%% Determines the grayscale intensity to use for the cell outlines.
LineIntensity = max(OrigImage(:));
%%% Overlays the outlines on the original image.
ObjectOutlinesOnOrigImage = OrigImage;
ObjectOutlinesOnOrigImage(LogicalOutlines) = LineIntensity;

%%%%%%%%%%%%%%%%%%%%%%%
%%% DISPLAY RESULTS %%%
%%%%%%%%%%%%%%%%%%%%%%%
drawnow

ThisModuleFigureNumber = handles.Current.(['FigureNumberForModule',CurrentModule]);
if any(findobj == ThisModuleFigureNumber)
    %%% Activates the appropriate figure window.
    CPfigure(handles,'Image',ThisModuleFigureNumber);
    if handles.Current.SetBeingAnalyzed == handles.Current.StartingImageSet
        CPresizefigure(OrigImage,'TwoByTwo',ThisModuleFigureNumber);
    end

    %%% A subplot of the figure window is set to display the original
    %%% image.
    hAx=subplot(2,2,1,'Parent',ThisModuleFigureNumber);
    CPimagesc(OrigImage,handles,hAx);
    title(hAx,['Input Image, cycle # ',num2str(handles.Current.SetBeingAnalyzed)]);

    %%% A subplot of the figure window is set to display the label
    %%% matrix image.
    hAx=subplot(2,2,3,'Parent',ThisModuleFigureNumber);
    UnfilteredLabelMatrixImage = CPlabel2rgb(handles,LabelMatrixImage);
    CPimagesc(UnfilteredLabelMatrixImage,handles,hAx);
    title(hAx,['Original ',ObjectName]);

    %%% A subplot of the figure window is set to display the Overlaid image,
    %%% where the maxima are imposed on the inverted original image
    hAx=subplot(2,2,2,'Parent',ThisModuleFigureNumber);
    ColoredLabelMatrixImage = CPlabel2rgb(handles,FinalLabelMatrixImage);
    CPimagesc(ColoredLabelMatrixImage,handles,hAx);
    title(hAx,[ObjectName,' filtered by ',FeatureName]);

    hAx=subplot(2,2,4,'Parent',ThisModuleFigureNumber);
    CPimagesc(ObjectOutlinesOnOrigImage,handles,hAx);
    title(hAx,[TargetName, ' Outlines on Input Image']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% SAVE DATA TO HANDLES STRUCTURE %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
drawnow

handles = CPaddimages(handles,['Segmented' TargetName],FinalLabelMatrixImage);

fieldname = ['SmallRemovedSegmented', ObjectName];
%%% Checks whether the image exists in the handles structure.
if CPisimageinpipeline(handles, fieldname)
    handles = CPaddimages(handles,['SmallRemovedSegmented' TargetName],...
                            CPretrieveimage(handles,['SmallRemovedSegmented',ObjectName],ModuleName));
end

fieldname = ['UneditedSegmented',ObjectName];
%%% Checks whether the image exists in the handles structure.
if CPisimageinpipeline(handles, fieldname)
    handles = CPaddimages(handles,['UneditedSegmented' TargetName],...
                            CPretrieveimage(handles,['UneditedSegmented',ObjectName],ModuleName));
end

handles = CPsaveObjectCount(handles, TargetName, FinalLabelMatrixImage);
handles = CPsaveObjectLocations(handles, TargetName, FinalLabelMatrixImage);

if ~strcmpi(SaveOutlines,'Do not use')
    try handles = CPaddimages(handles,SaveOutlines,LogicalOutlines);
    catch
        error(['The object outlines were not calculated by the ', ModuleName, ' module so these images were not saved to the handles structure. Image processing is still in progress, but the Save Images module will fail if you attempted to save these images.'])
    end
end