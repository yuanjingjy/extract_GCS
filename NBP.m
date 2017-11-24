function [ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,nbpmean_mean] = NBP( starttime,startpoint,ahe_id )
%输入参数：
%       starttime:hea头文件记录的起始时间
%       startpoint：AHE样本本相对于原始数据记录的起始点
%输出参数：
%       sysnbp_max:nbp收缩最大值.
%       sysnbp_min:nbp收缩最小值
%       sysnbp_mean:nbp收缩平均值
%       dianbp_max:nbp舒张最大值
%       dianbp_min:nbp舒张最小值
%       dianbp_mean:nbp舒张平均值
%       nbpmean_max:nbp平均最大值
%       nbpmean_min:nbp平均最小值
%       nbpmean_mean:nbp平均平均值

%函数功能：提取样本所在10个小时范围内病人无创血压参数

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
%———————————————提取NBP———————————————%
sql_NBP=['select subject_id, icustay_id, charttime, realtime, value1num,value2num from mimic2v26.nbp'...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    '''and subject_id =' num2str(ahe_id) ];
curs_NBP=exec(conna,sql_NBP);
curs_NBP=fetch(curs_NBP);
Data_NBP=curs_NBP.Data;

if length(Data_NBP)==1
    data_sysnbp=0;
    data_dianbp=0
else
    data_sysnbp=Data_NBP(:,5);%倒数第二行记录的是收缩压
    data_sysnbp=cell2mat(data_sysnbp);
    
    data_dianbp=Data_NBP(:,end);%最后一行为舒张压
    data_dianbp=cell2mat(data_dianbp);
end



if length(data_sysnbp)==1
    sysnbp_max=nan;
    sysnbp_min=nan;
    sysnbp_mean=nan;
else
    sysnbp_max=max(data_sysnbp);%GCS最大值
    sysnbp_min=min(data_sysnbp);%GCS最小值
    sysnbp_mean=mean(data_sysnbp);%GCS平均值
end

if length(data_dianbp)==1
    dianbp_max=nan;
    dianbp_min=nan;
    dianbp_mean=nan;
else
    dianbp_max=max(data_dianbp);
    dianbp_min=min(data_dianbp);
    dianbp_mean=mean(data_dianbp);
end

%———————————————提取NBP mean———————————————%
sql_NBP_mean=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.nbp_mean '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%筛选样本对应的10个小时内的GCS
curs_NBP_mean=exec(conna,sql_NBP_mean);
curs_NBP_mean=fetch(curs_NBP_mean);
Data_NBP_mean=curs_NBP_mean.Data;

data_nbpmean=Data_NBP_mean(:,end);%最后一列记录的是GCS数据
data_nbpmean=cell2mat(data_nbpmean);%元胞数组转matlab矩阵

if length(data_nbpmean)== 7
    nbpmean_max=nan;
    nbpmean_min=nan;
    nbpmean_mean=nan;
else
    nbpmean_max=max(data_nbpmean);%GCS最大值
    nbpmean_min=min(data_nbpmean);%GCS最小值
    nbpmean_mean=mean(data_nbpmean);%GCS平均值
end

close(conna);


end

