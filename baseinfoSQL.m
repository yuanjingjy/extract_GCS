function [GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max,height] = baseinfoSQL( starttime,startpoint,ahe_id )
%输入参数：
%       starttime:hea头文件记录的起始时间
%       startpoint：AHE样本本相对于原始数据记录的起始点
%输出参数：

%       GCS_max:所选时间范围内GCS的最大值；
%       GCS_min：所选时间范围内GCS的最小值
%       GCS_mean：所选时间范围内GCS的平均值
%       gender：性别
%       age：年龄
%       weight_first：进入ICU时的体重
%       weight_min：病人在ICU期间体重的最小值
%       weight_max：病人在ICU期间体重的最大值
%       height：病人身高记录
%函数功能：提取样本所在10个小时范围内病人的GCS、性别、年龄、体重、身高等信息

conna=database('YJDB','postgres','yuanjing')%数据库连接

%——————计算10个小时AHE样本对应的两个时间节点———————%
sql_time=['select( TIMESTAMP ''' starttime '''+ interval ''' num2str(startpoint)  ' minute '' )'];
curs=exec(conna,sql_time);%hea起始时间，加上样本起始点，即为筛选出的样本的开始时间

curs=fetch(curs);
Data_time=curs.Data;

T_start=Data_time{1,1};%求出的样本的开始时间
sql_T0=['select( TIMESTAMP ''' T_start '''+ interval ''' num2str(10)  ' hour '' )'];%样本的开始时间加10小时
curs_T0=exec(conna,sql_T0);
curs_T0=fetch(curs_T0);
Data_T0=curs_T0.Data;
Data_T0=Data_T0{1,1};%样本开始时间加上10小时后的时间，即T0时刻

%———————————————提取GCS———————————————%
sql_GCS=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.gcs '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%筛选样本对应的10个小时内的GCS
curs_GCS=exec(conna,sql_GCS);
curs_GCS=fetch(curs_GCS);
Data_GCS=curs_GCS.Data;

data_gcs=Data_GCS(:,end);%最后一列记录的是GCS数据
data_gcs=cell2mat(data_gcs);%元胞数组转matlab矩阵

if length(data_gcs)==7
    GCS_max=nan;
    GCS_min=nan;
    GCS_mean=nan;
else
    GCS_max=max(data_gcs);%GCS最大值
    GCS_min=min(data_gcs);%GCS最小值
    GCS_mean=mean(data_gcs);%GCS平均值
end


%提取出样本对应的icustay_id，
% icuid=Data_GCS(1,2);
% icuid=cell2mat(icuid);

%————————筛选性别、年龄、身高、体重等基本信息————————%
% sql_baseinfo=['select subject_id, icustay_id,gender,icustay_admit_age, '...
%     'weight_first,weight_min,weight_max,height from mimic2v26.icustay_detail'...
%     ' where subject_id = ' num2str(ahe_id) ' and icustay_id = ' num2str(icuid)]
sql_baseinfo=['select subject_id, icustay_id,gender,icustay_admit_age, '...
    'weight_first,weight_min,weight_max,height from mimic2v26.icustay_detail'...
    ' where subject_id = ' num2str(ahe_id)];


curs_baseinfo=exec(conna,sql_baseinfo);
curs_baseinfo=fetch(curs_baseinfo);
Data_baseinfo=curs_baseinfo.Data;

tmp=zeros(1,6);

%—————————提取性别——————————%
gender_tmp=Data_baseinfo(:,3);
gender_tmp=cell2mat(gender_tmp);

[m,n]=find(gender_tmp);

gender_str=gender_tmp(m(1),n(1));

if strcmp(gender_str,'F')
    tmp(1,1)=1;%女性用1表示
end
if strcmp( gender_str,'M')
    tmp(1,1)=2;%男性用2表示
end
gender=tmp(1,1);
%————————提取年龄—————————%
age_tmp=Data_baseinfo(:,4);
age_tmp=cell2mat(age_tmp);

tmp(1,2)=mean(age_tmp);

age=tmp(1,2);
%------------------提取体重---------------%
weight=Data_baseinfo(:,5:7);
weight=cell2mat(weight);
tmp(1,3:5)=mean(weight);

weight_first=tmp(1,3);
weight_min=tmp(1,4);
weight_max=tmp(1,5);
% %-----------------提取身高----------------%
% height_tmp=Data_baseinfo(:,8);
% height=cell2mat(height_tmp);
% tmp(1,6)=height;
% height=tmp(1,6);


sql_height=['select subject_id, height from mimic2v26.height'...
    '  where subject_id = ' num2str(ahe_id)];

curs_height=exec(conna,sql_height);
curs_height=fetch(curs_height);
Data_height=curs_height.Data;

if length(Data_height)~= 2
    height=nan;
else
    height_tmp=Data_height(:,2);
    height_tmp=cell2mat(height_tmp);
    height=mean(height_tmp);
end


close(conna);


end

