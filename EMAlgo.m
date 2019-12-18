% function EMAlgo(K, epsilon, X)
fig = double(imread('./pic/Input_sample.jpg'));%��ȡͼƬ
c1 = fig(:,:,1);
c2 = fig(:,:,2);
c3 = fig(:,:,3);
X = [c1(:),c2(:),c3(:)]; %X�����У�ÿһ����һ������
K =2;
epsilon = 1e-5;

% ���´������Automatic Corneal Ulcer Segmentation Combining Gaussian Mixture
% Modeling and Otsu Method�е�α�����д

% Initialization
[N, dim] = size(X);% N��dimά�ȵ�����
t = 0; %��������

% tau, mu,sigmaΪ�����ƵĲ��������������˶�ά����洢�����struct,cellҪ��ʡ��Դ
tau = 1/K * ones(1,K);% Mixing coefficient  
mu = randi(255,dim,K) .* ones(dim, K);% ��ʼ��mu
sigma = zeros(dim, dim, K);
for i = 1:K
    sigma(:,:,i) = 100 * eye(dim,dim);%��ʼ��sigma
end

rnk = 0.5 * ones(N, K); %��ʼ��������ʣ�posterior probability��
% �������˹����,��������һ����������
guass_fun = @(x, mu, sigma) exp(-1/2 * (x-mu).*(inv(sigma)*(x-mu)')')/sqrt((2*pi)^size(x,2)*det(sigma));
%��ǰ������Ȼ����ֵ��LogLikelihood�����������ĵ�������
llh = LogLikelihood(X, tau, mu, sigma, guass_fun);

while true
    t = t + 1;
    % E step
    for class = 1:K
        rnk(:, class) = sum(guass_fun(X, mu(:, class)', sigma(:, :, class)),2);
    end
    rnk = (rnk.*tau)./sum(rnk.*tau, 2);
    
    
    % M step
    for class = 1:K
        mu(:,class) = (sum(rnk(:, class).*X, 1)./sum(rnk(:, class)))';
        zeroMean = (X-mu(:,class)');
        sigma(:,:,class) = (zeroMean' * (zeroMean .* rnk(:,class)))./sum(rnk(:,class));
    end
    tau = sum(rnk)./N;
    
    % ��ӡ���
    disp(['+++++++++++ iteration ',num2str(t),'++++++++++++'])
    disp(['tau: ', num2str(tau)])
    disp('mu: ')
    disp(num2str(mu))
    disp('sigma: ')
    disp(num2str(sigma))
    
    % �˳�ѭ������
    llh_new = LogLikelihood(X, tau, mu, sigma, guass_fun);
    if (llh_new - llh)<=epsilon %����Ȼ��������������ʱ���˳�
        break;
    end
    llh = llh_new;
    
    if(t>100)% ���ߵ�����������������ʱ���˳�
        break
    end
  
end

% TODO: ���Էָ�Ч��

% end

%% �����Ȼ����
function result = LogLikelihood(X, tau, mu, sigma, fcnHandle)
% �ú�����������log-likelihood given in Eq. (4)��
% �����fcnHandle�Ƕ������˹����
    k = length(tau);% �ж�����
    [n, ~] = size(X);
    p = zeros(n, k);% ÿһ�����ص�ĸ���
    for j = 1:k
        p(:,j) = sum(tau(j) * fcnHandle(X, mu(:,j)', sigma(:,:,j)), 2);
    end
    result = sum(log(p));
end