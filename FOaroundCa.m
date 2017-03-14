gaoclear all; close all; clc;


user = input('User is ','s');
%defualt Ca composition = 30%

%i_c is now from 1:9 meaning 0% to 80% 
Ca_around_per_FO = zeros(1,8);
 
for  i_c = 1:9
    if (i_c == 1)
        continue 
    end
switch(i_c)
    case 2    
    Cutoff = 2.45;
    case 3    
    Cutoff = 2.75;
    case 4    
    Cutoff = 2.55;
        case 5    
    Cutoff = 2.85;
        case 6    
    Cutoff = 2.95;
        case 7    
    Cutoff = 2.85;
        case 8    
    Cutoff = 2.95;
    case 9 
    Cutoff = 3.05;
end
    
cd (['/Users/',user,'/Dropbox/CS Glasses/C',num2str((i_c-1)*10),'S',num2str((11-i_c)*10)])


 fid = fopen('TestTraj.lammpstrj', 'r') ;              % Open source file.
 for i = 1:9
    fgetl(fid) ;      
 end% Read/discard line.
 buffer = fread(fid, Inf) ;                    % Read rest of the file.
 fclose(fid);
 fid = fopen('TestTraj_m.lammpstrj','w')  ;   % Open destination file.
 fwrite(fid, buffer) ;                         % Save to file.
 fclose(fid) ;
 
 traj = dlmread('TestTraj_m.lammpstrj');



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

Custom
variable        BO equal 9
variable        NBO equal 10
variable        FO equal 11
%}

L= 34.9159548486583; %%units?
N_atom = 2986;
N_FO = 0;
Ca_around = 0;
for atom_FO = 1:1:N_atom
    if traj(atom_FO,2) == 11
        N_FO = N_FO+1;
        for atom_Ca = 1:1:N_atom
            if traj(atom_Ca,2) == 5
                if abs(traj(atom_Ca,3)-traj(atom_FO,3)) < L/2
                    x_delta = abs(traj(atom_Ca,3)-traj(atom_FO,3));
                else
                    x_delta = abs(L-abs(traj(atom_Ca,3)-traj(atom_FO,3)));      
                end
                if abs(traj(atom_Ca,4)-traj(atom_FO,4)) < L/2
                    y_delta = abs(traj(atom_Ca,4)-traj(atom_FO,4));
                else
                    y_delta = abs(L-abs(traj(atom_Ca,4)-traj(atom_FO,4)));
                end
                if abs(traj(atom_Ca,5)-traj(atom_FO,5)) < L/2
                    z_delta = abs(traj(atom_Ca,5)-traj(atom_FO,5));
                else
                    z_delta = abs(L-abs(traj(atom_Ca,5)-traj(atom_FO,5)));
                end
                    distance_min = sqrt(x_delta^2+y_delta^2+z_delta^2);               
                if distance_min <= Cutoff
                    Ca_around = Ca_around+1;
                end
            end
        end    
    end
end 

fprintf('Average Ca_around/FO at C%0.0fS%0.0f is %0.3f \n', (i_c-1)*10,(11-i_c)*10,Ca_around/N_FO);

%NBOratio_i(i_c) = NBO/N_FO;
%BOratio_i(i_c) = BO/N_FO;
%FOratio_i(i_c) = FO/N_FO;
Ca_around_per_FO(i_c-1)= Ca_around/N_FO;
end

i = 2:1:9;
i = (i-1)*10;
plot(i,Ca_around_per_FO)
title('Ca around per FO atom vs Ca composition');
xlabel('x(Ca %)');
ylabel('Average Number of Ca aounrd per FO' );
%{
i = 1:1:9;
i = (i-1)*10;
NumberNBO =NBOratio_i.*N_FO;
N_Ca = 1090;
NBoratio_Model = NumberNBO./(N_Ca);
k = 1:1:9;
k = (k-1)*0.1;
NBO_theory = 2*k./(2-k);
AllOxygen = 1;
% plot(i,NBOratio_i,i,NBO_theory)
plot(i,NBOratio_i,i,BOratio_i,i,FOratio_i,i,NBoratio_Model);
a = axis;
hold on
plot(a(1:2),[1,1]);
hold off
title('NBO,BO,FO ratio vs Ca Composition');
xlabel('x(Ca %)');
ylabel('OxygenType/Numer of O' );
legend('NBO simulation','BO','FO','NBOratio Model');
%}