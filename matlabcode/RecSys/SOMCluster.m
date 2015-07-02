% function SOMCluster(data)

%% Variables to be modified by the user
SOMwidth = 12;
RoughFin = 2;
FinetuneFin = 1;

%% Create a batch of test data
data = [randn(300,1)+0,randn(300,1)+0;...
	randn(300,1)+10,randn(300,1)+0;...
	randn(300,1)+0,randn(300,1)+10;];
% scale the data
sData = som_data_struct(data);
sDataN = som_normalize(sData, 'var');

%% train the SOM
sMapN = som_map_struct(size(data,2), 'msize', [SOMwidth, 12],'lattice','hexa','shape','sheet'); 
sMapN = som_randinit(sDataN, sMapN);

% run the rough training phase
figure(1)
sTrainN = som_train_struct(sMapN,'phase','rough');
sMapN = som_batchtrain(sMapN,sDataN,sTrainN,'radius_fin', RoughFin, ...
		       'tracking',3,'trainlen',20);

           



% run the fine tuning phase
sTrainN = som_train_struct(sMapN,'phase','finetune');
sMapN = som_batchtrain(sMapN,sDataN,sTrainN,'radius_fin', FinetuneFin, ...
		       'tracking',3,'trainlen',200);

% The training could be done in one step using som_make.
% The som_make determines the training parameters automatically
% from data.
% sMapN = som_make(sDataN);

%% visualize the result using the U-matrix and the 
figure(2)
som_show(sMapN, 'norm', 'd');

% end