function [MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,Ma_mean_min,Ma_mean_mean] = manual_BP( starttime,startpoint,ahe_id )
%输入参数：
%       starttime:hea头文件记录的起始时间
%       startpoint：AHE样本本相对于原始数据记录的起始点
%       ahe_id:病人的id号
%输出参数：
%       MaBP_sys_max:手动BP收缩最大值
%       MaBP_sys_min:手动BP收缩最小值
%       MaBP_sys_mean:手动BP收缩平均值
%       MaBP_dia_max:手动BP舒张最大值
%       MaBP_dia_min:手动BP舒张最小值
%       MaBP_dia_mean:手动BP舒张平均值
%       Ma_mean_max:手动BP平均最大值
%       Ma_mean_min:手动BP平均最小值
%       Ma_mean_mean:手动BP平均平均值

%函数功能：提取样本所在10个小时范围内病人的手动测量血压值

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

%———————————————提取Manual BP———————————————%
sql_MaBP=['select subject_id, icustay_id, charttime, realtime, value1num,value2num from mimic2v26.manual_bp'...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    '''and subject_id =' num2str(ahe_id) ];
curs_MaBP=exec(conna,sql_MaBP);
curs_MaBP=fetch(curs_MaBP);
Data_MaBP=curs_MaBP.Data;

if length(Data_MaBP)==1
    data_sysma=0;
    data_diama=0
else
    data_sysma=Data_MaBP(:,5);%倒数第二行记录的是收缩压
    data_sysma=cell2mat(data_sysma);
    
    data_diama=Data_MaBP(:,end);%最后一行为舒张压
    data_diama=cell2mat(data_diama);
end

if length(data_sysma)==1
    MaBP_sys_max=nan;
    MaBP_sys_min=nan;
    MaBP_sys_mean=nan;
else
    MaBP_sys_max=max(data_sysma);%GCS最大值
    MaBP_sys_min=min(data_sysma);%GCS最小值
    MaBP_sys_mean=mean(data_sysma);%GCS平均值
end

if length(data_diama)==1
    MaBP_dia_max=nan;
    MaBP_dia_min=nan;
    MaBP_dia_mean=nan;
else
    MaBP_dia_max=max(data_diama);
    MaBP_dia_min=min(data_diama);
    MaBP_dia_mean=mean(data_diama);
end


%———————————————提取Manual BP mean———————————————%
sql_Ma_mean=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.manual_bp_mean '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%筛选样本对应的10个小时内的GCS
curs_Ma_mean=exec(conna,sql_Ma_mean);
curs_Ma_mean=fetch(curs_Ma_mean);
Data_Ma_mean=curs_Ma_mean.Data;

data_mamean=Data_Ma_mean(:,end);%最后一列记录的是GCS数据
data_mamean=cell2mat(data_mamean);%元胞数组转matlab矩阵

if length(data_mamean) == 7
    Ma_mean_max=nan;
    Ma_mean_min=nan;
    Ma_mean_mean=nan;
else
    Ma_mean_max=max(data_mamean);%GCS最大值
    Ma_mean_min=min(data_mamean);%GCS最小值
    Ma_mean_mean=mean(data_mamean);%GCS平均值
end

close(conna);


end

