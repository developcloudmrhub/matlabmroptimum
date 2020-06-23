function varargout = drawtest(varargin)
% DRAWTEST MATLAB code for drawtest.fig
%      DRAWTEST, by itself, creates a new DRAWTEST or raises the existing
%      singleton*.
%
%      H = DRAWTEST returns the handle to a new DRAWTEST or the handle to
%      the existing singleton*.
%
%      DRAWTEST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DRAWTEST.M with the given input arguments.
%
%      DRAWTEST('Property','Value',...) creates a new DRAWTEST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before drawtest_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to drawtest_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help drawtest

% Last Modified by GUIDE v2.5 10-Jul-2019 11:48:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @drawtest_OpeningFcn, ...
                   'gui_OutputFcn',  @drawtest_OutputFcn, ...
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


% --- Executes just before drawtest is made visible.
function drawtest_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to drawtest (see VARARGIN)



set(handles.minslider, 'min', 1);
set(handles.minslider, 'max', 100);
set(handles.minslider, 'Value', 1); % Somewhere between max and min.

set(handles.maxslider, 'min', 1);
set(handles.maxslider, 'max', 100);
set(handles.maxslider, 'Value', 100); % Somewhere between max and min.


handles.h=255;
handles.w=255;
handles.array=randn(handles.h*handles.w,1);

handles.SUP=figure();
title('data transformation');


createimageandplot(handles.array,handles.h,handles.w,handles.axes1,handles.axes2,get(handles.minslider,'Value'),(100-get(handles.maxslider,'Value')),handles.SUP);
guidata(hObject, handles);





% Choose default command line output for drawtest
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes drawtest wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = drawtest_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on slider movement.
function minslider_Callback(hObject, eventdata, handles)
% hObject    handle to minslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

createimageandplot(handles.array,handles.h,handles.w,handles.axes1,handles.axes2,get(handles.minslider,'Value'),(100-get(handles.maxslider,'Value')),handles.SUP);

% --- Executes during object creation, after setting all properties.
function minslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function maxslider_Callback(hObject, eventdata, handles)
% hObject    handle to maxslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

createimageandplot(handles.array,handles.h,handles.w,handles.axes1,handles.axes2,get(handles.minslider,'Value'),(100-get(handles.maxslider,'Value')),handles.SUP);

% --- Executes during object creation, after setting all properties.
function maxslider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxslider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in resultsload.
function resultsload_Callback(hObject, eventdata, handles)
% hObject    handle to resultsload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


[FILENAME, PATHNAME] = uigetfile('*.json', 'load json result');

data=readanddecodejson(fullfile(PATHNAME,FILENAME));

[handles.array ,handles.h,handles.w]=getarrayfromresult(data,3);

createimageandplot(handles.array,handles.h,handles.w,handles.axes1,handles.axes2,get(handles.minslider,'Value'),(100-get(handles.maxslider,'Value')),handles.SUP);
guidata(hObject, handles);


% --- Executes on button press in gradient_.
function gradient__Callback(hObject, eventdata, handles)
% hObject    handle to gradient_ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


handles.h=255;
handles.w=255;

X=linspace(-255,255,255);
Y=repmat(X(:),[1, 255]);

handles.array=Y(:);




createimageandplot(handles.array,handles.h,handles.w,handles.axes1,handles.axes2,get(handles.minslider,'Value'),(100-get(handles.maxslider,'Value')),handles.SUP);
guidata(hObject, handles);


