clear
close all
filename = zeros(4,1);
result = zeros(4,989);
filename(1)="triangle_01.csv";
filename(2) ="triangle_02.csv";
filename(3)="square_01.csv";
filename(4)="square_02.csv";
fs = 44100;

result1 = importdata("triangle_01.csv");
result2 = importdata("triangle_02.csv");
result3 = importdata("square_01.csv");
result4 = importdata("square_02.csv");
result(1,:)=result1.data;
result(2,:)=result2.data;
result(3,:)=result3.data;
result(4,:)=result4.data;
index=1;
sample_time = 20;
sample_interval = fs/sample_time;
%peaks = findpeaks(result);
%%201为特征个数，事先计算好的
train_x = zeros(length(result(:,1))*8,201);
train_x_index = 1;
for q = 1:length(result(:,1))
    tmp = result(q,:);
    %plot(result(peaks),'.');
    segment_time = floor(length(tmp(1,:))/100)-1;
    segment_length=100;
    %%将result拆分成八份，每份的长度为100
    segment = zeros(segment_time,segment_length);
    for i=1:segment_time
        data = tmp(segment_length*i:segment_length*i+segment_length-1);
        segment(i,:)=data;
    end
    %%平滑处理
    for i = 1:length(segment(:,i))
        segment(i,:)=smoothdata(segment(i,:),'gaussian',segment_length/10);
    end
    
    %%201为特征个数，事先计算好的
    total_features=zeros(length(segment(:,1)),201);
    for i = 1:length(segment(:,1))
        feature1 = var(segment(i,:));
        feature2 = mean(segment(i,:));
        feature3 = median(segment(i,:));
        feature4 = max(segment(i,:));
        feature5 = min(segment(i,:));
        feature6 = diff(segment(i,:));
        feature7 = diff(diff(feature6));
        features = [feature1,feature2,feature3,feature4,feature5,feature6,feature7];
        train_x(train_x_index,:)=features;
        train_x_index = train_x_index+1;
    end
    
    
end
y = 1:1:length(result(:,1))*segment_time;
y = y';
t=fitctree(train_x,y');
test_triangle_01=importdata("test_square_01.csv");
test_triangle_01=test_triangle_01.data;
test_feature = fun(test_triangle_01);
yfit=predict(t,test_feature);
function feature = fun(test_data)
    fs = 44100;
    sample_time = 20;
    sample_interval = fs/sample_time;
    %plot(result(peaks),'.');
    segment_time = floor(length(test_data(1,:))/100)-1;
    segment_length=100;
    %%将result拆分成八份，每份的长度为100
    segment = zeros(segment_time,segment_length);
    for i=1:segment_time
        data = test_data(segment_length*i:segment_length*i+segment_length-1);
        segment(i,:)=data;
    end
    %%平滑处理
    for i = 1:length(segment(:,i))
        segment(i,:)=smoothdata(segment(i,:),'gaussian',segment_length/10);
    end
    
    %%201为特征个数，事先计算好的
    total_features=zeros(8,201);
    for i = 1:length(segment(:,1))
        feature1 = var(segment(i,:));
        feature2 = mean(segment(i,:));
        feature3 = median(segment(i,:));
        feature4 = max(segment(i,:));
        feature5 = min(segment(i,:));
        feature6 = diff(segment(i,:));
        feature7 = diff(diff(feature6));
        features = [feature1,feature2,feature3,feature4,feature5,feature6,feature7];
        total_features(i,:)=features;
    end
    feature = total_features;
end