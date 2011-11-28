AppendOut<-function(compile.out,Header,x,out,Parm.Len,parent,split.type){
    Header.Length<-nrow(Header)

################ Writing to the csv  ############################
  if(file.access(compile.out,mode=0)==-1){ #if very first time through little

          write.table(Header,file =compile.out,row.names=FALSE,col.names=FALSE,quote=FALSE,sep=",")
          write.table(x,file=compile.out,row.names=FALSE,col.names=FALSE,quote=FALSE,append=TRUE,sep=",")
          output<-matrix(0,0,0)
  } else { #this else (not the first time through) read current csv first
          input<-read.table(compile.out,fill=TRUE,sep=",")
          output<-cbind(input,c(Header[,2],as.character(x[,2])))
              temp=try(write.table(output,file =compile.out,row.names=FALSE,col.names=FALSE,quote=FALSE,sep=","),silent=TRUE)
           while(class(temp)=="try-error"){
                      modalDialog("","Please Close the AppendedOutput.exe\ so that R can write to it then press ok to continue ","")
                      temp<-try(write.table(output,file =compile.out,row.names=FALSE,col.names=FALSE,quote=FALSE,sep=","),silent=TRUE)
                      }
          }

  ###################### Making the jpg image ###################
  if(ncol(output)>2){

                  jpeg(file=paste(parent,paste("AcrossModel",
                       switch(out$dat$split.type,"crossValidation"="CV","test"="Test","none"=""),
                       switch(out$input$model.family,"binomial"="Bin","bernoulli"="Bin","poisson"="Cnt"),
                       ".jpg",sep=""),sep="\\"),width=1000,height=1000,pointsize=13)
                  par(mfrow=c(Parm.Len,1),mar=c(.2, 5, .6, 2),cex=1.1,oma=c(5, 0, 3, 0))
               #Getting rid of the header
                            row.nms<-as.character(output[(nrow(Header)+3):((nrow(Header)+2)+Parm.Len),1])
                      Hdr<-unlist(strsplit(readLines(compile.out,1),split=","))
                      output<-output[(nrow(Header)+1):nrow(output),2:ncol(output)]
               #Setting up train as numeric
                      train<-output[3:(Parm.Len+2),]
                      train<-matrix(data=as.numeric(as.character(as.matrix(train))),nrow=nrow(train),ncol=ncol(train))
                       row.names(train)<-row.nms
                       train[grep("Percent",rownames(train),ignore.case=TRUE),]<-train[grep("Percent",rownames(train),ignore.case=TRUE),]/100
                #Setting up test as numeric

                 if(split.type!="none"){
                      test<-output[(Parm.Len+3):nrow(output),]
                      test<-test[-c(seq(from=1,to=nrow(test),by=Parm.Len+2),seq(from=2,to=nrow(test),by=Parm.Len+2)),]
                      test<-as.data.frame(matrix(data=as.numeric(as.character(as.matrix(test))),nrow=nrow(test),ncol=ncol(test)))
                      test$split.inx<-rep(seq(from=1,to=nrow(test)/Parm.Len),each=Parm.Len)
                      test.lst<-split(test[,-c(ncol(test))],f=test$split.inx)
                         for(i in 1:length(test.lst)) {row.names(test.lst[[i]])<-row.nms
                          test.lst[[i]][grep("Percent",rownames(test.lst[[i]]),ignore.case=TRUE),]<-test.lst[[i]][grep("Percent",rownames(test.lst[[i]]),ignore.case=TRUE),]/100
                                }
                          } else test.lst<-list()
                          
                     ss<-seq(from=1,to=ncol(train),by=1)
                     x.labs<-sub(" ","\n",rownames(train))
                     x.labs<-sub("Percent","Proportion",x.labs)
                    colors.test=c("chocolate3","gold1","darkolivegreen2","steelblue1","brown3")
                  colors.train=c("chocolate4","gold3","darkolivegreen4","steelblue4","brown4")
        #producing plots
                   for(i in 1:Parm.Len){
                        plot(c(0,(ncol(train)+2)),c(0,1.1),type="n",xaxt="n",
                            xlab=paste("Corresponding Column in ",ifelse(!is.null(out$dat$ma$ma.test),"AppendedOutputTestTrain.csv","AppendedOutput.csv"),sep=""),
                            ylab=x.labs[i])
                            grid(nx=10)
                            if(split.type!="none") legend(ncol(test),y=.75,legend=c("Test","Train"),fill=c(colors.test[i],colors.train[i]))
                          rect(xleft=ss-.4,ybottom=0,xright=ss,ytop=train[i,],col=colors.train[i],lwd=2)
                         #if test split
                         options(warn=-1)
                          if(length(test.lst)==1) rect(xleft=ss,ybottom=0,xright=(ss+.4),ytop=pmax(0,test.lst[[1]][i,]),col=colors.test[i],lwd=2)
                          if(length(test.lst)>1) for(j in 1:length(test.lst)) points(x=ss,y=pmax(0,test.lst[[j]][i,]),col=colors.test[i],cex=2)
                         options(warn=0)
                          text((which(train[i,]==max(train[i,],na.rm=TRUE),arr.ind=TRUE)-.25),
                              max(train[i,],na.rm=TRUE)+.05,labels=as.character(round(max(train[i,]),digits=2)),cex=.8)
                          if(length(test.lst)==1) text((which(test.lst[[1]][i,]==max(test.lst[[1]][i,],na.rm=TRUE),arr.ind=TRUE)+.25),
                              max(test.lst[[1]][i,],na.rm=TRUE)+.05,labels=as.character(round(max(test.lst[[1]][i,]),digits=2)),cex=.8)
                        if (i==1) par(mar=c(.2, 5, .6, 2))
                        if(i!=1 & i!=(Parm.Len-1)) par(mar=c(.3, 5, .4, 2))
                        if(i==(Parm.Len-1)) par(mar=c(2, 5, .4, 2))
                        }
                        

             #Outer margin labels

                            for(i in 1:length(Hdr)) mtext(Hdr[i],line=-12,at=(i-1),las=2)
                          mtext("Evaluation Metrics Performance Across Model Runs",outer=TRUE,side=3,cex=1.3)
                          mtext(paste("sub-folder name where model is found in the folder ",parent
                            ,sep=""),side=1,outer=TRUE,line=3)
                       dev.off()

                    }
               }