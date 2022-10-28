#!/usr/bin/env Rscript

# Copyright 2022 Zeya Chen <zeya.chen@sickkids.ca>, Zhong Wang, Lei Sun, Andrew D. Paterson 
#
#  This file is free software: you may copy, redistribute and/or modify it  
#  under the terms of the GNU General Public License as published by the  
#  Free Software Foundation, either version 2 of the License, or (at your  
#  option) any later version.  
#  
#  This file is distributed in the hope that it will be useful, but  
#  WITHOUT ANY WARRANTY; without even the implied warranty of  
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU  
#  General Public License for more details.  
#  
#  You should have received a copy of the GNU General Public License  
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.  
suppressPackageStartupMessages(library("argparse"))

.VERSION <- "0.0.1"

# create parser object
parser <- ArgumentParser(
  description="sdMAF is a R based commend-line tool used to compute sex differences in allele frequencies. sdMAF is free and comes with ABSOLUTELY NO WARRANTY. Details of the method can be found https://journals.plos.org/plosgenetics/article/authors?id=10.1371/journal.pgen.1010231",
  epilog="Copyright 2022 Zeya Chen, Zhong Wang, Lei Sun, Andrew D. Paterson. Report bugs to zeya [dot] chen [at] sickkids [dot] ca"
  )



# specify our desired options 
# required arguments
requiredNamed = parser$add_argument_group('required arguments')
requiredNamed$add_argument("-f","--female", type="character", 
                           help = "Female genotype count file produced by PLINK.", 
                           metavar = "<filename>")
requiredNamed$add_argument("-m","--male", type="character", 
                           help = "Male genotype count file produced by PLINK.", 
                           metavar = "<filename>")

# optional arguments 
parser$add_argument("--version", action="store_true",
                    help="Print the version of this tool and exit.")
parser$add_argument("--bim", type="character", 
                    help = "Input bim file address to extract base pair position.Optional if ID in .gcount file are all chr:bp:a1:a2.",
                    metavar = "<filename>")
parser$add_argument("-o","--out", type="character", default="autosomal", 
                    help = "Specify output file name and address. Default autosomal.sdMAF.", metavar = "<filename>")
parser$add_argument("--multi-allelic", action="store_true",default=FALSE, 
                    help = "Indicate whether to keep multi-allelic SNPs in the results or not. Default FALSE.")
parser$add_argument("--mac", type="integer", default=5,
                    help = "Minimum allele count filter. Default 5.",
                    metavar = "<minimum count>")
  
# get command line options, if help option encountered print help and exit,
# otherwise if options not found on command line then set defaults, 
args <- parser$parse_args()

# print version and exit early if  --version was passed
if (isTRUE(args[["version"]])){
    cat(paste0("You are using version ",.VERSION," of sdMAF tool.", "\n"))
    quit(save = "no", status = 0)
}

cat("Checking if inputs are valid.\n")
# print Error and exit early if no female genotype count found.
if (!file.exists(args[["female"]])){
  cat(paste0("Error: no female genotype count file found at",args[["female"]],".","\n"))
  quit(save = "no", status = 0)
}

# print Error and exit early if no male genotype count found.
if (!file.exists(args[["male"]])){
  cat(paste0("Error: no male genotype count file found at",args[["male"]],".","\n"))
  quit(save = "no", status = 0)
}

fe <- read.table(args$female)
ma <- read.table(args$male)

# print Error and exit early if female male file dimension not matching or col number is not 10.
if (nrow(fe) != nrow(ma) | ncol(fe) != 10 | ncol(fe) != 10){
  cat(paste0("Error: genotype count files dimensions are incorrect or row numbers not equal.", "\n"))
  quit(save = "no", status = 0)
}


names(fe) <- c("CHROM","ID","REF","ALT","HOM_REF_CT","HET_REF_ALT_CTS","TWO_ALT_GENO_CTS","HAP_REF_CT","HAP_ALT_CTS","MISSING_CT")
names(ma) <- c("CHROM","ID","REF","ALT","HOM_REF_CT","HET_REF_ALT_CTS","TWO_ALT_GENO_CTS","HAP_REF_CT","HAP_ALT_CTS","MISSING_CT")

# print Error and exit early if male genotype count file is passed to --female.
if (nrow(fe) != sum(fe$HAP_REF_CT + fe$HAP_ALT_CT == 0)){
  cat(paste0("Error: male genotype files was passed to --female.", "\n"))
  quit(save = "no", status = 0)
}

# print Error and exit early if female male SNPs are not matching.
if (nrow(fe) != sum(fe$ID == ma$ID)){
  cat(paste0("Error: genotype count files snps are not matching.", "\n"))
  quit(save = "no", status = 0)
}

# check the region of SNPs if they are autosomal/PAR or ChrX NPR based on input. region = 1 for autosomal/PAR and 2 for NPR. 
region <- 1
if (nrow(ma) == sum(ma$HAP_REF_CT + ma$HAP_ALT_CT != 0)){
  region <- 2
  cat(paste0("ChrX NPR region detected based on male genotype count file.", "\n"))
} else {cat(paste0("Autosomal/NPR region detected based on male genotype count file.", "\n"))}

wald.1df.hwd.auto <- function(x)
  # 'Wald' type, 1 d.f. assuming HWD, Autosomal 
  # x is a vector with elements F_A1A1,F_A1A2,F_A2A2,M_A1A1.A1,M_A1A2,M_A2A2.A2 respectively
{
  r0 = x[1]; r1 = x[2]; r2 = x[3]; s0 = x[4]; s1 = x[5]; s2 = x[6]
  s = s0+s1+s2; r = r0+r1+r2
  pM = (0.5*s1+s2)/s; pF = (0.5*r1+r2)/r
  pAA.M = s2/s; pAA.F = r2/r
  delta.M = pAA.M-pM^2; delta.F = pAA.F-pF^2
  stat = (pM-pF)^2/(1/(2*s)*(pM*(1-pM)+delta.M)+1/(2*r)*(pF*(1-pF)+delta.F))
  -pchisq(as.numeric(stat),df=1,lower.tail = F,log.p=T)/log(10)     # -log10
}

wald.1df.hwd.xchr <- function(x)
  # 'Wald' type, 1 d.f. assuming HWD, Xchr 
  # x is a vector with elements F_A1A1,F_A1A2,F_A2A2,M_A1A1.A1,M_A1A2,M_A2A2.A2 respectively
{
  r0 = x[1]; r1 = x[2]; r2 = x[3]; s0 = x[4]; s1 = x[5]; s2 = x[6]
  s = s0+s2; r = r0+r1+r2
  pM = s2/s; pF = (0.5*r1+r2)/r 
  pAA.F = r2/r
  delta.F = pAA.F-pF^2
  stat = (pM-pF)^2/(1/s*(pM*(1-pM))+1/(2*r)*(pF*(1-pF)+delta.F))
  -pchisq(as.numeric(stat),df=1,lower.tail = F,log.p=T)/log(10)     # -log10
}

loop_func <- function(df,reg){
  # df dataframe to be fed into wald.1df.hwd function.
  # reg regions 1 for autosomal/PAR and 2 for NPR.
  nr <- nrow(df) 
  prog <- c("10%","20%","30%","40%","50%","60%","70%","80%","90%","100%")
  snpc <- ceiling(c(0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1)*nr)
  fl <- c("wald.1df.hwd.auto","wald.1df.hwd.xchr")
  f <- get(fl[reg]) #assign which function to be used based on input
  LOG10P <- c()
  j = 1
  for (i in 1:nr) {
    LOG10P <- c(LOG10P,f(df[i,5:10])) #appending P value
    if (i == snpc[j]) {
      if (j == 10) {cat(paste0("Finito !", "\n"))} else {cat(paste0("Now calculated ", prog[j]," (",i,"/",nr,").", "\n"))} #print % of calculation done
      j = j + 1
    }
  }
  cbind(df,LOG10P)
}

if (is.null(args$bim)) {
  cat(paste0("No bim file provided. OK unless ID column from genotype file not all in chr:bp:A1:A2 form.","\n"))
} else {ch <- read.table(args$bim,header =F)} # since --geno-couts does not include physical position.

# merge fe and ma to one data frame
if (region==1) {
  chrom <- cbind(fe[,1:7],ma[,5:7])
} else {chrom <- cbind(fe[,1:7],ma[,8],0,ma[,9])}

names(chrom)[3:10] <- c("A1","A2","F_A1A1","F_A1A2","F_A2A2","M_A1A1.A1","M_A1A2","M_A2A2.A2")
cat(paste0("Input checkers all passed, now applying filters.","\n"))

#filter for only biallelic variants
if (isTRUE(args[["multi-allelic"]])){
} else {
  bia <- nchar(chrom$A2)==1&nchar(chrom$A1)==1
  cat(paste0("Keeping ", sum(bia)," biallelic SNPs out of ", nrow(chrom)," total SNPs from Input.","\n"))
  chrom <- chrom[bia,]
}

# getting a list of whether each SNP passes mac  checking 2AA + Aa and Aa + 2aa is > MAC
macf <- (2*chrom$F_A1A1+2*chrom$M_A1A1.A1+chrom$F_A1A2+chrom$M_A1A2 >= args$mac) & (chrom$F_A1A2+chrom$M_A1A2+2*chrom$F_A2A2+2*chrom$M_A2A2.A2 >= args$mac)
cat(paste0("Keeping ", sum(macf)," SNPs out of ", nrow(chrom)," SNPs based on a minor allele count filter of ",args$mac,".\n"))
chrom <- chrom[macf,]

cat(paste0("All filters applied, now computing sdMAF!","\n"))
# computing p value for sdMAF 
chromwithP <- loop_func(chrom,region)

if (!is.null(args$bim)) {
  chromwithP$BP <- ch$V4 # add BP to results from bim file
} else { chromwithP$BP <- sapply(strsplit(chromwithP$ID,":"), `[`, 2) } # get BP from ID

chromwithP$Mmissing <- ma$MISSING_CT[match(chromwithP$ID,ma$ID)]
chromwithP$Fmissing <- fe$MISSING_CT[match(chromwithP$ID,fe$ID)]
chromwithP <- chromwithP[,c(1:4,12:14,5:11)] #rearrange

# compute allele frequency
chromwithP$Ffreq <- (0.5*chromwithP$F_A1A2+chromwithP$F_A2A2)/(chromwithP$F_A1A1+chromwithP$F_A1A2+chromwithP$F_A2A2)
chromwithP$Mfreq <- (0.5*chromwithP$M_A1A2+chromwithP$M_A2A2)/(chromwithP$M_A1A1+chromwithP$M_A1A2+chromwithP$M_A2A2)
chromwithP$Fmaf <- ifelse(chromwithP$Ffreq>0.5,1-chromwithP$Ffreq,chromwithP$Ffreq)
chromwithP$Mmaf <- ifelse(chromwithP$Mfreq>0.5,1-chromwithP$Mfreq,chromwithP$Mfreq)
chromwithP$DIFmaf <- chromwithP$Fmaf - chromwithP$Mmaf

# writing results
f.nm <- paste0(args$out,".sdMAF")

# break it down into finer steps
invisible(file.create(f.nm))
f <- file(f.nm, open="w") # or open="a" if appending

cat(paste0("Writing results to ",f.nm,"\n"))
write.table(chromwithP, file = f, sep = "\t", quote = F, append=FALSE, row.names = FALSE, col.names=TRUE)

close(f)