clc
clear all
addpath(genpath('F:\Githubcode\extract_GCS'))

codepath='F:\Githubcode\extract_GCS';
ahepath='E:\E盘\nonAHE\比较小的文件备用';%存放筛选出的AHE病例的路径
srcpath='D:\Available\already\'%预处理后的原始数据的文件夹，AHE病例从此处提取
FileList_ahe=dir(ahepath);%提取所有AHE病例编号

for i=1:length(FileList_ahe)
    if FileList_ahe(i).isdir==0
        %————————————————————————————————%
        %找到样本对应的原始数据文件夹，src ，并切换路径src
        filename_ahe=FileList_ahe(i).name;%筛选出的AHE病例都是文件格式
        srcname=filename_ahe(1:6);%名称的前6个字符为病例编号，是对应的文件夹名称
        src=[srcpath,srcname];
        cd(src)
        
        %————————————————————————————————%
        %从样本对应的头文件中提取出记录的起始时间，并转换为和postgreSQL一致
        %的时间格式：starttime变量
        filename_hea=[filename_ahe(1:end-8),'.hea'];
        fid=fopen(filename_hea);
        lines=get_lines(fid);
        data=importdata(filename_hea,'\t');
        [row_hea,col_hea]=size(data);
        data_starttime=cell2mat(data(end));%头文件的最后记录的是记录的起始时间
        starttime_tmp=data_starttime(end-23:end-1);%提取出表示时间的字符串
        
        starttime=extracttime(starttime_tmp);%将提取出的时间转换成postgresql中一致的格式
        fclose(fid);
        
        %————————————————————————————————%
        %从原始数据段中，找到AHE样本对应的位置
        cd(ahepath)
        load(filename_ahe);
%         ahe_episode=AHE_tmp(:,4);%筛选到的AHE样本
        ahe_episode=nonAHE_data(:,4);%筛选到的AHE样本
        cd(src)
        
        filename_ahesrc=[filename_ahe(1:end-8),'_select.mat'];
        load(filename_ahesrc);
        ahe_source=val_final(:,4);%AHE样本的原始数据段
        startpoint  = locate_AHE( ahe_episode,ahe_source);
        clear val_final
        clear AHE_tmp
       
        
        ahe_id=str2num(srcname(2:end));
        [MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,...
            Ma_mean_min,Ma_mean_mean] = manual_BP( starttime,startpoint,ahe_id )%提取手动血压测量结果
        
        [ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,...
            nbpmean_mean] = NBP( starttime,startpoint,ahe_id )%提取无创血压测量结果
        
        [GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max] = baseinfoSQL( starttime,startpoint,ahe_id );%GCS
      
        baseinfo=[ sysnbp_max,sysnbp_min,sysnbp_mean,dianbp_max,dianbp_min,dianbp_mean,nbpmean_max,nbpmean_min,nbpmean_mean,...
                 MaBP_sys_max,MaBP_sys_min,MaBP_sys_mean,MaBP_dia_max,MaBP_dia_min,MaBP_dia_mean,Ma_mean_max,Ma_mean_min,Ma_mean_mean,...
                  GCS_max,GCS_min,GCS_mean,gender,age,weight_first,weight_min,weight_max];
        filename_baseinfo=[filename_ahe(1:end-8),'_baseinfo1.mat'];
        save(filename_baseinfo,'baseinfo');
        
        cd (codepath)
    end
   
end
