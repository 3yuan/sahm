Pred.Surface<-function(object, model, filename="", na.rm=TRUE) {
		predrast <- raster(object)
		filename <- trim(filename)
			firstrow <- 1
			firstcol <- 1
		ncols <- ncol(predrast)
		lyrnames <- layerNames(object)
		xylyrnames <- c('x', 'y', lyrnames)
		v <- matrix(NA, ncol=nrow(predrast), nrow=ncol(predrast))
      na.rm <- FALSE
		tr <- blockSize(predrast, n=nlayers(object)+3)
		ablock <- 1:(ncol(object) * tr$nrows[1])
		napred <- rep(NA, ncol(predrast)*tr$nrows[1])
  	predrast <- writeStart(predrast, filename=filename,overwrite=TRUE)
  ############################################################
      z.max<-0
		  z.min<-0

  	for (i in 1:tr$n) {
			if (i==tr$n) { 
				ablock <- 1:(ncol(object) * tr$nrows[i])
				napred <- rep(NA, ncol(predrast) * tr$nrows[i])
			}
			rr <- firstrow + tr$row[i] - 1
				p <- xyFromCell(predrast, ablock + (tr$row[i]-1) * ncol(predrast)) 
				p <- na.omit(p)
				blockvals <- data.frame(x=p[,1], y=p[,2])
        if (na.rm) {
					blockvals <- na.omit(blockvals)		
				}
    if (nrow(blockvals) == 0 ) {
					predv <- napred
				} else {
					predv <- predict(out$mods$auc.output$residual.smooth.fct, blockvals)
   	}
				if (na.rm) {  
					naind <- as.vector(attr(blockvals, "na.action"))
					if (!is.null(naind)) {
						p <- napred
						p[-naind] <- predv
						predv <- p
						rm(p)
					}
				}
				# to change factor to numeric; should keep track of this to return a factor type RasterLayer
				predv = as.numeric(predv)
				predrast <- writeValues(predrast, predv, tr$row[i])
				if(length(na.omit(predv))>0){
    				z.max<-max(c(na.omit(predv),z.max))
    				z.min<-min(c(na.omit(predv),z.min))
				}
			}
  predrast@data@min=z.min
  predrast@data@max=z.max
  browser()
	predrast <- writeStop(predrast)
		return()
	}
