#!/usr/bin/env Rscript

rm(list = ls())

values <- read.table("stableDetection.txt")$V1

library(cpm)
df <- data.frame(x = 1:length(values), y = values)
par(mfrow = c(2, 1))
plot(df, type = "l", col = "steelblue", lwd = 2)

# shapiro.test(df$y)
plot(density(df$y))
cpm_res <- processStream(df$y, cpmType = "GLR")
# cpm_res$changePoints
# cpm_res$x[cpm_res$changePoints]
file.copy(
    paste0("RepeatedTrial/HTNE.specific_",
        cpm_res$changePoints,
        ".bed"),
    "../HTNE_brca.bed", overwrite = TRUE)
