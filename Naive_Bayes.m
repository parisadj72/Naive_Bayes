%% Loading Data

dire = fileparts(which('Naive_Bayes.m'));

files_neg = dir(strcat(dire,'\neg\*.txt'));
files_name_neg = {files_neg.name};

for i = 1:length(files_name_neg)
    Doc_neg{i} = importdata(strcat(dire,'\neg\',files_name_neg{i}));
    if(isstruct(Doc_neg{i}))
        Doc_neg{i} = Doc_neg{i}.textdata;
    end
end

files_pos = dir(strcat(dire,'\pos\*.txt'));
files_name_pos = {files_pos.name};

for i = 1:length(files_name_pos)
    Doc_pos{i} = importdata(strcat(dire,'\pos\',files_name_pos{i}));
    if(isstruct(Doc_pos{i}))
        Doc_pos{i} = Doc_pos{i}.textdata;
    end
end


%% 80-20 Split Train and Test Data

%Train
n = 0.8*(length(files_name_pos));
for i = 1:n
    Train_Data{i,1} = Doc_pos{i};
    Train_Data{i,2} = 'p';
end
m = 0.8*(length(files_name_neg));
for i = 1:m
    Train_Data{i+n,1} = Doc_neg{i};
    Train_Data{i+n,2} = 'n';
end

%Test
o = 0.2*(length(files_name_pos));
for i = 1:o
    Test_Data{i,1} = Doc_pos{i+n};
end
p = 0.2*(length(files_name_neg));
for i = 1:p
    Test_Data{i+o,1} = Doc_neg{i+m};
end

%% Priors
P_neg = m/(length(Train_Data));
P_pos = n/(length(Train_Data));

%% words extraction

expression = '\ ';
C=[];
D=[];
for i = 1:length(Train_Data)
    if (Train_Data{i,2} == 'p')
        splitStr = regexp(Train_Data{i,1},expression,'split');
        for j = 1:length(splitStr)
            B = regexp(splitStr{j}, '\w*', 'match');
            B(cellfun('isempty', B)) = [];
            C = horzcat(C,[B{:}]);
        end
    end
    if (Train_Data{i,2} == 'n')
        splitStr = regexp(Train_Data{i,1},expression,'split');
        for j = 1:length(splitStr)
            B = regexp(splitStr{j}, '\w*', 'match');
            B(cellfun('isempty', B)) = [];
            D = horzcat(D,[B{:}]);
        end
    end
end

%% Conditional probabilities

expression2 = '_';

Str_pos = regexp(C,expression2,'split');
Str_pos = [Str_pos{:}];
Str_pos = regexp(Str_pos,'[a-z]\w+','match');
Str_pos = [Str_pos{:}];
Str_pos(cellfun('isempty', Str_pos)) = [];
Str_pos1 = unique(Str_pos);

Str_neg = regexp(D,expression2,'split');
Str_neg = [Str_neg{:}];
Str_neg = regexp(Str_neg,'[a-z]\w+','match');
Str_neg = [Str_neg{:}];
Str_neg(cellfun('isempty', Str_neg)) = [];
Str_neg1 = unique(Str_neg);

V = unique(horzcat(C,D));

%P(w(i)|pos)
for i = 1:length(Str_pos1)
    word = Str_pos1(i);
    p_pos(i) = ((length(strfind(Str_pos,word)))+1)/(length(Str_pos)+length(V));
end

%P(w(i)|neg)
for i = 1:length(Str_neg1)
    word = Str_neg1(i);
    p_neg(i) = ((length(strfind(Str_neg,word)))+1)/(length(Str_neg)+length(V));
end

%% Test
F=[];
for i = 1:length(Test_Data)
    splitStr = regexp(Test_Data{i,1},expression,'split');
    for j = 1:length(splitStr)
        E = regexp(splitStr{j}, '\w*', 'match');
        E(cellfun('isempty', E)) = [];
        F = horzcat(F,[E{:}]);
    end
    Str_train = regexp(F,expression2,'split');
    Str_train = [Str_train{:}];
    Str_train = regexp(Str_train,'[a-z]\w+','match');
    Str_train = [Str_train{:}];
    Str_train(cellfun('isempty', Str_train)) = [];
    G{i} = Str_train;
    F=[];
end

%P(neg|s)
%P(pos|s)
A=1;
B=1;
for i = 1:length(G)
    sen = G(i);
    for j = 1:length(sen)
        A = A * p_neg(strfind(Str_neg1,sen{1,1}(j)));
    end
    A = A*P_neg;
    sen = G(i);
    for j = 1:length(sen)
        B = B * p_pos(strfind(Str_pos1,sen{1,1}(j)));
    end
    B = B*P_pos;
    if(A>=B)
        G{i,2} = 'n';
    else
        G{i,2} = 'p';
    end
end






