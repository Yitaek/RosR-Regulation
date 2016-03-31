## Biology 311 Final Project
# Exploring RosR - Clustering Analysis

## Loading all the required packages
library(dendextend)
library(gplots)

# Read in the Gene Expression Data
gedata = read.csv("GEdata.csv", header=T, row.names=1)

# Subset of the Parent Strain
parent = t(gedata[1:8])

# Subset of the RosR Deletion
RosRDel = t(gedata[9:16])

# Heatmap for the Parent Strain	
parent.T = t(parent)
parent.max.times <- apply(parent.T, 1, which.max)
parent.gene.order <- rev(order(parent.max.times))
reordered.parent <- parent.T[parent.gene.order, 1:8]

png("heatmap_reordered_parent.png", width=600, height=600)
heatmap(reordered.parent, Colv=NA, Rowv=NA, col=greenred(64), labRow=NA, cexCol=0.5)
dev.off()

# Clustering for the Parent Strain
my.dist <- function(x) {as.dist(1 - cor(x, use="pairwise.complete.obs"))}
parent.dist <- my.dist(parent)
parent.tree <- hclust(parent.dist, method="complete")
parent.dend <- as.dendrogram(parent.tree)

png("heatmap_with_dendrogram_parent.png", width=600, height=600)
heatmap(parent.T, Colv=NA, Rowv=parent.dend, col=greenred(64), labRow=NA, cexCol=0.5)
dev.off()

# Heatmap for the RosR Knockout
RosR.T = t(RosRDel)
RosR.max.times <- apply(RosR.T, 1, which.max)
RosR.gene.order <- rev(order(RosR.max.times))
reordered.RosR <- parent.T[RosR.gene.order, 1:8]

png("heatmap_reordered_RosRDel.png", width=600, height=600)
heatmap(reordered.RosR, Colv=NA, Rowv=NA, col=greenred(64), labRow=NA, cexCol=0.5)
dev.off()

# Clustering for the RosR Knockout
RosR.dist <- my.dist(RosRDel)
RosR.tree <- hclust(RosR.dist, method="complete")
RosR.dend <- as.dendrogram(RosR.tree)

png("heatmap_with_dendrogram_RosRDel.png", width=600, height=600)
heatmap(parent.T, Colv=NA, Rowv=RosR.dend, col=greenred(64), labRow=NA, cexCol=0.5)
dev.off()



### Clustering Algorithms

# Determining the "best" number of clusters using elbow plot
wss <- (nrow(parent.T)-1)*sum(apply(parent.T,2,var))
for (i in 2:100) wss[i] <- sum(kmeans(parent.T, centers=i)$withinss)
  	
png("elbow_plot_parent.png")
plot(1:100, wss, type="b", xlab="Number of Clusters", ylab="Within groups sum of squares")
dev.off()
  
# 10 was determined to be appropriate

parent.cor <- cor(parent, use="pairwise.complete.obs")
parent.kmeans <- kmeans(1-parent.cor, 10)
parent.kclusters <- parent.kmeans$cluster
table(parent.kclusters)

# Rearranging k-means clusters for different colors for dendrogram
parent.kclusters <- parent.kclusters[order.dendrogram(parent.dend)]
dend.colors <- unique(get_leaves_branches_attr(color_branches(parent.dend, k=10, attr="col")))

png("kmeans_parent.png")
plot(branches_attr_by_clusters(parent.dend, parent.kclusters, dend.colors) ,leaflab="none")
dev.off()

# VNG0258H gene is in cluster 6