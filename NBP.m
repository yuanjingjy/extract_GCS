function [ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,nbpmean_mean] = NBP( starttime,startpoint,ahe_id )
%���������
%       starttime:heaͷ�ļ���¼����ʼʱ��
%       startpoint��AHE�����������ԭʼ���ݼ�¼����ʼ��
%���������
%       sysnbp_max:nbp�������ֵ.
%       sysnbp_min:nbp������Сֵ
%       sysnbp_mean:nbp����ƽ��ֵ
%       dianbp_max:nbp�������ֵ
%       dianbp_min:nbp������Сֵ
%       dianbp_mean:nbp����ƽ��ֵ
%       nbpmean_max:nbpƽ�����ֵ
%       nbpmean_min:nbpƽ����Сֵ
%       nbpmean_mean:nbpƽ��ƽ��ֵ

%�������ܣ���ȡ��������10��Сʱ��Χ�ڲ����޴�Ѫѹ����

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
%��������������������������������ȡNBP������������������������������%
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
    data_sysnbp=Data_NBP(:,5);%�����ڶ��м�¼��������ѹ
    data_sysnbp=cell2mat(data_sysnbp);
    
    data_dianbp=Data_NBP(:,end);%���һ��Ϊ����ѹ
    data_dianbp=cell2mat(data_dianbp);
end



if length(data_sysnbp)==1
    sysnbp_max=nan;
    sysnbp_min=nan;
    sysnbp_mean=nan;
else
    sysnbp_max=max(data_sysnbp);%GCS���ֵ
    sysnbp_min=min(data_sysnbp);%GCS��Сֵ
    sysnbp_mean=mean(data_sysnbp);%GCSƽ��ֵ
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

%��������������������������������ȡNBP mean������������������������������%
sql_NBP_mean=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.nbp_mean '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%ɸѡ������Ӧ��10��Сʱ�ڵ�GCS
curs_NBP_mean=exec(conna,sql_NBP_mean);
curs_NBP_mean=fetch(curs_NBP_mean);
Data_NBP_mean=curs_NBP_mean.Data;

data_nbpmean=Data_NBP_mean(:,end);%���һ�м�¼����GCS����
data_nbpmean=cell2mat(data_nbpmean);%Ԫ������תmatlab����

if length(data_nbpmean)== 7
    nbpmean_max=nan;
    nbpmean_min=nan;
    nbpmean_mean=nan;
else
    nbpmean_max=max(data_nbpmean);%GCS���ֵ
    nbpmean_min=min(data_nbpmean);%GCS��Сֵ
    nbpmean_mean=mean(data_nbpmean);%GCSƽ��ֵ
end

close(conna);


end
