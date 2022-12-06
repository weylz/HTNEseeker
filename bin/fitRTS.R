#!/usr/bin/env Rscript
# File     :  fitRTS.R
# Time     :  2022/10/01 10:20:30
# Author   :  Wenyong Zhu
# Version  :  1.0.0
# Desc     :  fit distribution of random trancriptional signal

rm(list = ls())

library(fitdistrplus)

# input as value at single nt
args <- commandArgs(TRUE)
# args[1]  "transcriptional.noise.rpm.txt"
transcriptional_noise <- args[1]

# read 1 million lines
df <- read.table(transcriptional_noise, comment.char = "")
df <- log10(df[, 1])

fitn <- fitdist(df, "norm")
pdf("transcriptional.noise.distribution.pdf", width = 8, height = 6)
hist(df, breaks = 80, prob = TRUE, xlab = "log10(RPM)",
    axes = TRUE, main = "Distribution of transcriptional noise")

lines(density(df, bw = 0.25), col = "grey", lwd = 3)

m <- round(as.numeric(fitn$estimate[1]), digits = 3)
sd <- round(as.numeric(fitn$estimate[2]), digits = 3)
# line type (lty) can be specified using either text or number.
# Note that lty = "solid" is identical to lty=1.
lines(density(rnorm(n = 1000000, mean = m, sd = sd), bw = 0.25),
    col = "springgreen4", lty = 5, lwd = 3)

p <- round(qnorm(0.05, mean = m, sd = sd, lower.tail = FALSE), digits = 3)
lines(y = c(0, 0.26), x = c(p, p), col = "red", lwd = 3)
text(p + 0.2, 0.3,
    paste("P(X>", p, ") = 0.05\nRPM = 10^", p, " = ", round(10**p, digits = 3)),
    adj = c(0, 0.5))
legend("topright", c("empirical density curve",
    paste("fitted normal distribution \n(mean = ", m, ", sd = ", sd, ")")),
    col = c("black", "blue"), lty = c(1, 2), bty = "n")

write.table(10**p, "transcriptional.noise.rpm.pvalues.txt",
    quote = FALSE, row.names = FALSE, col.names = FALSE)

dev.off()
