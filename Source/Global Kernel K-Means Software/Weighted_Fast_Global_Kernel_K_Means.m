function [Cluster_elem,Clustering_error]=Weighted_Fast_Global_Kernel_K_Means(K,Dataset_Weights,Total_clusters,Display)
%
%[Cluster_elem,Clustering_error]=Weighted_Fast_Global_Kernel_K_Means(K,Dataset_Weights,Total_clusters,Display)
%
%This function implements the Fast Global Kernel K-Means algorithm as described in  
%G.Tzortzis and A.Likas, "The Global Kernel k-Means Algorithm for Clustering in Feature Space", to be published in IEEE TNN.
%It allows the user to run both the weighted and the non-weighted versions of Fast Global Kernel K-Means.
%
%This function calls the Weighted_Kernel_K_Means function.
%
%Function Inputs
%===============
%
%K is the kernel matrix of the dataset. It must be a positive definite
%square matrix (Gram matrix) in order to guarantee algorithm convergence.
%If K is not positive definite the algorithm may still converge though.
%
%Dataset_Weights is a column vector containing the weight of each datapoint. It
%is used to run the weighted version of Fast Global Kernel K-Means. By setting all
%weights equal to 1 the non-weighted version is run. The weights must be positive numbers.
%
%Total_clusters is the number of clusters.
%
%Display when set to 'nutshell' prints information only about Fast Global Kernel K-Means
%and when set to 'details' also prints information about each iteration of Kernel K-Means.
%Any other value results in no printing.
%
%Function Outputs
%================
%
%Cluster_elem is a column vector containing the final partitioning of the dataset. The clusters are indexed 1,...,Total_clusters.
%
%Clustering_error is the value of the Kernel K-Means objective function corresponding to the final partitioning.
%
%
%Courtesy of G. Tzortzis

%Dataset size.
Data_num=size(K,1);

%Store the optimal clustering error when searching for 1,2,...,Total_clusters.
Best_error=zeros(1,Total_clusters);

%Store the assignment of points to clusters corresponding to the optimal solution for 1,2,...,Total_clusters.
Best_clusters=ones(Data_num,Total_clusters);

%Find one cluster solution.
[Best_clusters(:,1),Best_error(1),Center_dist]=Weighted_Kernel_K_Means(Best_clusters(:,1),K,Dataset_Weights,1,Display);

%Find 2,...,Total_Clusters solutions.
for m=2:Total_clusters
    
    Max_reduction=-1;
    
    %Place the m-th cluster initially at point n and calculate the guaranteed reduction in clustering error.
    for n=1:Data_num
        
        Reduction=Center_dist-(K(n,n)+diag(K)-2*K(n,:)');
        Reduction(Reduction<0)=0;
        Total_reduction=Dataset_Weights'*Reduction;
        
        %Keep the best point.
        if Total_reduction>Max_reduction
            
            Max_reduction=Total_reduction;
            Index=n;
        end
    end           
        
    %Place the m-th cluster center at the point that guarantees the greatest reduction in clustering error.
    %The other clusters are initiallized using the solution to the m-1 clustering problem.
    Cluster_elem=Best_clusters(:,m-1);
    Cluster_elem(Index)=m;
    
    if strcmp(Display,'details') || strcmp(Display,'nutshell')
        fprintf('\n\nSearching for %d clusters.Intitially placing %dth cluster at point %d',m,m,Index);
    end
    
    %Find the solution with m clusters.
    [Best_clusters(:,m),Best_error(m),Center_dist]=Weighted_Kernel_K_Means(Cluster_elem,K,Dataset_Weights,m,Display);
    
    if strcmp(Display,'details') || strcmp(Display,'nutshell')
        fprintf('\nFinal Clustering error=%g\n',Best_error(m));
    end
          
    if size(unique(Best_clusters(:,m)),1)<m
        error('Not able to find more than %d clusters\n',m-1);
    end
end

%Keep as final solution of Fast Global Kernel K-Means the one with the lowest clustering error (usually its the one with Total_clusters).
[Clustering_error,Clusters]=min(Best_error);
Cluster_elem=Best_clusters(:,Clusters);

if strcmp(Display,'details') || strcmp(Display,'nutshell')
    fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++++\n');
    fprintf('Best fit:%d clusters with Clustering Error=%g\n',Clusters,Clustering_error);
    fprintf('++++++++++++++++++++++++++++++++++++++++++++++++++++\n');
end

