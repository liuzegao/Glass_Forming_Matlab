clear all;  clc; close all;

clear all; close all; clc;


user = input('User is ','s');
%defualt Ca composition = 30%

%i_c is now from 1:9 meaning 0% to 80% 

NBOratio_i = zeros(1,9); 
BOratio_i= zeros(1,9);
FOratio_i = zeros(1,9);
NBOratio_rand = zeros(1,9);
BOratio_rand = zeros(1,9);
FOratio_rand = zeros(1,9);
for  i_c = 1:9
    
cd (['/Users/',user,'/Dropbox/CS Glasses/C',num2str((i_c-1)*10),'S',num2str((11-i_c)*10)])

data = fopen('md300K.lammpstrj');
traj = zeros(3000,5);
for n=1:9
  tline = fgetl(data);
end
for i =10:1:3004  %%First time step 4410000 Last time step 4510000  
    tline = str2num(fgetl(data));
    traj(i-9,:)=tline;
end

%%id type x y z 
%{
variable        Al equal 1
variable        Si equal 2
variable        Na equal 3
variable        O equal 4
variable        Ca equal 5
variable        K equal 6
variable        Mg equal 7
variable        Fe equal 8
%}

L= 34.9159548486583; %%units?
N_atom = 2995;
NBO = 0;
BO = 0;
FO = 0;
N_O = 0;
N_Ca = 0;
for atom_O = 1:1:N_atom
    if traj(atom_O,2) == 5
        N_Ca=N_Ca+1;
    elseif traj(atom_O,2) == 4
        Si_around = 0;
        N_O = N_O+1;
        for atom_Si = 1:1:N_atom
            if traj(atom_Si,2) == 2
                if abs(traj(atom_Si,3)-traj(atom_O,3)) < L/2
                    x_delta = abs(traj(atom_Si,3)-traj(atom_O,3));
                else
                    x_delta = abs(L-abs(traj(atom_Si,3)-traj(atom_O,3)));      
                end
                if abs(traj(atom_Si,4)-traj(atom_O,4)) < L/2
                    y_delta = abs(traj(atom_Si,4)-traj(atom_O,4));
                else
                    y_delta = abs(L-abs(traj(atom_Si,4)-traj(atom_O,4)));
                end
                if abs(traj(atom_Si,5)-traj(atom_O,5)) < L/2
                    z_delta = abs(traj(atom_Si,5)-traj(atom_O,5));
                else
                    z_delta = abs(L-abs(traj(atom_Si,5)-traj(atom_O,5)));
                end
                    distance_min = sqrt(x_delta^2+y_delta^2+z_delta^2);               
                if distance_min <= 1.8
                    Si_around = Si_around+1;
                end
            end
        end
        if Si_around == 1  %% Question: Is only 1 Si atom around considered NBO ?
                NBO = NBO+1;
        elseif Si_around == 2
                BO = BO+1;
        elseif Si_around == 0
                FO = FO+1;       
        end      
    end
end 

%fprintf('NBO/O ratio f at C%0.0fS%0.0f is %0.3f \n', (i_c-1)*10,(11-i_c)*10,NBO/N_O);
%fprintf('BO/O ratio f at C%0.0fS%0.0f is %0.3f \n', (i_c-1)*10,(11-i_c)*10,BO/N_O);
%fprintf('FO/O ratio f at C%0.0fS%0.0f is %0.3f \n', (i_c-1)*10,(11-i_c)*10,FO/N_O);
NBOratio_i(i_c) = NBO/N_O;
BOratio_i(i_c) = BO/N_O;
FOratio_i(i_c) = FO/N_O;

N_BO=0;
N_FO=0;
if i_c < 8  
    Cutoff = 0.3;
    N_NBO=0;
else
    Cutoff = 0.7;
    N_NBO=N_O;
end
for j = 1:1:N_Ca
    if Cutoff < 0.5
        N_NBO=N_NBO+2;
    else
        N_NBO = N_NBO-1/2;
        N_FO = N_FO+1/2;
    end
end
N_BO = N_O-N_NBO-N_FO;

NBOratio_rand(i_c) = N_NBO/N_O;
BOratio_rand(i_c) = N_BO/N_O;
FOratio_rand(i_c) = N_FO/N_O;

end
i = 1:1:9;
i = (i-1)*10;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  Plot
hold on;
plot(i,NBOratio_rand,'r-*',i,BOratio_rand,'k-*',i,FOratio_rand,'b-*',i,NBOratio_i,'--or',i,BOratio_i,'--ok',i,FOratio_i,'--ob','LineWidth',1.5);
   
axis([0 80 0 1]);
title('Ordered Model Plot','fontsize',18,'fontweight','bold');
xlabel('x(Ca %)','fontsize',16);
ylabel('OxygenType/Numer of O' ,'fontsize',16);
legend('NBO Model','BO Model','FO Model','NBO simulation','BO simulation','FO simulation');
set(legend,'FontSize',11,'fontweight','bold');

hold off;






