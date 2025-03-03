rm(list=ls())

library("reshape2")
library("ggplot2")
library("zoo")
library(gtable)
library(grid)

malawi <- read.csv("data/malawi_data_new.csv")

# start here 
data<-cbind(malawi$RCSI,(malawi$FCS),(malawi$HDDS),malawi$month)
colnames(data)<-c("RCSI","FCS","HDDS","month")
data<-as.data.frame(data)
data$RCSI[data$RCSI>42]<-42
data<-data[data$HDDS!=0,]


short_data<-aggregate(cbind(RCSI,FCS,HDDS)~month,data=data, mean)

long_data<- melt(short_data,na.rm=TRUE,id.vars = c("month"),measure.vars = c("RCSI","FCS","HDDS"))

colnames(long_data)<-c("month","measure","Food_security")
long_data$months<-as.factor(long_data$month)


FCS_long<-as.data.frame(long_data[long_data$measure=="FCS",])

p<-ggplot(as.data.frame(long_data[long_data$measure!="FCS",]),aes(x=months,color=measure,y=Food_security,shape = measure,group=measure)) + theme_bw() + geom_path(size=2.5)+ geom_point(size=5)  
# adding the relative humidity data, transformed to match roughly the range of the temperature
p <- p +geom_line(size=2.5,data=FCS_long,aes(y = Food_security/12.3, colour = measure))  + geom_point(data=FCS_long,aes(y = Food_security/12.3, colour = measure),size=5)  


# now adding the secondary axis, following the example in the help file ?scale_y_continuous
# and, very important, reverting the above transformation
p <- p + scale_y_continuous(sec.axis = sec_axis(~.*12.3, name = "Food consumption scores"))

# modifying colours and theme options
#  p <- p + scale_colour_manual(values = c("blue", "red"))
p <- p + labs(y = "HDDS and RCSI scores",
              x = "Month",
              colour = "Food Security Measures",
              shape= " ")
p



ggsave("FS_by_month.png", plot = p,device = "png",path = "output/figures/",
       dpi = 1000, limitsize = TRUE)
#  p <- p + theme(legend.position = c(0.8, 0.9))

