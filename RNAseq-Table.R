#Megan Mair
#Botas Lab internal use
#Retreive expression patterns across models

######EDIT HERE ONLY #############
#change to directory containing files:
setwd("D:/RNA-seq/model comparisons") 

##########END EDITS##############

#Read all files
flhtt_nc_2<-read.csv("flhtt_nc_2.txt",sep="\t")
flhtt_nc_5<-read.csv("flhtt_nc_5.txt",sep = "\t")
flhtt_nc_7<-read.csv("flhtt_nc_7.txt",sep="\t")
flhtt_nc_10<-read.csv("flhtt_nc_10.txt",sep="\t")
flhtt_nc_14<-read.csv("flhtt_nc_14.txt",sep="\t")

nthtt_nc_2<-read.csv("nthtt_nc_2.txt",sep="\t")
nthtt_nc_5<-read.csv("nthtt_nc_5.txt",sep="\t")
nthtt_nc_7<-read.csv("nthtt_nc_7.txt",sep="\t")
nthtt_nc_10<-read.csv("nthtt_nc_10.txt",sep="\t")
nthtt_nc_14<-read.csv("nthtt_nc_14.txt",sep="\t")
nthtt_nc_21<-read.csv("nthtt_nc_21.txt",sep="\t")

tau_nc_2<-read.csv("tau_nc_2.txt",sep="\t")
tau_nc_5<-read.csv("tau_nc_5.txt",sep="\t")
tau_nc_7<-read.csv("tau_nc_7.txt",sep="\t")
tau_nc_10<-read.csv("tau_nc_10.txt",sep="\t")
tau_nc_14<-read.csv("tau_nc_14.txt",sep="\t")
tau_nc_21<-read.csv("tau_nc_21.txt",sep="\t")
tau_nc_28<-read.csv("tau_nc_28.txt",sep="\t")
tau_nc_42<-read.csv("tau_nc_42.txt",sep="\t")

asyn_nc_2<-read.csv("asyn_nc_2.txt",sep="\t")
asyn_nc_5<-read.csv("asyn_nc_5.txt",sep="\t")
asyn_nc_7<-read.csv("asyn_nc_7.txt",sep="\t")
asyn_nc_10<-read.csv("asyn_nc_10.txt",sep="\t")
asyn_nc_14<-read.csv("asyn_nc_14.txt",sep="\t")
asyn_nc_21<-read.csv("asyn_nc_21.txt",sep="\t")

b42_nc_2<-read.csv("b42_nc_2.txt",sep="\t")
b42_nc_5<-read.csv("b42_nc_5.txt",sep="\t")
b42_nc_7<-read.csv("b42_nc_7.txt",sep="\t")
b42_nc_10<-read.csv("b42_nc_10.txt",sep="\t")
b42_nc_14<-read.csv("b42_nc_14.txt",sep="\t")
b42_nc_21<-read.csv("b42_nc_21.txt",sep="\t")

#Make list of files per each model 
fl_files<-list(flhtt_nc_2,flhtt_nc_5,flhtt_nc_7,flhtt_nc_10,flhtt_nc_14)
nt_files<-list(nthtt_nc_2,nthtt_nc_5,nthtt_nc_7,nthtt_nc_10,nthtt_nc_14,nthtt_nc_21)
tau_files<-list(tau_nc_2,tau_nc_5,tau_nc_7,tau_nc_10,tau_nc_14,tau_nc_21,tau_nc_28,tau_nc_42)
asyn_files<-list(asyn_nc_2,asyn_nc_5,asyn_nc_7,asyn_nc_10,asyn_nc_14,asyn_nc_21)
b42_files<-list(b42_nc_2,b42_nc_5,b42_nc_7,b42_nc_10,b42_nc_14,b42_nc_21)

tabl <- data.frame(matrix(ncol = 5, nrow = 0))

#provide column names
colnames(tabl) <- c('genes', 'log2fc', 'pval','padj','days')

#Function that fetches +/- expressed values
#Default Padj<0.05, |log2fc|>0.2
check_gene <- function(model) {
  #Get model info... days in dataset vary by model
  if (model=="FL"){
    files <- fl_files
    day_counter=c(2,5,7,10,14) 
  } 
  else if (model=="B42") {
    files <- b42_files
    day_counter=c(2,5,7,10,14,21)
  } 
  else if (model=="NT") {
    files <- nt_files
    day_counter=c(2,5,7,10,14,21)
  } 
  else if (model=="tau") {
    files <- tau_files
    day_counter=c(2,5,7,10,14,21,28,42)
  } 
  else if (model=="asyn") {
    files <- asyn_files
    day_counter=c(2,5,7,10,14,21)
  } 
  else {
    print("wrong model entered")
  }
  #Get list of all genes measured in each model
  genes<-c()
  for (f in files){
    g<-as.data.frame(f)
    gene<-g$Gene_symbol
    gene<-as.vector(gene)
    genes<-c(genes,gene)
  }
  genes<-unique(genes)
  #Main function - get data for the table
  output_data <- data.frame(rbind(c("GeneName","Values")),stringsAsFactors = FALSE)
  for (gene in genes){ 
    log2fc<-c()
    padjs<-c()
    pval2<-c()
    day_counts<-c()
    counter=0 #day counter, to see what days are significant
    gcount=0
    
    for (file in files) {
      counter=counter+1
      pval=1
      gene_dat<-subset(file,file$Gene_symbol==gene)
      fc<-gene_dat$log2FoldChange
      pval<-gene_dat$padj
      pvals2<-gene_dat$pvalue
      if (identical(pval,numeric(0))){
        abc=0
      }
      else if (is.na(pval) | is.null(pval)){
        abc=0
      }
      else if (pval<0.05){
        if (abs(fc)>0.2){
          log2fc<-c(log2fc,fc)
          padjs<-c(padjs,pval)
          pval2<-c(pval2,pvals2)
          day_counts<-c(day_counts,day_counter[counter])

        }
        else {
          abc=0
        }
      }
    }
    
    #if (length(log2fc)>1){
    if (day_counter[length(day_counter)] %in% day_counts | day_counter[length(day_counter)-1] %in% day_counts){
    if (all(log2fc<0) | all(log2fc>0)){
      dfc<-toString(log2fc)
      dpval<-toString(padjs)
      dpval2<-toString(pval2)
      ddays<-toString(day_counts)
      data<-c(gene,dfc,dpval2,dpval,ddays)
      tabl[nrow(tabl) + 1,] = data
    
    }
    }
  }
  return(tabl)
  print(gcount)
  plot(gcount,day_counter)
}



#Check all the models
fl_data<-check_gene("FL") #Full length htt
nt_data<-check_gene("NT") #eNd terminal htt
tau_data<-check_gene("tau") #tau (AD)
b42_data<-check_gene("B42") #beta 42 (AD)
asyn_data<-check_gene("asyn") #alpha-syn (PD)

#Export relevant data
write.csv(tau_data,"tau_sig_fly.csv")


