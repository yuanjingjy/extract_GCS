clc
clear all
addpath(genpath('E:\E��\Ԥ���Ѫ����\GCS��ȡ'))

codepath='E:\E��\Ԥ���Ѫ����\GCS��ȡ\';
ahepath='E:\E��\nonAHE\a����\';%���ɸѡ����AHE������·��
srcpath='D:\Available\already\'%Ԥ������ԭʼ���ݵ��ļ��У�AHE�����Ӵ˴���ȡ
FileList_ahe=dir(ahepath);%��ȡ����AHE�������

for i=1:length(FileList_ahe)
    if FileList_ahe(i).isdir==0
        %����������������������������������������������������������������%
        %�ҵ�������Ӧ��ԭʼ�����ļ��У�src �����л�·��src
        filename_ahe=FileList_ahe(i).name;%ɸѡ����AHE���������ļ���ʽ
        srcname=filename_ahe(1:6);%���Ƶ�ǰ6���ַ�Ϊ������ţ��Ƕ�Ӧ���ļ�������
        src=[srcpath,srcname];
        cd(src)
        
        %����������������������������������������������������������������%
        %��������Ӧ��ͷ�ļ�����ȡ����¼����ʼʱ�䣬��ת��Ϊ��postgreSQLһ��
        %��ʱ���ʽ��starttime����
        filename_hea=[filename_ahe(1:end-8),'.hea'];
        fid=fopen(filename_hea);
        lines=get_lines(fid);
        data=importdata(filename_hea,'\t');
        [row_hea,col_hea]=size(data);
        data_starttime=cell2mat(data(end));%ͷ�ļ�������¼���Ǽ�¼����ʼʱ��
        starttime_tmp=data_starttime(end-23:end-1);%��ȡ����ʾʱ����ַ���
        
        starttime=extracttime(starttime_tmp);%����ȡ����ʱ��ת����postgresql��һ�µĸ�ʽ
        fclose(fid);
        
        %����������������������������������������������������������������%
        %��ԭʼ���ݶ��У��ҵ�AHE������Ӧ��λ��
        cd(ahepath)
        load(filename_ahe);
%         ahe_episode=AHE_tmp(:,4);%ɸѡ����AHE����
        ahe_episode=nonAHE_data(:,4);%ɸѡ����AHE����
        cd(src)
        
        filename_ahesrc=[filename_ahe(1:end-8),'_select.mat'];
        load(filename_ahesrc);
        ahe_source=val_final(:,4);%AHE������ԭʼ���ݶ�
        startpoint  = locate_AHE( ahe_episode,ahe_source);
        clear val_final
        clear AHE_tmp
       
        
        ahe_id=str2num(srcname(2:end));
        time_point(i-2,1)=starttime;
        time_point(i-2,2)=startpoint;
        time_point(i-2,3)=ahe_id;
        
        cd (codepath)
    end
   
end
