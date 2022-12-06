#!/usr/bin/env Rscript
# File     :  calEXP.R
# Time     :  2022/10/01 10:20:30
# Author   :  Wenyong Zhu
# Version  :  1.0.0
# Desc     :  calculate the consistence of HTNE expression across the samples

rm(list = ls())

args <- commandArgs(TRUE)

SAMPLE_GROUP <- args[1]
list_bw_file <- args[2]

list_bw <- read.table(list_bw_file, header = FALSE,
    col.names = c("sampleID", "bigwigFile"), stringsAsFactors = FALSE)

EXP <- data.frame()
PV <- data.frame()
for (bw_file in list_bw$bigwigFile){
    print(bw_file)
    # read background
    df <- read.table(paste0(bw_file, ".randomBackground"), header = FALSE)[, 2]
    # mean RPM (mean from bigWigAverageOverBed)
    Fn <- ecdf(df)
    # read expression
    expression <- read.table(paste0(bw_file, ".HTNE.meanRPM"), header = FALSE)
    pvalue <- as.numeric(format(1-Fn(expression[,2]), digits = 3))
    # merge
    if (ncol(EXP) == 0) {
        EXP <- expression
        expression[, 2] <- pvalue
        PV <- expression
    } else {
        EXP <- cbind(EXP, expression[, 2])
        PV <- cbind(PV, pvalue)
    }
}

colnames(EXP) <- c("locus", list_bw$sampleID)
colnames(PV) <- c("locus", list_bw$sampleID)
write.table(EXP, "HTNE.tmp5.meanRPM.xls",
    col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)
write.table(PV,  "HTNE.tmp5.pvalues.xls",
    col.names = TRUE, row.names = FALSE, sep = "\t", quote = FALSE)

## binomial test for the significant HHTNE (p<0.05)
N <- nrow(list_bw)
binomial.pvalues <- sapply(rowSums(PV[, -1] <= 0.05),
    function(x) binom.test(x, N, 0.05, 'greater')$p.value)
# using the Holm-Bonferroni method 
# (AKA step-down Bonferroni) to correct for multiple test
p.adjusted <- cbind(binomial.pvalues=binomial.pvalues,
    p.adjusted.HB = p.adjust(binomial.pvalues, method = "holm"),
    p.adjusted.bonferroni = p.adjust(binomial.pvalues, method = "bonferroni"),
    p.adjusted.FDR = p.adjust(binomial.pvalues, method = "fdr"))
rownames(p.adjusted) <- PV[, 1]

write.table(p.adjusted, "HTNE.tmp5.pvalues.adjusted.xls",
    col.names = NA, row.names = TRUE, sep = "\t", quote = FALSE)
