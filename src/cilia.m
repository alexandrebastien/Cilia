function cilia(varargin)
% CILIA  Compute cilia orientation relative to epididymis tubule.
%   CILIA() compute cilia orientation relative to epididymis tubule. The
%   function will prompt for a 5-channels Tiff files. Channels must be:
%   1. Cilia (mCherry)
%   2. Basal cell (GFP)
%   3. DNA (DAPI)
%   4. Tubules contour (binairy mask)
%   5. Centrosomes (GFP hotspot as binairy mask)
%   The function will calculate cilia position from centrosome (GFP
%   hotspot). The orientation is computed from the convolution of a
%   rotating bar with the cilium mCherry image. The quality of the
%   calculated orientation is filtred against the prominence/FWHM ratio.
%   The final orientation result will be the angle difference between the
%   closest tubule wall tangent and the cilium. All angles are show on the
%   the final image.

    % Default parameters
    % bar length (L), MinPeakProminence (P), MaxDistance (D)
    P = 10000; L = 20; D = 400;

    % Read 5-channels tiff and red/green maxima
    hw = waitbar(0,'Reading image...');
    if isempty(varargin)
        [name,path,~] = uigetfile('*.tif;*.tiff', 'Open 4-channels tiff ...');
        if name==0; return; end
        impath = [path,name];
        [name,path,~] = uigetfile('*.csv', 'Open red maxima ...',path);
        rpath = [path,name]; 
        if name==0; return; end
        [name,path,~] = uigetfile('*.csv', 'Open green maxima ...',path);
        gpath = [path,name]; 
        if name==0; return; end
    else
        impath = varargin{1}; rpath = varargin{2}; gpath = varargin{3};
    end
    im = readTiff(impath);
    r = readtable(rpath);
    g = readtable(gpath);
    % Filtering centrosome
    waitbar(.4,hw,'Filtering centrosome...');
    ON = false(size(g,1),1);
    for ii = 1:size(g,1)
        ON(ii) = sum(sqrt((g.X(ii)-r.X).^2 + (g.Y(ii)-r.Y).^2) < 40) > 0;
    end
    g = g(ON,:);

    ON = false(size(g,1),1);
    for ii = 1:size(g,1)
        dot = find((sqrt((g.X(ii)-g.X).^2 + (g.Y(ii)-g.Y).^2) < 10));
        if length(dot)>1
            dotdist = nan(size(dot));
            for jj = 1:length(dot)
                dotdist(jj) = min(sqrt((g.X(dot(jj))-r.X).^2 + (g.Y(dot(jj))-r.Y).^2));
            end
            [~,idx] = min(dotdist);
            ON(dot(idx)) = true;
        else
            ON(dot) = true;
        end
    end
    g = g(ON,:);

    z = nan(size(g,1),1);
    out = table(z,z,z,z,'VariableNames',{'y' 'x' 'w' 'p'});
    out.y = g.Y; out.x = g.X;
    clear('g','r','z','dot','dotdist','idx','ii','jj','name','path','ON');

    % Rejeter les centroids trop prêt des bords de l'image
    out = out(out.y<size(im,1)-L & out.x<size(im,2)-L,:);
    out = out(out.y-L>0 & out.x-L>0,:);

    % Create rotating bar
    rad = rotbar('single');

    % Convoluer la bar avec les cils de l'image et récupérer l'angle maximal

    waitbar(.8,hw,'Analyzing cilia angles...');
    out.angle = nan(size(out,1),1);
    data = zeros(size(out,1),360);
    for ii = 1:size(out,1)      
        data(ii,:) = squeeze(sum(sum(rad.*double(repmat...
            (im(out.y(ii)-L:out.y(ii)+L,out.x(ii)-L:out.x(ii)+L,1),1,1,360)),1),2))';
        [~,out.angle(ii)] = max(data(ii,:));
        data(ii,:) = data(ii,make360(out.angle(ii)+(-180:179)));
    end

    % Caractériser la prominence et la largeur des peaks
    for ii = 1:size(out,1)
        [~,~,w,p] = findpeaks(data(ii,:),1:360,...
                             'MinPeakProminence',P,'Annotate','extents');
        if ~isempty(p)
            out.p(ii) = max(p); out.w(ii) = max(w);
        end
    end
    clear('w','p','data');

    % Enlever les nan (peaks trop faibles)
    out =  out(~isnan(out.p),:);

    % Trouver le contour le plus proche pour chaque point
    waitbar(.9,hw,'Compute relative angle to lumen...');
    [edgeY,edgeX] = find(im(:,:,4)>0);
    out.edgeY = nan(size(out,1),1);
    out.edgeX = nan(size(out,1),1);
    rad = rotbar('double');
    imL = zeros(size(im,1)+40,size(im,2)+40);
    imL(21:(size(im,1)+20),21:(size(im,2))+20) = im(:,:,4);
    for ii = 1:size(out,1)
        [~,idx] = min((edgeX-out.x(ii)).^2+(edgeY-out.y(ii)).^2);
        out.edgeY(ii) = edgeY(idx); out.edgeX(ii) = edgeX(idx);
        imTmp = repmat(imL((out.edgeY(ii)):(out.edgeY(ii)+40),...
                           (out.edgeX(ii)):(out.edgeX(ii)+40)),1,1,180);
        [~,out.refangle(ii)] = max(squeeze(sum(sum(rad.*imTmp,1),2)));
    end
    angle = abs(out.refangle - out.angle);
    angle(angle>=180) = angle(angle>=180) - 180;
    angle(angle>90) = 180- angle(angle>90);
    out.diffangle = angle;
    out.distance = sqrt((out.x-out.edgeX).^2+(out.y-out.edgeY).^2);
    clear('edgeY','edgeX','idx','imL','imTmp','angle');
    close(hw);

    % Output
    out = out(out.distance <= D,:);
    out.category = categorical(true(size(out,1),1),[true false],{'X','Y'});
    if isempty(varargin)
        [name,path,~] = uiputfile('*.csv', 'Sauvegarder le fichier résultat');
        writetable(out,[path,name]);
    else
        writetable(out,varargin{4});
    end
    if isempty(varargin); showCilia(im,out,L); end
end

function angle = make360(angle)
    angle(angle>360) = angle(angle>360) - 360;
    angle(angle<=0) = angle(angle<=0) + 360;
end

function im = readTiff(path)
    warning('off','MATLAB:imagesci:tiffmexutils:libtiffWarning');
    info = imfinfo(path);
    switch info(1).BitsPerSample
        case 8
            bit = 'uint8';
        case 16
            bit = 'uint16';
        case 32
            bit = 'double';
        otherwise
            bit = '';
    end
    im = zeros(info(1).Height,...
                  info(1).Width,...
                  length(info),bit);
    TifLink = Tiff(path, 'r');
    for i=1:length(info)
       TifLink.setDirectory(i);
       im(:,:,i)=TifLink.read();
    end
    TifLink.close();
    warning('on','MATLAB:imagesci:tiffmexutils:libtiffWarning');
end

function rad = rotbar(style)
    t = 3; l = 20;
    switch style
        case 'single'
            if mod(t,2)==0
                rad = zeros(2*l,2*l,360);
                rad(:,:,end) = [[zeros(l,l-t/2),ones(l,t),...
                                 zeros(l,l-t/2)];zeros(l,2*l)];
            else
                rad = zeros(2*l+1,2*l+1,360);
                rad(:,:,end) = [[zeros(l+1,(2*l+1-t)/2),ones(l+1,t),...
                                 zeros(l+1,(2*l+1-t)/2)];zeros(l,2*l+1)];
            end
            for ii = 1:360
                rad(:,:,ii) = imrotate(rad(:,:,end),-ii,'bilinear','crop');
                rad(:,:,ii) = rad(:,:,ii)/sum(sum(rad(:,:,ii)));
            end
        case 'double'
            barx = pdf(makedist('Normal',0,.2),-2:.1:2);
            bary = pdf(makedist('Normal',0,.5),-1:.1:1); bary = [bary,bary(2:end)];
            rad = (bary'*barx); rad = cat(3,zeros(41,41,179),rad);
            for ii = 1:180
                rad(:,:,ii) = imrotate(rad(:,:,end),-ii,'bilinear','crop');
                rad(:,:,ii) = rad(:,:,ii)/sum(sum(rad(:,:,ii)));
            end; clear('barx','bary');
    end
end

function showCilia(im,out,L)
    figure; image(cat(3,im(:,:,1),im(:,:,2),(2^16)*uint16(im(:,:,4)>0)-1));
    axis equal; axis off;
    for ii = 1:size(out,1)
        [y,x] = pol2cart((-out.angle(ii)/360)*2*pi,L);
        line([out.x(ii),out.x(ii)-x],[out.y(ii),out.y(ii)-y],'Color','White');
        [y,x] = pol2cart((-out.refangle(ii)/360)*2*pi,L);
        line([out.x(ii),out.x(ii)-x],[out.y(ii),out.y(ii)-y],'Color','White','LineStyle',':');
        [y,x] = pol2cart((-out.refangle(ii)/360)*2*pi,-L);
        line([out.x(ii),out.x(ii)-x],[out.y(ii),out.y(ii)-y],'Color','White','LineStyle',':');
        line([out.x(ii),out.edgeX(ii)],[out.y(ii),out.edgeY(ii)],'Color','White','LineStyle',':');
    end
end