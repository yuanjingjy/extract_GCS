function [GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max,height] = baseinfoSQL( starttime,startpoint,ahe_id )
%���������
%       starttime:heaͷ�ļ���¼����ʼʱ��
%       startpoint��AHE�����������ԭʼ���ݼ�¼����ʼ��
%���������

%       GCS_max:��ѡʱ�䷶Χ��GCS�����ֵ��
%       GCS_min����ѡʱ�䷶Χ��GCS����Сֵ
%       GCS_mean����ѡʱ�䷶Χ��GCS��ƽ��ֵ
%       gender���Ա�
%       age������
%       weight_first������ICUʱ������
%       weight_min��������ICU�ڼ����ص���Сֵ
%       weight_max��������ICU�ڼ����ص����ֵ
%       height��������߼�¼
%�������ܣ���ȡ��������10��Сʱ��Χ�ڲ��˵�GCS���Ա����䡢���ء���ߵ���Ϣ

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

%��������������������������������ȡGCS������������������������������%
sql_GCS=['select subject_id, icustay_id,charttime, realtime, value1num from mimic2v26.gcs '...
    'where realtime between TIMESTAMP ''' T_start ''' and TIMESTAMP ''' Data_T0 ...
    ''' and subject_id = ' num2str(ahe_id)];%ɸѡ������Ӧ��10��Сʱ�ڵ�GCS
curs_GCS=exec(conna,sql_GCS);
curs_GCS=fetch(curs_GCS);
Data_GCS=curs_GCS.Data;

data_gcs=Data_GCS(:,end);%���һ�м�¼����GCS����
data_gcs=cell2mat(data_gcs);%Ԫ������תmatlab����

if length(data_gcs)==7
    GCS_max=nan;
    GCS_min=nan;
    GCS_mean=nan;
else
    GCS_max=max(data_gcs);%GCS���ֵ
    GCS_min=min(data_gcs);%GCS��Сֵ
    GCS_mean=mean(data_gcs);%GCSƽ��ֵ
end


%��ȡ��������Ӧ��icustay_id��
% icuid=Data_GCS(1,2);
% icuid=cell2mat(icuid);

%����������������ɸѡ�Ա����䡢��ߡ����صȻ�����Ϣ����������������%
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

%��������������������ȡ�Ա𡪡�����������������%
gender_tmp=Data_baseinfo(:,3);
gender_tmp=cell2mat(gender_tmp);

[m,n]=find(gender_tmp);

gender_str=gender_tmp(m(1),n(1));

if strcmp(gender_str,'F')
    tmp(1,1)=1;%Ů����1��ʾ
end
if strcmp( gender_str,'M')
    tmp(1,1)=2;%������2��ʾ
end
gender=tmp(1,1);
%������������������ȡ���䡪����������������%
age_tmp=Data_baseinfo(:,4);
age_tmp=cell2mat(age_tmp);

tmp(1,2)=mean(age_tmp);

age=tmp(1,2);
%------------------��ȡ����---------------%
weight=Data_baseinfo(:,5:7);
weight=cell2mat(weight);
tmp(1,3:5)=mean(weight);

weight_first=tmp(1,3);
weight_min=tmp(1,4);
weight_max=tmp(1,5);
% %-----------------��ȡ���----------------%
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

