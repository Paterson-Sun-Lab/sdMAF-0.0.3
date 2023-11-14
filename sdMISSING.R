#!/usr/bin/env Rscript
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least one argument must be supplied (input file).n", call.=FALSE)
} else if (length(args)==1) {
  # default output file
  args[2] = "out.txt"
} else if (length(args)>2) {
  stop("No more than two arguments should be provided.", call.=FALSE)
}
# check if the input file exists
if (!file.exists(args[1])){
  cat(paste0("Error: no sdMAF file found at ",args[1],".","\n"))
  quit(save = "no", status = 0)
}

## program...
df = read.table(args[1], header=TRUE)
co <- cbind(df$F_A1A1+df$F_A1A2+df$F_A2A2,df$M_A1A1.A1+ifelse(is.na(df$M_A1A2),0,df$M_A1A2)+df$M_A2A2.A2,df$Fmissing,df$Mmissing)
df$sdMISSING <- (co[,3]/(co[,3]+co[,1]) - co[,4]/(co[,4]+co[,2]))
df$Pmissing <- NA
for (i in 1:nrow(co)) {
  df$Pmissing[i] <- -log10(fisher.test(matrix(unlist(co[i,]),2,2))$p.value)
}
write.table(df, file=args[2], row.names=FALSE)

