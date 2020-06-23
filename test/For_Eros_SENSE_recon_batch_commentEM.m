
warning('off','MATLAB:nearlySingularMatrix')
warning('off','MATLAB:divideByZero')

% -------------------
%  GENERAL SETTINGS
% -------------------
which_slice = 1;           % select which slice to use in rawdata with multiple slices
normalize_sens = 1;        % 1 --> normalize coil sensitivities
mask_sens = 1;
simple_sens = 1;           % 1 --> coil sensitivities calculated as the coil images normalized by the RSS reconstruction (FAST)
                           % 0 --> coil sensitivities manipulated to remove noise with the method used in Siemens scanners (SLOW)
remove_oversampling = 1;
decimate_data = 1;         % 1 --> decimate fully sampled data to simulate acceleration
user_label = 'RL';         % user signature
warningsoffflag = 1;       % 1 --> set off some MATLAB warnings

% ---------------
%  PLOT SETTINGS
% ---------------
plot_reconstructed_image = 1;
plot_g_factor = 1;
plot_coil_sensitivities = 0;
used_colormap = 'parula';
show_colorbar = 1;
usedatamask = 1; % mask data for better g-factor display

acc_set_1D = [2 1;3 1;4 1; 5 1];             % 1D acceleration factor [Phase Freq]
acc_set_2D = [2 2;3 3;4 4];                 % 2D acceleration factor [Phase Freq]

% NOISE and DATA files. If [] the user will be asked to browse the disks and select them

noise_file = [];
data_file = [];

% ----------------
%  READ NOISE FILE
% ----------------
if isempty(noise_file)
    [noise_file,noise_path] = uigetfile('*.dat','Select the noise raw file');
    disp('***  loading noise data from:');
    disp(['   ' fullfile(noise_path,noise_file)]);
    disp('---');
    noise_file = fullfile(noise_path,noise_file);
end
image_obj = mapVBVD(noise_file,'doAverage');
kdata = image_obj.image();
clear image_obj
if size(kdata,2) > 1
    noiserawdata = permute(squeeze(kdata(:,:,:,:,which_slice,:,:,:,:,:,:,:,:,:,:,:)),[1,3,2]); % [nfreq nphase ncoil]
else % single coil case
    noiserawdata = squeeze(kdata(:,:,:,:,which_slice,:,:,:,:,:,:,:,:,:,:,:)); % [nfreq nphase]
end

% ------------------
%  READ SIGNAL FILE
% ------------------
if isempty(data_file)
    [data_file,data_path] = uigetfile('*.dat','Select the data raw file');
    disp('***  loading MR signal from:');
    disp(['   ' fullfile(data_path,data_file)]);
    disp('---');
    data_file = fullfile(data_path,data_file);
end
image_obj = mapVBVD(data_file,'removeos','doAverage');
kdata = image_obj.image();
clear image_obj
if size(kdata,2) > 1
    signalrawdata = permute(squeeze(kdata(:,:,:,:,which_slice,:,:,:,:,:,:,:,:,:,:,:)),[1,3,2]); % [nfreq nphase ncoil]
else % single coil case
    signalrawdata = squeeze(kdata(:,:,:,:,which_slice,:,:,:,:,:,:,:,:,:,:,:)); % [nfreq nphase]
end
clear kdata

nf = size(signalrawdata,1);
np = size(signalrawdata,2);
nc = size(signalrawdata,3);

% --------------------
%  COIL SENSITIVITIES
% --------------------

b1map = MRifft(signalrawdata,[1,2]);
ref_img = sqrt(sum(abs(b1map).^2,3));
figure
colormap('gray');
imagesc(abs(ref_img));  title('SoS Image'); axis off; axis image;
if normalize_sens
    b1map = b1map./repmat(ref_img,[1 1 nc]);
end

%masktest = ref_img > 6.0E-8; % THIS IS IMPORTANT AND WE SHOULD FIND A WAY TO GENERALIZE IT (IT NEEDS TO MASK THE OBJECT FROM THE BACKGROUND)

masktest = ref_img > 6.0E-5; % THIS IS IMPORTANT AND WE SHOULD FIND A WAY TO GENERALIZE IT (IT NEEDS TO MASK THE OBJECT FROM THE BACKGROUND)
% masktest = ones(size(masktest));
if mask_sens
    b1map = b1map.*repmat(masktest,[1 1 nc]);
end

b1map = permute(b1map,[3,2,1]);

if plot_coil_sensitivities
    if (nc/4 < 1)
        figure;
        set(gcf,'name','Coil Sensitivities');
        for ichan = 1:nc
            subplot(1,nc,ichan);
            imshow(abs(squeeze(b1map(ichan,:,:))),[]);
            title(['Chan ', num2str(ichan)]);
            
        end
        colormap(used_colormap);
    else
        figure;
        set(gcf,'name','Coil Sensitivities');
        for ichan = 1:nc
            if mod(nc,4) == 0
                subplot(4,nc/4,ichan);
            else
                subplot(4,floor(nc/4)+1,ichan);
            end
            imshow(abs(squeeze(b1map(ichan,:,:))),[]);
            title(['Chan ', num2str(ichan)]);
        end
        colormap(used_colormap);
    end
end

noise_samples = reshape(noiserawdata,[2*nf*np nc]);
noise_samples = noise_samples.';
    
% Compute Noise Covariance Matrix from Noise Samples
Rn = 1/size(noise_samples,2)*(noise_samples*noise_samples');

% Compute "decorrelation" Matrix L
L               = chol(Rn,'lower');
L               = inv(L);

raw_data = permute(signalrawdata,[3,2,1]);
raw_data = L*raw_data(:,:);
raw_data = reshape(raw_data,nc,np,nf);

b1map = L*b1map(:,:);
b1map = reshape(b1map,nc,np,nf);

noise_samples = L*noise_samples(:,:);

% Our new Covariance Matrix is now an Identity-Matrix
% because we have generated uncorrelated channels with std(noise) = 1
% (You can verify this by computing cov(noise'))
Rn = eye(nc);

% 1D Acceleration %
% 1D Acceleration %
for iacc = 1:length(acc_set_1D)
    
    R = acc_set_1D(iacc);
    
    % ---------------------------------------------------
    % 2: Do SENSE Reconstruction
    %
    display('SENSE-Reconstruction ...');
    
    % Generate undersampled acquisition
    
    %%EROS decimato in maniera diversa 
    
    k_temp              = zeros(size(raw_data));
    k_temp(:,1:R:np,:)  = raw_data(:,1:R:np,:);
    
    % Generate aliased multi-channel images
    aliased_image = ifftshift(ifft(ifftshift(k_temp,3),[],3),3);
    aliased_image = ifftshift(ifft(ifftshift(aliased_image,2),[],2),2);
    
    % Do Reconstruction and g-Factor calculation
    % [sense_image,g_sense] = opensense(aliased_image(:,1:np/R,:),b1map,R);
    
    imfold = aliased_image(:,1:floor(np/R),:);
    [nc,npfold,nffold]=size(imfold);
    
    for x=1:nf
        for y=1:floor(np./R)
            
            s=squeeze(b1map(:,y:floor(np./R):np,x));   %Gather the aliased pixels into the sensitivity matrix
            %         s=squeeze(b1map(:,y:np./R:np,x));   %Gather the aliased pixels into the sensitivity matrix
            
            
            u=pinv(s);                          %psuedoinverse of coil sensitivity matrix
            
            pp=u*squeeze(imfold(:,y,x));        %do the reconstruction of this set of pixels
            sense_image(y:floor(np./R):np,x)=pp;            %put this recon into the right places in the image
            %         sense_image(y:np./R:np,x)=pp;            %put this recon into the right places in the image
            
            g_sense(y:floor(np./R):np,x)=sqrt(abs(diag(pinv(s'*s)).*diag(s'*s)));   %Calculate g-factor using
            %         g_sense(y:np./R:np,x)=sqrt(abs(diag(pinv(s'*s)).*diag(s'*s)));   %Calculate g-factor using formula from Pruessmann, et al
            
        end
    end
    

end

% 2D Acceleration %
for i2acc = 1:length(acc_set_2D)
        
    Rp = acc_set_2D(i2acc,1);
    Rf = acc_set_2D(i2acc,2);
    
    % ---------------------------------------------------
    % 2: Do SENSE Reconstruction
    %
    display('SENSE-Reconstruction ...');
    
    % Generate undersampled acquisition
    
    k_temp              = zeros(size(raw_data));
    k_temp(:,1:Rp:np,1:Rf:nf)  = raw_data(:,1:Rp:np,1:Rf:nf);
    
    % Generate aliased multi-channel images
    aliased_image = ifftshift(ifft(ifftshift(k_temp,3),[],3),3);
    aliased_image = ifftshift(ifft(ifftshift(aliased_image,2),[],2),2);
    
    % Do Reconstruction and g-Factor calculation
    % [sense_image,g_sense] = opensense(aliased_image(:,1:np/R,:),b1map,R);
    
    imfold = aliased_image(:,1:floor(np/Rp),1:floor(nf/Rf));
    [nc,npfold,nffold]=size(imfold);
    
    for x=1:floor(nf./Rf)
        for y=1:floor(np./Rp)
            
            s_temp=squeeze(b1map(:,y:floor(np./Rp):np,x:floor(nf./Rf):nf));   %Gather the aliased pixels into the sensitivity matrix
            %         s=squeeze(b1map(:,y:np./R:np,x));   %Gather the aliased pixels into the sensitivity matrix
            
            s = reshape(s_temp,[nc size(s_temp,2)*size(s_temp,3)]);
            u=pinv(s);                          %psuedoinverse of coil sensitivity matrix
            
            pp=u*squeeze(imfold(:,y,x));        %do the reconstruction of this set of pixels
            sense_image(y:floor(np./Rp):np,x:floor(nf./Rf):nf)=reshape(pp,[size(s_temp,2) size(s_temp,3)]);            %put this recon into the right places in the image
            %         sense_image(y:np./R:np,x)=pp;            %put this recon into the right places in the image
            
            g_sense(y:floor(np./Rp):np,x:floor(nf./Rf):nf) = reshape(sqrt(abs(diag(pinv(s'*s)).*diag(s'*s))),[size(s_temp,2) size(s_temp,3)]);   %Calculate g-factor using
            %         g_sense(y:np./R:np,x)=sqrt(abs(diag(pinv(s'*s)).*diag(s'*s)));   %Calculate g-factor using formula from Pruessmann, et al
            
        end
    end
    
    
    % -------------------------------------------------------------------------
    % PLOTS
    
    if plot_reconstructed_image
        % Display Reconstructed images
        imagetitle = ['SENSE Reconstructed Image - Acc = ' num2str(Rp) ' X ' num2str(Rf)];
        figure
        set(gcf,'Name',imagetitle);
        colormap('gray');
        imagesc(abs(sense_image));  title(imagetitle); axis off; axis image;
    end
    
    if plot_g_factor
        % Display g-Factors
        gtitle = ['g-Factor - Acc = ' num2str(Rp) ' X ' num2str(Rf)];
        figure
        set(gcf,'Name',gtitle);
        colormap('parula');
        imagesc(abs(g_sense),[0.8 max(g_sense(:))]); title(gtitle); axis off; axis image; colorbar
        
        % Display 1/g-Factors
        invgtitle = ['Inverse g-Factor - Acc = ' num2str(Rp) ' X ' num2str(Rf)];
        gsense_inv = 1./g_sense;
        gsense_inv(isinf(gsense_inv))=0;        %Just check to make sure there are no bad entries in the coil maps
        gsense_inv(isnan(gsense_inv))=0;
        
        figure,
        set(gcf,'Name',gtitle);
        colormap('hot');
        imagesc(flipud(abs(gsense_inv)),[0 1]); title(invgtitle); axis off; axis image; colorbar
    end
end
