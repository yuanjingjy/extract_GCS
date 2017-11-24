function [MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,Ma_mean_min,Ma_mean_mean] = manual_BP( starttime,startpoint,ahe_id )
%���������
%       starttime:heaͷ�ļ���¼����ʼʱ��
%       startpoint��AHE�����������ԭʼ���ݼ�¼����ʼ��
%       ahe_id:���˵�id��
%���������
%       MaBP_sys_max:�ֶ�BP�������ֵ
%       MaBP_sys_min:�ֶ�BP������Сֵ
%       MaBP_sys_mean:�ֶ�BP����ƽ��ֵ
%       MaBP_dia_max:�ֶ�BP�������ֵ
%       MaBP_dia_min:�ֶ�BP������Сֵ
%       MaBP_dia_mean:�ֶ�BP����ƽ��ֵ
%       Ma_mean_max:�ֶ�BPƽ�����ֵ
%       Ma_mean_min:�ֶ�BPƽ����Сֵ
%       Ma_mean_mean:�ֶ�BPƽ��ƽ��ֵ

%�������ܣ���ȡ��������10��Сʱ��Χ�ڲ��˵��ֶ�����Ѫѹֵ

conna=database('YJDB','postgres','yuanjing')%���ݿ�����

%����������������10��СʱAHE������Ӧ������ʱ��ڵ㡪������������%
sql_time=['select( TIMESTAMP ''' starttime '''+ interval ''' num2str(startpoint)  ' minute '' )'];
curs=exec(conna,sql_time);%hea��ʼʱ�䣬����������ʼ�㣬��Ϊɸѡ���������Ŀ�ʼʱ��

curs=fetch(curs);
Data_time=curs.Data;

T_start=Data_time{1,1};%����������Ŀ�ʼʱ��
sql_T0=['select( TIMESTAMP ''' T_start '''+ interval ''' num2str(10)  ' hour '' )'];%�����Ŀ�ʼʱ���10Сʱ
curs_T0=exec(conna,sql_T0);
curs_T0=fetch(curs_T0);
Data_T0=curs_T0.Data;
Data_T0=Data_T0{1,1};%������ʼʱ�����10Сʱ���ʱ�䣬��T0ʱ��

%��������������������������������ȡManual BP������������������������������%
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
    data_sysma=Data_MaBP(:,5);%�����ڶ��м�¼��������ѹ
    data_sysma=cell2mat(data_sysma);
    
    data_diama=Data_MaBP(:,end);%���һ��Ϊ����ѹ
    data_diama=cell2mat(data_diama);
end

if length(data_sysma)==1
    MaBP_sys_max=nan;
    MaBP_sys_min=nan;
    MaBP_sys_mean=nan;
else
    MaBP_sys_max=max(data_sysma);%GCS���ֵ
    MaBP_sys_min=min(data_sysma);%GCS��Сֵ
    MaBP_sys_mean=mean(data_sysma);%GCSƽ��ֵ
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


%��������������������������������ȡManual BP mean������������������������������%
sql_Ma_mean=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.manual_bp_mean '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%ɸѡ������Ӧ��10��Сʱ�ڵ�GCS
curs_Ma_mean=exec(conna,sql_Ma_mean);
curs_Ma_mean=fetch(curs_Ma_mean);
Data_Ma_mean=curs_Ma_mean.Data;

data_mamean=Data_Ma_mean(:,end);%���һ�м�¼����GCS����
data_mamean=cell2mat(data_mamean);%Ԫ������תmatlab����

if length(data_mamean) == 7
    Ma_mean_max=nan;
    Ma_mean_min=nan;
    Ma_mean_mean=nan;
else
    Ma_mean_max=max(data_mamean);%GCS���ֵ
    Ma_mean_min=min(data_mamean);%GCS��Сֵ
    Ma_mean_mean=mean(data_mamean);%GCSƽ��ֵ
end

close(conna);


end

