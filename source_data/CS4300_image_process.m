clear;
% load('G.mat');
% load('P.mat');
% load('W.mat');

% parse .jpg
for i = 1: 3
    switch i
        case 1
            for j = 1:9
                im = imread(strcat('g', char(j+'0'), '.jpg'));
                im = imresize(im,[15,15]);
                im = im>50;
                X(j,:) = im(:,8);
            end
        case 2
            for j = 1:9
                im = imread(strcat('p', char(j+'0'), '.jpg'));
                im = imresize(im,[15,15]);
                im = im>50;
                X(j+9,:) = im(:,8);
            end
        case 3
            for j = 1:9
                im = imread(strcat('w', char(j+'0'), '.jpg'));
                im = imresize(im,[15,15]);
                im = im>50;
                X(j+18,:) = im(:,8);
            end
    end
end

y(1:9)=1;
y(10:18)= 2;
y(19:27)=3;
y = y';

% % G.mat parser
% for i = 1:9
%     G(i).im = imresize(G(i).im,[15,15]);
%     G(i).im = G(i).im>50;
%     G_train(i,:) = G(i).im(:);
% end
% 
% % P.mat parser
% for i = 1:9
%     P(i,1).im = imresize(P(i,1).im,[15,15]);
%     P(i,1).im = P(i,1).im>50;
%     P_train(i,:) = P(i,1).im(:);
% end
% 
% % W.mat parser
% for i = 1:9
%     G(i).im = imresize(G(i).im,[15,15]);
%     G(i).im = G(i).im>50;
%     G_train(i,:) = G(i).im(:);
% end
