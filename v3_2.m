clc;clear;
tic;
%t_move_choice=[0,20,33,46];%�ƶ�i����λ����ʱ��
t_odd=15;%RGVΪCNC1#��3#��5#��7#һ������������ʱ��
t_even=15;%RGVΪCNC2#��4#��6#��8#һ������������ʱ��
t_wash=25;%RGV���һ�����ϵ���ϴ��ҵ����ʱ��
iter=0;%��������
cncnum1=3;cncnum2=2; 
loc=round((cncnum2+cncnum1)/2);
t_move_choice=[20:13:13*(loc-1)+7];
temp=[0];
t_move_choice=cat(2,temp,t_move_choice);
while(iter<1000)
 %%
    CNC_num_1=[]; CNC_num_2=[];    down_1st=[]; down_2nd=[];    up_1st=[];  up_2nd=[];    location_all=[]; failure_task=[];t_consumeall=[];
	CNC_order_state_1=zeros(1,cncnum1);%���ڼ�¼CNCi�������ĸ���ŵ�����
    CNC_order_state_2=zeros(1,cncnum2);%���ڼ�¼CNCi�������ĸ���ŵ�����
    CNC_1=zeros(1,cncnum1);%0��ʾCNCδ�ڼӹ�,��һ������CNC
    CNC_2=zeros(1,cncnum2);%0��ʾCNCδ�ڼӹ����ڶ�������CNC
    CNC_worktime_1=zeros(1,cncnum1);%��һ������CNC�Ѽӹ�ʱ��
    CNC_worktime_2=zeros(1,cncnum2);
    CNC_failuretime_1=zeros(1,cncnum1);%���ϼ�ʱ
    CNC_failuretime_2=zeros(1,cncnum2);%���ϼ�ʱ
    CNC_repairtime_1=zeros(1,cncnum1);%��һ�ι���ʱ�޸��õ�ʱ��
    CNC_repairtime_2=zeros(1,cncnum2);%��һ�ι���ʱ�޸��õ�ʱ��
    CNC_worktofailure_1=zeros(1,cncnum1);
    CNC_worktofailure_2=zeros(1,cncnum2);
    t_delta=0;
    time_all=0;
    location_current=1;%��ʼλ��
    failure_num=0;%���ϴ���
    n=0;
    n2=0;
    n3=0;
    
    %������һ�ι���ʱ�޸��õ�ʱ�䣬��600-1200֮��
    for i=1:cncnum1
        CNC_repairtime_1(i)=600+round((1200-600)*rand());
        %CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    for i=1:cncnum2
        CNC_repairtime_2(i)=600+round((1200-600)*rand());
        %CNC_repairtime_2(i)=600+round((1200-600)*rand());
    end
    %todo:�������ǰ�ļӹ�ʱ��
%    
    %������һ�ι���ʱ��CNC�Ѿ������˵�ʱ��
    for i=1:cncnum1
        CNC_worktofailure_1(i)=round(400*rand());
    end
    for i=1:cncnum2
        CNC_worktofailure_2(i)=round(378*rand());
    end
    %���ѡȡ�ڶ�����cnc
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
        CNC_procedure(m(i))=2;%i��ʾCNCiΪ�ڼ�������
    end
%     
% CNC_procedure=[1,2,1,2,1,2,1,2];
    record_1=find(CNC_procedure==1); %��¼ĳ̨CNC�ǵڼ�������һ�������
    record_2=find(CNC_procedure==2); %��¼ĳ̨CNC�ǵڼ������ڶ��������
    
    %���ݹ���ȷ����������ʱ��
    ss=0;t=0;
    for i=1:cncnum1+cncnum2
        if(CNC_procedure(i)==1)
            ss=ss+1;
            if(mod(i,2))
                t_1st_uAndD(ss)=t_odd;%��һ������CNC����ʱ��
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
%��һ������
        n=n+1;
        location_all(n,1)=location_current;%��¼����n����1RGV�˶�λ��
        task_procedure(n)=1;%����n���ڵ�һ������
        %��ȥCNC_1���ϣ������ڹ��������,��ȴ������ɵ�һ��
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
            
            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
            CNC_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��0
            CNC_worktime_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��ʱ��0
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
            CNC_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��0
            CNC_worktime_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
            index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_1(index)=0;%������CNC��0
                CNC_failuretime_1(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_1(index(p))=round(400*rand());
                end
            end
            index=[];
            
            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(CNC_2==2)+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
            index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_2(index)=0;%������CNC��0
                CNC_failuretime_2(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_2(index(p))=round(378*rand());
                end
            end
            index=[];
        end
        %������� 221 245    ʱ����� 217 245 �������+����   213 247   ʱ�����+����  213 248
        
        
        %��������㷨
%         numa=record_1(find(CNC_1==0));
%         sa=abs(location_current-ceil(numa/2));
%         num=numa(find(sa==min(sa)));
%         num=num(1);
        %��������㷨
        
        %�������+����
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
        %�������+����        
                
                
        %ʱ������㷨
        numa=record_1(find(CNC_1==0));
        t_consumeall=t_move_choice(ceil(record_1(find(CNC_1==0))/2))+t_odd+t_odd*(CNC_order_state_1(find(CNC_1==0))~=0);
        num=numa(find(t_consumeall==min(t_consumeall)));
        num=num(1);  
        %ʱ������㷨
%         %ʱ������㷨+����
%           numa=record_1(find(CNC_1==0));
%           t_consumeall=t_move_choice(ceil(record_1(find(CNC_1==0))/2))+t_odd+t_odd*(CNC_order_state_1(find(CNC_1==0))~=0);
%           [temp1,temp2]=sort(t_consumeall);
%           
%           while(1)%�Ը�����������ɵ�CNC_1
%                num=numa(randi(length(numa),1));
%                order=temp2(find(temp1==num));
%                if(rand()<1/sum(1:order))
%                    break
%                end     
%           end
%         %ʱ������㷨 +����         

        
        s=abs(location_current-ceil(num/2));%��Ŀ��CNC�ľ���
        %��������,��0.01�ĸ��ʣ�������ǰ����
        if(round(99*rand())==0)
            CNC_1(find(record_1==num))=2;
            failure_num=failure_num+1;
            failure_task(failure_num,1)=n;%��¼���ϵ��������
            failure_task(failure_num,2)=num;%��¼���ϵ�CNC
            failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_1(find(record_1==num));%��¼CNC���ϵĿ�ʼʱ��
            failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_1(find(record_1==num))+CNC_repairtime_1(find(record_1==num));%��¼CNC���ϵĽ���ʱ��
        end     
        
        
        
        if(CNC_order_state_1(find(record_1==num))~=0)
            n2=CNC_order_state_1(find(record_1==num));%��ǰҪ���ϵ����ϵ���ţ���ȷ����Ҫ���ڶ�����������ϵ����
            t_delta=2*t_1st_uAndD(find(record_1==num));
            down_1st(n2)=time_all+t_move_choice(s+1);%��¼����n2����1����ʱ��
            up_1st(n)=time_all+t_move_choice(s+1)+0.5*t_delta;%��¼����n+1����1����ʱ��
        else
            n2=0;
            t_delta=t_1st_uAndD(find(record_1==num));
            up_1st(n)=time_all+t_move_choice(s+1);%��¼����n+1����1����ʱ��
        end
%         time_all=time_all-0.5*delta;
        
        CNC_num_1(n)=num;%��¼����n�Ĺ���1CNC���
        if(CNC_1(find(record_1==num))==2)%��¼��ǰCNC_1��������n������
            CNC_order_state_1(find(record_1==num))=0;
        else
            CNC_order_state_1(find(record_1==num))=n;
        end
                         
        time_all=time_all+t_move_choice(s+1)+t_delta;
        location_current=ceil(num/2);%���µ�ǰλ��
        
        CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��           
        CNC_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��0
        CNC_worktime_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��ʱ��0
        if(CNC_1(find(record_1==num))==0)
            CNC_1(record_1==num)=1;%����CNC_1״̬
        end
        CNC_failuretime_1(CNC_1==2)=CNC_failuretime_1(find(CNC_1==2))+t_move_choice(s+1)+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
        index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC_1(index)=0;%������CNC��0
            CNC_failuretime_1(index)=0;%������CNC��0
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
        
        CNC_worktime_2(CNC_2==1)=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
        CNC_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��0
        CNC_worktime_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��ʱ��0
        
        

        CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta+t_move_choice(s+1);%�������������ϵ�CNC_2���ѹ���ʱ��
        index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
        if(~isempty(index))%����������������һ�εĹ�������ʱ��
            CNC_2(index)=0;%������CNC��0
            CNC_failuretime_2(index)=0;%������CNC��0
            [o,p]=size(index);
            for i=1:p
                CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                CNC_worktofailure_2(index(p))=round(378*rand());
            end
        end
        index=[];
       
        
        
        
 %%
 %�ڶ�������
         if(n2~=0)
            location_all(n2,2)=location_current;%��¼����n����2RGV�˶�λ��
            task_procedure(n2)=2;%����n���ڵڶ�������

            %ȥCNC_2���ϣ������ڹ��������,��ȴ������ɵ�һ��
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

                CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_delta;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
                CNC_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��0
                CNC_worktime_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��ʱ��0

                CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_delta;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
                CNC_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��0
                CNC_worktime_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��ʱ��0
                
                CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
                index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
                if(~isempty(index))%����������������һ�εĹ�������ʱ��
                    CNC_1(index)=0;%������CNC��0
                    CNC_failuretime_1(index)=0;%������CNC��0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                        CNC_worktofailure_1(index(p))=round(400*rand());
                    end
                end
                index=[];

                CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
                index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
                if(~isempty(index))%����������������һ�εĹ�������ʱ��
                    CNC_2(index)=0;%������CNC��0
                    CNC_failuretime_2(index)=0;%������CNC��0
                    [o,p]=size(index);
                    for i=1:p
                        CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                        CNC_worktofailure_2(index(p))=round(378*rand());
                    end
                end
                index=[];
            end

            %�������
%             numa=record_2(find(CNC_2==0));
%             sa=abs(location_current-ceil(numa/2));
%             num=numa(find(sa==min(sa)));
%             num=num(1);
            %�������
            
            %�������+����
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
            %�������+����
            %ʱ�����
            numa=record_2(find(CNC_2==0));
            t_consumeall=t_move_choice(ceil(record_2(find(CNC_2==0))/2))+t_odd+t_odd*(CNC_order_state_2(find(CNC_2==0))~=0);
            num=numa(find(t_consumeall==min(t_consumeall)));
            num=num(1);
            %ʱ�����
%             %ʱ�����+����
%             numa=record_2(find(CNC_2==0));
%             t_consumeall=t_move_choice(ceil(record_1(find(CNC_2==0))/2))+t_odd+t_odd*(CNC_order_state_2(find(CNC_2==0))~=0);
%             [temp1,temp2]=sort(t_consumeall);
%           
%            while(1)%�Ը�����������ɵ�CNC_1
%                   num=numa(randi(length(numa),1));
%                   order=temp2(find(temp1==num));
%                   if(rand()<1/sum(1:order))
%                         break
%                   end     
%            end
%             %ʱ�����+����
            s=abs(location_current-ceil(num/2));%��Ŀ��CNC�ľ���
            if(round(99*rand())==0)
                CNC_2(find(record_2==num))=2;
                failure_num=failure_num+1;
                failure_task(failure_num,1)=n2;%��¼���ϵ��������
                failure_task(failure_num,2)=num;%��¼���ϵ�CNC
                failure_task(failure_num,3)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_2(find(record_2==num));%��¼CNC���ϵĿ�ʼʱ��
                failure_task(failure_num,4)=time_all+t_move_choice(s+1)+t_delta+CNC_worktofailure_2(find(record_2==num))+CNC_repairtime_2(find(record_2==num));%��¼CNC���ϵĽ���ʱ��
            end 
            
            if(CNC_order_state_2(find(record_2==num))~=0)
                t_delta=2*t_2nd_uAndD(find(record_2==num));
                n3=CNC_order_state_2(find(record_2==num));%��ǰҪ���ϵ����ϵ���ţ���ȷ������ɵڶ�������ȴ���ϴ�����ϵ����
                down_2nd(n3)=time_all+t_move_choice(s+1);%��¼����n3����2����ʱ��
                up_2nd(n2)=time_all+t_move_choice(s+1)+0.5*t_delta;%��¼����n2����2����ʱ��
            else
                t_delta=t_2nd_uAndD(find(record_2==num));
                n3=0;
                up_2nd(n2)=time_all+t_move_choice(s+1);%��¼����n2����2����ʱ��
            end
            CNC_num_2(n2)=num;%��¼����n2�Ĺ���2CNC���
            if(CNC_2(find(record_2==num))==2)%��¼��ǰCNC_1��������n������
                CNC_order_state_2(find(record_2==num))=0;
            else
                CNC_order_state_2(find(record_2==num))=n2;
            end  
            

            time_all=time_all+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);
            location_current=ceil(num/2);%���µ�ǰλ��
            
            
            
            CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);%�����������ӹ���CNC_2���Ѽӹ�ʱ��           
            CNC_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��0
            CNC_worktime_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��ʱ��0


            CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_move_choice(s+1)+t_delta+t_wash*(n3~=0);%�����������ӹ���CNC_1���Ѽӹ�ʱ��
            CNC_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��0
            CNC_worktime_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��ʱ��0
            
            CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta+t_move_choice(s+1)+t_wash*(n3~=0);%�������������ϵ�CNC_1���ѹ���ʱ��
            index=find(CNC_failuretime_1>=CNC_repairtime_1+CNC_worktofailure_1);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_1(index)=0;%������CNC��0
                CNC_failuretime_1(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_1(index(p))=round(400*rand());
                end
            end
            index=[];

            CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta+t_move_choice(s+1)+t_wash*(n3~=0);%�������������ϵ�CNC_2���ѹ���ʱ��
            index=find(CNC_failuretime_2>=CNC_repairtime_2+CNC_worktofailure_2);
            if(~isempty(index))%����������������һ�εĹ�������ʱ��
                CNC_2(index)=0;%������CNC��0
                CNC_failuretime_2(index)=0;%������CNC��0
                [o,p]=size(index);
                for i=1:p
                    CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
                    CNC_worktofailure_2(index(p))=round(378*rand());
                end
            end
            index=[];
            if(CNC_2(find(record_2==num))==0)
                CNC_2(find(record_2==num))=1;%����CNC_1״̬
            end
            
            if( CNC_2(find(record_2==num))==2 )
                    CNC_failuretime_2(find(record_2==num))=0;
            end

%             time_all=time_all+t_wash;
%             CNC_worktime_2(find(CNC_2==1))=CNC_worktime_2(find(CNC_2==1))+t_wash;%�����������ӹ���CNC_2���Ѽӹ�ʱ��
%             CNC_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��0
%             CNC_worktime_2(find(CNC_worktime_2>=378))=0;%�ӹ���CNC��ʱ��0
% 
%             CNC_worktime_1(find(CNC_1==1))=CNC_worktime_1(find(CNC_1==1))+t_wash;%�����������ӹ���CNC_1���Ѽӹ�ʱ��
%             CNC_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��0
%             CNC_worktime_1(find(CNC_worktime_1>=400))=0;%�ӹ���CNC��ʱ��0
%             
%             CNC_failuretime_1(find(CNC_1==2))=CNC_failuretime_1(find(CNC_1==2))+t_delta;%�������������ϵ�CNC_1���ѹ���ʱ��
%             index=find(CNC_failuretime_1>=CNC_repairtime_1);
%             if(~isempty(index))%����������������һ�εĹ�������ʱ��
%                 CNC_1(index)=0;%������CNC��0
%                 CNC_failuretime_1(index)=0;%������CNC��0
%                 [o,p]=size(index);
%                 for i=1:p
%                     CNC_repairtime_1(index(p))=600+round((1200-600)*rand());
%                 end
%             end
%             index=[];
% 
%             CNC_failuretime_2(find(CNC_2==2))=CNC_failuretime_2(find(CNC_2==2))+t_delta;%�������������ϵ�CNC_2���ѹ���ʱ��
%             index=find(CNC_failuretime_2>=CNC_repairtime_2);
%             if(~isempty(index))%����������������һ�εĹ�������ʱ��
%                 CNC_2(index)=0;%������CNC��0
%                 CNC_failuretime_2(index)=0;%������CNC��0
%                 [o,p]=size(index);
%                 for i=1:p
%                     CNC_repairtime_2(index(p))=600+round((1200-600)*rand());
%                 end
%             end
%             index=[];

            %up_2nd(n2)=time_all-t_delta-t_wash;%��¼����n2����2����ʱ��
           
         end
    end
    iter=iter+1;
    location_save{iter}=location_all(:,:);%����ÿһ�ε�·��
    down_1st_save{iter}=down_1st(1,:);%����ÿһ�εĵ�һ����������ʱ��
    up_1st_save{iter}=up_1st(1,:);%����ÿһ�εĵ�һ����������ʱ��
    down_2nd_save{iter}=down_2nd(1,:);%����ÿһ�εĵڶ�����������ʱ��
    up_2nd_save{iter}=up_2nd(1,:);%����ÿһ�εĵڶ�����������ʱ��
    CNC_num_1_save{iter}=CNC_num_1(1,:);%����ÿһ�εĹ���1CNC�ӹ��������
    CNC_num_2_save{iter}=CNC_num_2(1,:);%����ÿһ�εĹ���2CNC�ӹ��������
    task_num(iter,:)=n-failure_num;%����ÿһ�ε����������
    failure_num_save(iter,:)=failure_num;%����ÿһ�εĹ��ϴ���
    failure_task_save{iter}=failure_task;%����ÿһ�εĹ��ϼ�¼
end
max(task_num)
mean(task_num)
min(task_num)
%find(task_num==max(task_num))
% filetitle='C:\Users\Arthur\Documents\MATLAB\����\result.xlsx';
% %�洢��excel��λ�ú�����
% for i=1:m
%     if isempty(location_save{i})
%     continue;
%     else
%         xlrange=['A',num2str(i)];
%         %�洢����е�λ��,һ�δ�һ��
%         xlswrite(filetitle,location_save{i},'sheet1',xlrange);
%         %�洢ÿ������
%     end
% end
toc;