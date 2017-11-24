clc
clear all
addpath(genpath('F:\Githubcode\extract_GCS'))

codepath='F:\Githubcode\extract_GCS';
ahepath='E:\E��\nonAHE\�Ƚ�С���ļ�����';%���ɸѡ����AHE������·��
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
        [MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,...
            Ma_mean_min,Ma_mean_mean] = manual_BP( starttime,startpoint,ahe_id )%��ȡ�ֶ�Ѫѹ�������
        
        [ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,...
            nbpmean_mean] = NBP( starttime,startpoint,ahe_id )%��ȡ�޴�Ѫѹ�������
        
        [GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max] = baseinfoSQL( starttime,startpoint,ahe_id );%GCS
      
        baseinfo=[ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,nbpmean_mean,...
                 MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,Ma_mean_min,Ma_mean_mean,...
                  GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max];
        filename_baseinfo=[filename_ahe(1:end-8),'_baseinfo1.mat'];
        save(filename_baseinfo,'baseinfo');
        
        cd (codepath)
    end
   
end
