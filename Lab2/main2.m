% Constants
Vdd = 15;
SATURATED = 1;

% Collecting images
folderMisc = image_collect('misc/', '*.tiff')';
folderTrain = image_collect('train/', '*.jpg')';
folderUser = image_collect('user/', '*.png')';
originalImages = [folderMisc; folderTrain; folderUser];

% Extract cell current samples
n = size(originalImages);
Icell = cell(n);
for k = 1:n(1)
    Icell{k} = cell_current(originalImages{k});
end

% Power consumption
Ppanel = zeros(n);
for k = 1:n(1)
    Ppanel(k) = power_consumption(Vdd, Icell{k});
end

% Applying DVS
satImages = cell(n(1),5);
satPower = zeros(n(1),5);
satDist = zeros(n(1),5);
for i = 1:n(1)
    for j = 1:1:5
        satImages{i,j} = displayed_image(Icell{i}, (((1/20)*j)+(7/10))*Vdd, SATURATED);
        satPower(i,j) = power_consumption((((1/20)*j)+(7/10))*Vdd, satImages{i,j});
        satDist(i,j) = euclidean_distance(Icell{i}, satImages{i,j}/255);
    end
end

% Thrid Flow
brightImages = cell(n(1),5);
contrastImages = cell(n(1),5);
concurrentImages = cell(n(1),5);
brightDisplay = cell(n(1),5);
contrastDisplay = cell(n(1),5);
concurrentDisplay = cell(n(1),5);
brightI = cell(n(1),5);
contrastI = cell(n(1),5);
concurrentI = cell(n(1),5);
brightPower = zeros(n(1),5);
contrastPower = zeros(n(1),5);
concurrentPower = zeros(n(1),5);
brightDist = zeros(n(1),5);
contrastDist = zeros(n(1),5);
concurrentDist = zeros(n(1),5);
for i = 1:n(1)
    for j = 1:1:5
        brightImages{i,j} = brightness_compensantion(originalImages{1}, Vdd, (((1/20)*j)+(7/10))*Vdd);
        contrastImages{i,j} = contrast_enhancement(originalImages{1}, Vdd, (((1/20)*j)+(7/10))*Vdd);
        concurrentImages{i,j} = concurrent_compensation(originalImages{1}, Vdd, (((1/20)*j)+(7/10))*Vdd);
        
        brightI{i,j} = cell_current(brightImages{i,j});
        contrastI{i,j} = cell_current(contrastImages{i,j});
        concurrentI{i,j} = cell_current(concurrentImages{i,j});
        
        brightDisplay{i,j} = displayed_image(brightI{i,j}, (((1/20)*j)+(7/10))*Vdd, SATURATED);
        contrastDisplay{i,j} = displayed_image(contrastI{i,j}, (((1/20)*j)+(7/10))*Vdd, SATURATED);
        concurrentDisplay{i,j} = displayed_image(concurrentI{i,j}, (((1/20)*j)+(7/10))*Vdd, SATURATED);
        
        brightPower(i,j) = power_consumption((((1/20)*j)+(7/10))*Vdd, brightDisplay{i,j});
        contrastPower(i,j) = power_consumption((((1/20)*j)+(7/10))*Vdd, contrastDisplay{i,j});
        concurrentPower(i,j) = power_consumption((((1/20)*j)+(7/10))*Vdd, concurrentDisplay{i,j});
        
        brightDist(i,j) = euclidean_distance(brightI{i,j}, brightDisplay{i,j}/255);
        contrastDist(i,j) = euclidean_distance(contrastI{i,j}, contrastDisplay{i,j}/255);
        concurrentDist(i,j) = euclidean_distance(concurrentI{i,j}, concurrentDisplay{i,j}/255);
    end
end