#Programmed by ljq and her mysterious team member
clc;clear;
tic;
%t_move_choice=[0,20,33,46];%移动i个单位所需时间
t_odd=15;%RGV为CNC1#，3#，5#，7#一次上下料所需时间
t_even=15;%RGV为CNC2#，4#，6#，8#一次上下料所需时间
t_wash=25;%RGV完成一个物料的清洗作业所需时间
iter=0;%搜索次数
cncnum1=3;cncnum2=2; 
loc=round((cncnum2+cncnum1)/2);
t_move_choice=[20:13:13*(loc-1)+7];
temp=[0];
t_move_choice=cat(2,temp,t_move_choice);
while(iter<1000)
 %%
    CNC_num_1=[]; CNC_num_2=[];    down_1st=[]; down_2nd=[];    up_1st=[];  up_2nd=[];    location_all=[]; failure_task=[];t_consumeall=[];
	CNC_order_state_1=zeros(1,cncnum1);%用于记录CNCi正处理哪个序号的物料
    CNC_order_state_2=zeros(1,cncnum2);%用于记录CNCi正处理哪个序号的物料
    CNC_1=zeros(1,cncnum1);%0表示CNC未在加工,第一道工序CNC
    CNC_2=zeros(1,cncnum2);%0表示CNC未在加工，第二道工序CNC
    CNC_worktime_1=zeros(1,cncnum1);%第一道工序CNC已加工时间
    CNC_worktime_2=zeros(1,cncnum2);
    CNC_failuretime_1=zeros(1,cncnum1);%故障计时
    CNC_failuretime_2=zeros(1,cncnum2);%故障计时
    CNC_repairtime_1=zeros(1,cncnum1);%下一次故障时修复好的时间
    CNC_repairtime_2=zeros(1,cncnum2);%下一次故障时修复好的时间
    CNC_worktofailure_1=zeros(1,cncnum1);
    CNC_worktofailure_2=zeros(1,cncnum2);
    t_delta=0;
    time_all=0;
    location_current=1;%初始位置
    failure_num=0;%故障次数
    n=0;
    n2=0;
    n3=0;
    
    %产生下一次故障时修复好的时间，在600-1200之间
    for i=1:cncnum1
        CNC_repairtime_1(i)=600+round((1200-600)*rand());
        %CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    for i=1:cncnum2
        CNC_repairtime_2(i)=600+round((1200-600)*rand());
        %CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    %todo:加入故障前的加工时间
%    
    %产生下一次故障时，CNC已经工作了的时间
    for i=1:cncnum1
        CNC_worktofailure_1(i)=round(400*rand());
    end
    for i=1:cncnum2
        CNC_worktofailure_2(i)=round(378*rand());
    end
    %随机选取第二工序cnc
    CNC_procedure=ones(1,cncnum1+cncnum2);
    m=zeros(1,cncnum2);
    for i=1:cncnum2
        while(1)
            a=rem(round(rand()*(cncnum2+1+cncnum1)),cncnum1+cncnum2)+1;
            if(~ismember(a,m))
                m(i)=a;
                break;
            end
        end
        CNC_procedure(m(i))=2;%i表示CNCi为第几道工序
    end
%     
% CNC_procedure=[1,2,1,2,1,2,1,2];
    record_1=find(CNC_procedure==1); %记录某台CNC是第几个做第一道工序的
    record_2=find(CNC_procedure==2); %记录某台CNC是第几个做第二道工序的
    
    %根据工序确定其上下料时间
    ss=0;t=0;
    for i=1:cncnum1+cncnum2
        if(CNC_procedure(i)==1)
            ss=ss+1;
            if(mod(i,2))
                t_1st_uAndD(ss)=t_odd;%第一道工序CNC上料时间
            else
                t_1st_uAndD(ss)=t_even;
            end
        else
            t=t+1;
            if(mod(i,2))
                t_2nd_uAndD(t)=t_odd;
            else
                t_2nd_uAndD(t)=t_even;
            end            
        end
    end
      
    while(time_all<=8*3600)
%%
%第一道工序
        n=n+1;
        location_all(n,1)=location_current;%记录任务n工序1RGV运动位置
        task_procedure(n)=1;%任务n处于第一道工序
        %先去CNC_1上料，若都在工作或故障,则等待最快完成的一个
        while(isempty(find(CNC_1==0)))
            a=max(CNC_worktime_1);
            t_delta_1=400-a;
            
            a=CNC_repairtime_1(find(CNC_1==2))+CNC_worktofailure_1(find(CNC_1==2))-CNC_failuretime_1(find(CNC_1==2));
            if(~isempty(a))
                t_delta_2=min(a);
            else 
                t_delta_2=1e+4;
            end
            
            t_delta=min(t_delta_1,t_delta_2);
            
            time_all=time_all+t_delta;
            
            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%更新其他正加工的CNC_1的已加工时间
            CNC_1(find(CNC_worktime_1>=400))=0;%加工完CNC置0
            CNC_worktime_1(find(CNC_worktime_1>=400))=0;%加工完CNC计时置0
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%更新其他正加工的CNC_2的已加工时间
            CNC_2(find(CNC_worktime_2>=378))=0;%加工完CNC置0
            CNC_worktime_2(find(CNC_worktime_2>=378))=0;%加工完CNC计时置0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%更新其他正故障的CNC_1的已故障时间
            index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
            if(~isempty(index))%修理完重新生成下一次的故障修理时间
                CNC_1(index)=0;%修理完CNC置0
                CNC_failuretime_1(index)=0;%修理完CNC置0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_1(index(p))=round(400*rand());
                end
            end
            index=[];
            
            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(CNC_2==2)+t_delta;%更新其他正故障的CNC_2的已故障时间
            index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
            if(~isempty(index))%修理完重新生成下一次的故障修理时间
                CNC_2(index)=0;%修理完CNC置0
                CNC_failuretime_2(index)=0;%修理完CNC置0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_2(index(p))=round(378*rand());
                end
            end
            index=[];
        end
        %距离最近 221 245    时间最短 217 245 距离最短+概率   213 247   时间最短+概率  213 248
        
        
        %距离最近算法
%         numa=record_1(find(CNC_1==0));
%         sa=abs(location_current-ceil(numa/2));
%         num=numa(find(sa==min(sa)));
%         num=num(1);
        %距离最近算法
        
        %距离最短+概率
%         numa=record_1(find(CNC_1==0));
%         sa=abs(location_current-ceil(numa/2));
%         [temp1,temp2]=sort(sa);
%         while(1)
%             num=numa(randi(length(numa),1));
%             order=temp2(find(temp1==num));
%             if(rand()<1/sum(1:order))
%                 break
%             end
%         end
        %距离最短+概率        
                
                
        %时间最短算法
        numa=record_1(find(CNC_1==0));
        t_consumeall=t_move_choice(ceil(record_1(find(CNC_1==0))/2))+t_odd+t_odd*(CNC_order_state_1(find(CNC_1==0))~=0);
        num=numa(find(t_consumeall==min(t_consumeall)));
        num=num(1);  
        %时间最短算法
%         %时间最短算法+概率
%           numa=record_1(find(CNC_1==0));
%           t_consumeall=t_move_choice(ceil(record_1(find(CNC_1==0))/2))+t_odd+t_odd*(CNC_order_state_1(find(CNC_1==0))~=0);
%           [temp1,temp2]=sort(t_consumeall);
%           
%           while(1)%以概率搜索已完成的CNC_1
%                num=numa(randi(length(numa),1));
%                order=temp2(find(temp1==num));
%                if(rand()<1/sum(1:order))
%                    break
%                end     
%           end
%         %时间最短算法 +概率         

        
        s=abs(location_current-ceil(num/2));%与目标CNC的距离
        %发生故障,以0.01的概率，放弃当前任务
        if(round(99*rand())==0)
            CNC_1(find(record_1==num))=2;
            failure_num=failure_num+1;
            failure_task(failure_num,1)=n;%记录故障的物料序号
            failure_task(failure_num,2)=num;%记录故障的CNC
            failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_1(find(record_1==num));%记录CNC故障的开始时间
            failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_1(find(record_1==num))+CNC_repairtime_1(find(record_1==num));%记录CNC故障的结束时间
        end     
        
        
        
        if(CNC_order_state_1(find(record_1==num))~=0)
            n2=CNC_order_state_1(find(record_1==num));%当前要下料的物料的序号，即确认正要做第二道工序的物料的序号
            t_delta=2*t_1st_uAndD(find(record_1==num));
            down_1st(n2)=time_all+t_move_choice(s+1);%记录任务n2工序1下料时间
            up_1st(n)=time_all+t_move_choice(s+1)+0.5*t_delta;%记录任务n+1工序1上料时间
        else
            n2=0;
            t_delta=t_1st_uAndD(find(record_1==num));
            up_1st(n)=time_all+t_move_choice(s+1);%记录任务n+1工序1上料时间
        end
%         time_all=time_all-0.5*delta;
        
        CNC_num_1(n)=num;%记录任务n的工序1CNC编号
        if(CNC_1(find(record_1==num))==2)%记录当前CNC_1正在做第n个物料
            CNC_order_state_1(find(record_1==num))=0;
        else
            CNC_order_state_1(find(record_1==num))=n;
        end
                         
        time_all=time_all+t_move_choice(s+1)+t_delta;
        location_current=ceil(num/2);%更新当前位置
        
        CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_1的已加工时间           
        CNC_1(find(CNC_worktime_1>=400))=0;%加工完CNC置0
        CNC_worktime_1(find(CNC_worktime_1>=400))=0;%加工完CNC计时置0
        if(CNC_1(find(record_1==num))==0)
            CNC_1(record_1==num)=1;%更新CNC_1状态
        end
        CNC_failuretime_1(CNC_1==2)=CNC_failuretime_1(find(CNC_1==2))+t_move_choice(s+1)+t_delta;%更新其他正故障的CNC_1的已故障时间
        index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
        if(~isempty(index))%修理完重新生成下一次的故障修理时间
            CNC_1(index)=0;%修理完CNC置0
            CNC_failuretime_1(index)=0;%修理完CNC置0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                CNC_worktofailure_1(index(p))=round(400*rand());
            end
        end
        
        index=[];
             
        if( CNC_1(find(record_1==num))==2 )
            CNC_failuretime_1(record_1==num)=0;
        end
        
        CNC_worktime_2(CNC_2==1)=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%更新其他正加工的CNC_2的已加工时间
        CNC_2(find(CNC_worktime_2>=378))=0;%加工完CNC置0
        CNC_worktime_2(find(CNC_worktime_2>=378))=0;%加工完CNC计时置0
        
        

        CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta+t_move_choice(s+1);%更新其他正故障的CNC_2的已故障时间
        index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
        if(~isempty(index))%修理完重新生成下一次的故障修理时间
            CNC_2(index)=0;%修理完CNC置0
            CNC_failuretime_2(index)=0;%修理完CNC置0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                CNC_worktofailure_2(index(p))=round(378*rand());
            end
        end
        index=[];
       
        
        
        
 %%
 %第二道工序
         if(n2~=0)
            location_all(n2,2)=location_current;%记录任务n工序2RGV运动位置
            task_procedure(n2)=2;%任务n处于第二道工序

            %去CNC_2上料，若都在工作或故障,则等待最快完成的一个
            while(isempty(find(CNC_2==0)))
                a=max(CNC_worktime_2);
                t_delta=378-a;
                
                a=CNC_repairtime_2(find(CNC_2==2))+CNC_worktofailure_2(find(CNC_2==2))-CNC_failuretime_2(find(CNC_2==2));
                if(~isempty(a))
                    t_delta_2=min(a);
                else 
                    t_delta_2=1e+4;
                end

                t_delta=min(t_delta_1,t_delta_2);

                time_all=time_all+t_delta;

                CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%更新其他正加工的CNC_2的已加工时间
                CNC_2(find(CNC_worktime_2>=378))=0;%加工完CNC置0
                CNC_worktime_2(find(CNC_worktime_2>=378))=0;%加工完CNC计时置0

                CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%更新其他正加工的CNC_1的已加工时间
                CNC_1(find(CNC_worktime_1>=400))=0;%加工完CNC置0
                CNC_worktime_1(find(CNC_worktime_1>=400))=0;%加工完CNC计时置0
                
                CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%更新其他正故障的CNC_1的已故障时间
                index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
                if(~isempty(index))%修理完重新生成下一次的故障修理时间
                    CNC_1(index)=0;%修理完CNC置0
                    CNC_failuretime_1(index)=0;%修理完CNC置0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                        CNC_worktofailure_1(index(p))=round(400*rand());
                    end
                end
                index=[];

                CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%更新其他正故障的CNC_2的已故障时间
                index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
                if(~isempty(index))%修理完重新生成下一次的故障修理时间
                    CNC_2(index)=0;%修理完CNC置0
                    CNC_failuretime_2(index)=0;%修理完CNC置0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                        CNC_worktofailure_2(index(p))=round(378*rand());
                    end
                end
                index=[];
            end

            %距离最短
%             numa=record_2(find(CNC_2==0));
%             sa=abs(location_current-ceil(numa/2));
%             num=numa(find(sa==min(sa)));
%             num=num(1);
            %距离最短
            
            %距离最短+概率
%             numa=record_2(find(CNC_2==0));
%             sa=abs(location_current-ceil(numa/2));
%             [temp1,temp2]=sort(sa);
%             while(1)
%                  num=numa(randi(length(numa),1));
%                  order=temp2(find(temp1==num));
%                  if(rand()<1/sum(1:order))
%                       break
%                  end
%             end
            %距离最短+概率
            %时间最短
            numa=record_2(find(CNC_2==0));
            t_consumeall=t_move_choice(ceil(record_2(find(CNC_2==0))/2))+t_odd+t_odd*(CNC_order_state_2(find(CNC_2==0))~=0);
            num=numa(find(t_consumeall==min(t_consumeall)));
            num=num(1);
            %时间最短
%             %时间最短+概率
%             numa=record_2(find(CNC_2==0));
%             t_consumeall=t_move_choice(ceil(record_1(find(CNC_2==0))/2))+t_odd+t_odd*(CNC_order_state_2(find(CNC_2==0))~=0);
%             [temp1,temp2]=sort(t_consumeall);
%           
%            while(1)%以概率搜索已完成的CNC_1
%                   num=numa(randi(length(numa),1));
%                   order=temp2(find(temp1==num));
%                   if(rand()<1/sum(1:order))
%                         break
%                   end     
%            end
%             %时间最短+概率
            s=abs(location_current-ceil(num/2));%与目标CNC的距离
            if(round(99*rand())==0)
                CNC_2(find(record_2==num))=2;
                failure_num=failure_num+1;
                failure_task(failure_num,1)=n2;%记录故障的物料序号
                failure_task(failure_num,2)=num;%记录故障的CNC
                failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_2(find(record_2==num));%记录CNC故障的开始时间
                failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_2(find(record_2==num))+CNC_repairtime_2(find(record_2==num));%记录CNC故障的结束时间
            end 
            
            if(CNC_order_state_2(find(record_2==num))~=0)
                t_delta=2*t_2nd_uAndD(find(record_2==num));
                n3=CNC_order_state_2(find(record_2==num));%当前要下料的物料的序号，即确认已完成第二道工序等待清洗的物料的序号
                down_2nd(n3)=time_all+t_move_choice(s+1);%记录任务n3工序2下料时间
                up_2nd(n2)=time_all+t_move_choice(s+1)+0.5*t_delta;%记录任务n2工序2上料时间
            else
                t_delta=t_2nd_uAndD(find(record_2==num));
                n3=0;
                up_2nd(n2)=time_all+t_move_choice(s+1);%记录任务n2工序2上料时间
            end
            CNC_num_2(n2)=num;%记录任务n2的工序2CNC编号
            if(CNC_2(find(record_2==num))==2)%记录当前CNC_1正在做第n个物料
                CNC_order_state_2(find(record_2==num))=0;
            else
                CNC_order_state_2(find(record_2==num))=n2;
            end  
            

            time_all=time_all+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);
            location_current=ceil(num/2);%更新当前位置
            
            
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);%更新其他正加工的CNC_2的已加工时间           
            CNC_2(find(CNC_worktime_2>=378))=0;%加工完CNC置0
            CNC_worktime_2(find(CNC_worktime_2>=378))=0;%加工完CNC计时置0


            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);%更新其他正加工的CNC_1的已加工时间
            CNC_1(find(CNC_worktime_1>=400))=0;%加工完CNC置0
            CNC_worktime_1(find(CNC_worktime_1>=400))=0;%加工完CNC计时置0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta+t_move_choice(s+1)+t_wash*(n3~=0);%更新其他正故障的CNC_1的已故障时间
            index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
            if(~isempty(index))%修理完重新生成下一次的故障修理时间
                CNC_1(index)=0;%修理完CNC置0
                CNC_failuretime_1(index)=0;%修理完CNC置0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_1(index(p))=round(400*rand());
                end
            end
            index=[];

            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta+t_move_choice(s+1)+t_wash*(n3~=0);%更新其他正故障的CNC_2的已故障时间
            index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
            if(~isempty(index))%修理完重新生成下一次的故障修理时间
                CNC_2(index)=0;%修理完CNC置0
                CNC_failuretime_2(index)=0;%修理完CNC置0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_2(index(p))=round(378*rand());
                end
            end
            index=[];
            if(CNC_2(find(record_2==num))==0)
                CNC_2(find(record_2==num))=1;%更新CNC_1状态
            end
            
            if( CNC_2(find(record_2==num))==2 )
                    CNC_failuretime_2(find(record_2==num))=0;
            end

%             time_all=time_all+t_wash;
%             CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_wash;%更新其他正加工的CNC_2的已加工时间
%             CNC_2(find(CNC_worktime_2>=378))=0;%加工完CNC置0
%             CNC_worktime_2(find(CNC_worktime_2>=378))=0;%加工完CNC计时置0
% 
%             CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_wash;%更新其他正加工的CNC_1的已加工时间
%             CNC_1(find(CNC_worktime_1>=400))=0;%加工完CNC置0
%             CNC_worktime_1(find(CNC_worktime_1>=400))=0;%加工完CNC计时置0
%             
%             CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%更新其他正故障的CNC_1的已故障时间
%             index=find(CNC_failuretime_1>=CNC_repairtime_1);
%             if(~isempty(index))%修理完重新生成下一次的故障修理时间
%                 CNC_1(index)=0;%修理完CNC置0
%                 CNC_failuretime_1(index)=0;%修理完CNC置0
%                 [o,p]=size(index);
%                 for i=1:p
%                     CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
%                 end
%             end
%             index=[];
% 
%             CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%更新其他正故障的CNC_2的已故障时间
%             index=find(CNC_failuretime_2>=CNC_repairtime_2);
%             if(~isempty(index))%修理完重新生成下一次的故障修理时间
%                 CNC_2(index)=0;%修理完CNC置0
%                 CNC_failuretime_2(index)=0;%修理完CNC置0
%                 [o,p]=size(index);
%                 for i=1:p
%                     CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
%                 end
%             end
%             index=[];

            %up_2nd(n2)=time_all-t_delta-t_wash;%记录任务n2工序2上料时间
           
         end
    end
    iter=iter+1;
    location_save{iter}=location_all(:,:);%保存每一次的路径
    down_1st_save{iter}=down_1st(1,:);%保存每一次的第一道工序下料时间
    up_1st_save{iter}=up_1st(1,:);%保存每一次的第一道工序上料时间
    down_2nd_save{iter}=down_2nd(1,:);%保存每一次的第二道工序下料时间
    up_2nd_save{iter}=up_2nd(1,:);%保存每一次的第二道工序上料时间
    CNC_num_1_save{iter}=CNC_num_1(1,:);%保存每一次的工序1CNC加工编号序列
    CNC_num_2_save{iter}=CNC_num_2(1,:);%保存每一次的工序2CNC加工编号序列
    task_num(iter,:)=n-failure_num;%保存每一次的完成物料数
    failure_num_save(iter,:)=failure_num;%保存每一次的故障次数
    failure_task_save{iter}=failure_task;%保存每一次的故障记录
end
max(task_num)
mean(task_num)
min(task_num)
%find(task_num==max(task_num))
% filetitle='C:\Users\Arthur\Documents\MATLAB\国赛\result.xlsx';
% %存储的excel的位置和名称
% for i=1:m
%     if isempty(location_save{i})
%     continue;
%     else
%         xlrange=['A',num2str(i)];
%         %存储表格中的位置,一次存一行
%         xlswrite(filetitle,location_save{i},'sheet1',xlrange);
%         %存储每组数据
%     end
% end
toc;
