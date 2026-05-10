function [images,labels] = convertImage(filename,thisLabel,images,labels)
%CONVERTIMAGE Adds image pixel values and labels to corresponding matrices

% this is a flag that allow you to activate/deactivate the data augmentation
% Data augmentation will increase the size of the dataset by created variations 
%(mirroring, flipping, displacements) of each given image. This aims to produce more
% training images and, therefore, improve performance
augmented=1;

% Flag enabling contrast enhancement
enhance=1;

I=imread(filename);
if size(I,3)>1
    I=rgb2gray(I);
end
vector = reshape(I,1, size(I, 1) * size(I, 2));
vector = double(vector); % / 255;   
if enhance
    vector = enhanceContrast(vector);
end
images= [images; vector];
labels = [labels; thisLabel];

    if augmented
        
        if thisLabel==1
            Itemp =fliplr(I);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(I,1);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(I,-1);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(I,[0 1]);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(I,[0 -1]);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(fliplr(I),1);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(fliplr(I),-1);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(fliplr(I),[0 1]);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =circshift(fliplr(I),[0 -1]);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
        else
            Itemp =fliplr(I);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =flipud(I);
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];
            
            Itemp =flipud(fliplr(I));
            vector = reshape(Itemp,1, size(I, 1) * size(I, 2));
            vector = double(vector); % / 255;
            images= [images; vector];
            labels= [labels; thisLabel];      
        end

    end
end

