# Recreate the cover series and compute nine PELT segmentations.
suppressPackageStartupMessages(library(changepoint))
set.seed(28102026)
n <- 300
breaks <- c(65, 130, 205, 255)
levels <- c(0.3, 1.7, -0.2, 1.15, 0.1)
segment <- findInterval(seq_len(n) - 0.5, breaks) + 1
series <- levels[segment] + rnorm(n, sd = 0.28)

penalties <- c(0.30, 0.35, 0.40, 0.50, 0.55, 0.65, 0.80, 40, 55)
solutions <- lapply(penalties, function(beta) {
  cpts(cpt.mean(series, method = "PELT", penalty = "Manual",
                pen.value = beta, minseglen = 1))
})
counts <- lengths(solutions)
stopifnot(length(unique(counts)) == 9)
# Shuffle the panels reproducibly; the lines show estimated, not true, changes.
set.seed(20261028)
order <- sample(seq_along(penalties))

pdf_file <- tempfile(fileext = ".pdf")
pdf(pdf_file, width = 12, height = 8.3, family = "Helvetica")
par(mfrow = c(3, 3), mar = c(2.2, 2.5, 2.1, 0.6),
    oma = c(1.5, 3, 0.2, 0.2), bg = "white", las = 1)
for (i in order) {
  plot(seq_len(n), series, type = "n", ylim = c(-1.2, 2.7),
       xaxs = "i", yaxs = "i", xlab = "", ylab = "", bty = "n",
       col.axis = "#40556b", cex.axis = 0.75)
  abline(h = c(-1, 0, 1, 2), col = "#e8eef2")
  if (counts[i]) abline(v = solutions[[i]] + 0.5, col = "#c95631", lty = 2, lwd = 1.8)
  lines(seq_len(n), series, col = "#286285", lwd = 0.8)
  title(main = sprintf("%d rupture%s  |  beta = %s", counts[i],
                       if (counts[i] == 1) "" else "s", penalties[i]),
        col.main = "#263e55", cex.main = 0.95, font.main = 1)
}
mtext("Temps", side = 1, outer = TRUE, line = 0.25, col = "#263e55")
mtext("Valeur observée", side = 2, outer = TRUE, line = 1, las = 0, col = "#263e55")
dev.off()
status <- system2("pdftoppm", c("-f", "1", "-l", "1", "-singlefile", "-png",
                                "-r", "150", shQuote(pdf_file),
                                "posts/2026-10-changepoint-intro/segmentations-candidates"))
unlink(pdf_file)
stopifnot(status == 0)
cat("Nombre de ruptures par panneau :", counts[order], "\n")
