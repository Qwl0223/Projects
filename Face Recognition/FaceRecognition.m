
%CITS4402 - Final Project - FaceRecognition
%Group12

function varargout = FaceRecognition(varargin)
% FACERECOGNITION MATLAB code for FaceRecognition.fig
%      FACERECOGNITION, by itself, creates a new FACERECOGNITION or raises the existing
%      singleton*.
%
%      H = FACERECOGNITION returns the handle to a new FACERECOGNITION or the handle to
%      the existing singleton*.
%
%      FACERECOGNITION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FACERECOGNITION.M with the given input arguments.
%
%      FACERECOGNITION('Property','Value',...) creates a new FACERECOGNITION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FaceRecognition_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FaceRecognition_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FaceRecognition

% Last Modified by GUIDE v2.5 22-May-2019 15:21:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FaceRecognition_OpeningFcn, ...
                   'gui_OutputFcn',  @FaceRecognition_OutputFcn, ...
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


% --- Executes just before FaceRecognition is made visible.
function FaceRecognition_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FaceRecognition (see VARARGIN)

%main path
handles.imgDataPath = 'E:/CITS4402/project/FaceDataset/FaceDataset/'; %Orignal Database
%handles.imgDataPath = 'E:/CITS4402/project/Group12/'; %new Database
handles.Train_set = 'E:/CITS4402/project/Train_set/';%Train Dataset
handles.Test_set = 'E:/CITS4402/project/Test_set/';%Test Dataset
%main parameter
handles.totalimg = 10;% image number of Every S set defined in the project description
handles.num = 5; % Training image number of Every S set defined in the project description
handles.downsampling = [10,5]; %downsampling size defined in the paper

handles.output = hObject;
set(handles.axes2,'xtick',[],'ytick',[]);
set(handles.axes1,'xtick',[],'ytick',[]);
guidata(hObject, handles);

% UIWAIT makes FaceRecognition wait for user response (see UIRESUME)
% uiwait(handles.figure1);
clear;
clc;


% --- Outputs from this function are returned to the command line.
function varargout = FaceRecognition_OutputFcn(hObject, eventdata, handles) 

varargout{1} = handles.output;


% --- Executes on button press in create_database.
function create_database_Callback(hObject, eventdata, handles)

if ~exist('Train_set','dir')
    mkdir('Train_set')
end 

if ~exist('Test_set','dir')
    mkdir('Test_set')
end

%Train_set = 'E:/CITS4402/project/Train_set/';%Train Dataset
%Test_set = 'E:/CITS4402/project/Test_set/';%Test Dataset

%imgDataPath = 'E:/CITS4402/project/FaceDataset/FaceDataset/'; %Orignal Database
imgDataDir  = dir(handles.imgDataPath);             % read all folder in FaceDataset

%get the classes of the database and make it as a array
isdir = [imgDataDir.isdir];
classes = {imgDataDir(isdir).name};
classes(ismember(classes,{'.', '..'})) = [];
handles.classes = classes;
disp(classes);

%store train dataset as a column in a file
colLen = prod(handles.downsampling);

Train = zeros(colLen, handles.num, length(classes));
handles.Train = Train;

%store test dataset as column in a file
Test = zeros(colLen, handles.totalimg - handles.num, length(classes));
handles.Test = Test;

for i = 1:length(classes)
    imgDataDir(i).name = ['s',num2str(i)];
    imgDir = dir([handles.imgDataPath imgDataDir(i).name '/*.pgm']); % read all pgm files in the folder
    jpick = randperm(length(imgDir)); % get random pick image for training set
    for j = 1:length(jpick)
        if j <= handles.num  % Train set
            p = jpick(j);
            img = imread([handles.imgDataPath imgDataDir(i).name '/' imgDir(p).name]);
            imwrite(img,[handles.Train_set,imgDataDir(i).name '_' int2str(p),'.pgm']);
            %gray image
            if ndims(img) == 3
                img = rgb2gray(img);
            end
            %resize to downsampling size
            img = imresize(img, handles.downsampling);
            % convert to doubles
            img = double(reshape(img,colLen,1));
            %normalise
            img = img / max(img);
            %store each image as a column
            handles.Train(:,j,i) = img;
        elseif j > handles.num  %Test set
            p = jpick(j);
            img = imread([handles.imgDataPath imgDataDir(i).name '/' imgDir(p).name]);
            imwrite(img,[handles.Test_set,imgDataDir(i).name '_' int2str(p),'.pgm']);
            %gray image
            if ndims(img) == 3
                img = rgb2gray(img);
            end
            %resize to downsampling size
            img = imresize(img, handles.downsampling);
            % convert to doubles
            img = double(reshape(img,colLen,1));
            %normalise
            img = img / max(img);
            %store each image as a column
            handles.Test(:,j - handles.num,i) = img;
        end
    end
end
guidata(hObject, handles);


function hatmatrix = computehatmatrix(hObject, handles) 
%compute H_i = X_i * (transpose(X_i)*X_i) ^ -1 * transpose(X_i)
%defined in the paper as hatmatrix
imageLen = prod(handles.downsampling);
numclasses = length(handles.classes);
hatmatrix = zeros(imageLen, imageLen, numclasses);
for i = 1:numclasses
    xi = handles.Train(:,:,i);
    hatmatrix(:, :, i) = xi / (xi' * xi ) * xi';
end
handles.hatmatrix = hatmatrix;
guidata(hObject, handles);


% --- Executes on button press in train_model.
function  [mDist, predicted] = Prediction(hObject, handles,img)
%compute smallest distance between the input image and find its projection
distance = zeros(length(handles.classes),1);
hatmatrix = computehatmatrix(hObject, handles);
for i = 1:length(distance);
    distance(i) = sum((img - hatmatrix(:, :, i) * img) .^2);
end

[mDist, predicted] = min(distance);

guidata(hObject, handles);


    

% --- Executes on button press in recognition.
function recognition_Callback(hObject, eventdata, handles)
%TestDataPath = 'E:/CITS4402/project/Test_set/';
TestDir = dir([handles.Test_set '/*.pgm']); 
TrainDir = dir([handles.Train_set '/*.pgm']);
numTotal = 0;
numCorrect = 0;
% read all pgm in the test_set folder
for i = 1:length(TestDir)
    ipick = randperm(length(TestDir),1);
    img = imread([handles.Test_set TestDir(ipick).name]);
    axes(handles.axes1);
    imshow(img);
    set(handles.labeltest, 'String',TestDir(ipick).name);
    
    % find the image colLen for the picked test image
    label_str1 = strsplit(TestDir(ipick).name,'_');
    label_str1 = label_str1{1};
    label_str2 = strsplit(label_str1,'s');
    label_str3 = label_str2{2};
    imglabel = str2num(label_str3);
    
    for j = 1: (handles.totalimg - handles.num)
        [mDist, predicted] = Prediction(hObject, handles, handles.Test(:, j, imglabel));
    end
    axes(handles.axes2);
    for m = 1:length(TrainDir)
        find_str1 = strsplit(TrainDir(m).name,'_');
        find_str1 = find_str1{1};
        find_str2 = strsplit(find_str1,'s');
        find_str3 = find_str2{2};
        imgfind = str2num(find_str3);
        if imgfind == predicted
            predictedname = TrainDir(m).name;
            break
        end
    end
    predictedimg = imread([handles.Train_set predictedname]);
    imshow(predictedimg);
    set(handles.labelpredicted, 'String',predictedname);
    if i==predicted
        pause(0.5);
    else
        pause(2);
    end
    
    %compute accurary
    numTotal = numTotal + 1;
    if predicted ~= imglabel
        numCorrect = numCorrect;
    else
        numCorrect = numCorrect + 1;
    end
    
    accuracy = numCorrect * 100 / numTotal;
    set(handles.Percent, 'String',sprintf('%.2f%% (%d/%d)', accuracy, numCorrect, numTotal));
end


guidata(hObject, handles);


% --- Executes on button press in image_detection.
function image_detection_Callback(hObject, eventdata, handles)
colLen = prod(handles.downsampling);
New = zeros(colLen)
handles.New = New;
TrainDir = dir([handles.Train_set '/*.pgm']);
[filename,pathname]=uigetfile({'*.pgm';'*.jpg';'*.bmp';'*.tif';'*.*'},'Load Image');
if isequal(filename,0)|isequal(pathname,0)
    errordlg('Choose No Image','Load Fail');
    return;
else
    file=[pathname,filename];
    global S;
    S=file;
    img=imread(file);
    axes(handles.axes1);
    imshow(img);
end
    %gray image
    if ndims(img) == 3
        img = rgb2gray(img);
    end
    %resize to downsampling size
    img = imresize(img, handles.downsampling);
    % convert to doubles
    img = double(reshape(img,colLen,1));
    %normalise
    img = img / max(img);
    %store each image as a column
    disp(img);
    handles.New = img;
    [mDist, predicted] = Prediction(hObject,handles,handles.New);
    axes(handles.axes2);
    for m = 1:length(TrainDir)
        find_str1 = strsplit(TrainDir(m).name,'_');
        find_str1 = find_str1{1};
        find_str2 = strsplit(find_str1,'s');
        find_str3 = find_str2{2};
        imgfind = str2num(find_str3);
        if imgfind == predicted
            predictedname = TrainDir(m).name;
            break
        end
    end
    predictedimg = imread([handles.Train_set predictedname]);
    imshow(predictedimg);
    set(handles.labelpredicted, 'String',predictedname);
    
    guidata(hObject,handles);
    


