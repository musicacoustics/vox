function varargout = external_forces_gui(varargin)
global Hndl Infold

% EXTERNAL_FORCES_GUI M-file for external_forces_gui.fig
%      EXTERNAL_FORCES_GUI, by itself, creates a new EXTERNAL_FORCES_GUI or raises the existing
%      singleton*.
%
%      H = EXTERNAL_FORCES_GUI returns the handle to a new EXTERNAL_FORCES_GUI or the handle to
%      the existing singleton*.
%
%      EXTERNAL_FORCES_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXTERNAL_FORCES_GUI.M with the given input arguments.
%
%      EXTERNAL_FORCES_GUI('Property','Value',...) creates a new EXTERNAL_FORCES_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before external_forces_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to external_forces_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help external_forces_gui

% Last Modified by GUIDE v2.5 20-Apr-2005 11:34:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @external_forces_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @external_forces_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before external_forces_gui is made visible.
function external_forces_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to external_forces_gui (see VARARGIN)

% Choose default command line output for external_forces_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes external_forces_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = external_forces_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function forceslider_Callback(hObject, eventdata, handles)
% hObject    handle to forceslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% set editphase editfield to actual value
ep   = findobj('Tag', 'editforce');
oval = get(hObject, 'Value');
nval = sprintf('%7.4f', oval/100);
set(ep,'String',nval);

% --- Executes during object creation, after setting all properties.
function forceslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forceslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editforce_Callback(hObject, eventdata, handles)
% hObject    handle to editforce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editforce as text
%        str2double(get(hObject,'String')) returns contents of editforce as a double

% set the slider to editfield value
ep   = findobj('Tag', 'forceslider');
oval = sscanf(get(hObject, 'String'), '%f');
nval = oval*100;
set(ep,'Value',nval);
% add % sign
set(hObject, 'String', get(hObject, 'String'));

% --- Executes during object creation, after setting all properties.
function editforce_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editforce (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function phaseslider_Callback(hObject, eventdata, handles)
% hObject    handle to phaseslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% set editphase editfield to actual value
ep   = findobj('Tag', 'editphase');
oval = get(hObject, 'Value');
nval = [sprintf('%3.0f', oval*360-180) '°'];
set(ep,'String',nval);


% --- Executes during object creation, after setting all properties.
function phaseslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to phaseslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

% set to zero degree after start
set(hObject,'Value',0.5);

function editphase_Callback(hObject, eventdata, handles)
% hObject    handle to editphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editphase as text
%        str2double(get(hObject,'String')) returns contents of editphase as a double

% set the slider to editfield value
ep   = findobj('Tag', 'phaseslider');
oval = sscanf(get(hObject, 'String'), '%d');
nval = (oval+180)/360;
set(ep,'Value',nval);
% add degree sign
set(hObject, 'String', [get(hObject, 'String') '°']);

% --- Executes during object creation, after setting all properties.
function editphase_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editphase (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function durationslider_Callback(hObject, eventdata, handles)
% hObject    handle to durationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% set editphase editfield to actual value
ep   = findobj('Tag', 'editduration');
oval = get(hObject, 'Value');
nval = sprintf('%4.0f', oval*100);
set(ep,'String',[nval '%']);

% --- Executes during object creation, after setting all properties.
function durationslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to durationslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function editduration_Callback(hObject, eventdata, handles)
% hObject    handle to editduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of editduration as text
%        str2double(get(hObject,'String')) returns contents of editduration as a double

% set the slider to editfield value
ep   = findobj('Tag', 'durationslider');
oval = sscanf(get(hObject, 'String'), '%d');
nval = oval/100;
set(ep,'Value',nval);
% add % sign
set(hObject, 'String', [get(hObject, 'String') '%']);

% --- Executes during object creation, after setting all properties.
function editduration_CreateFcn(hObject, eventdata, handles)
% hObject    handle to editduration (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function forcefactor_Callback(hObject, eventdata, handles)
% hObject    handle to forcefactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of forcefactor as text
%        str2double(get(hObject,'String')) returns contents of forcefactor as a double


% --- Executes during object creation, after setting all properties.
function forcefactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to forcefactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in factortoggle.
function factortoggle_Callback(hObject, eventdata, handles)
% hObject    handle to factortoggle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

faced   = findall(ancestor(hObject, 'figure'), 'Tag', 'forcefactor');   % handles is empty (window opened with openfig)
factors = -1*str2num(get(faced, 'String'));
maxm    = numel(factors);        % size() gave a vector, 1:maxm-1 is an error for it
setStr  = '';
for i=1:maxm-1
    setStr = [setStr sprintf('%1.0f', factors(i)) ';'];
end
setStr = [setStr sprintf('%1.0f', factors(maxm))];   % was factors(i): last value got lost
set(faced, 'String', setStr);
