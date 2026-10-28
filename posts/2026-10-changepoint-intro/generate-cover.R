# Reproduce the simulated series used as the blog post's cover.
set.seed(28102026)
n <- 300
breaks <- c(65, 130, 205, 255)
levels <- c(0.3, 1.7, -0.2, 1.15, 0.1)
segment <- findInterval(seq_len(n) - 0.5, breaks) + 1
series <- levels[segment] + rnorm(n, sd = 0.28)

pdf_file <- tempfile(fileext = ".pdf")
pdf(pdf_file, width = 9, height = 4.5, family = "Helvetica")
par(mar = c(4.2, 4.2, 1.2, 1.2), bg = "#ffffff", family = "sans")
plot(seq_len(n), series, type = "n", xlab = "Temps", ylab = "Valeur observée",
     ylim = c(-1.2, 2.7), xaxs = "i", yaxs = "i", las = 1,
     col.axis = "#40556b", col.lab = "#263e55", bty = "n")
abline(h = seq(-1, 2.5, by = 0.5), col = "#e8eef2", lwd = 1)
abline(v = breaks + 0.5, col = "#d66a45", lwd = 2.5, lty = 2)
lines(seq_len(n), series, col = "#286285", lwd = 1.4)
legend("topright", legend = c("Série simulée", "Ruptures"),
       col = c("#286285", "#d66a45"), lty = c(1, 2), lwd = c(1.6, 2.5),
       bty = "n", text.col = "#263e55", bg = "white")
dev.off()
system2("pdftoppm", c("-f", "1", "-l", "1", "-singlefile", "-png",
                     "-r", "160", shQuote(pdf_file),
                     "posts/2026-10-changepoint-intro/serie-ruptures"))
unlink(pdf_file)
