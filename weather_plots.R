# Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  require(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}

library(grid);library(ggplot2);library(scales)

weather_daily <- read.csv("weather_daily.csv")
weather_daily$date = as.Date(as.character(weather_daily$date),"%Y-%m-%d")
weather_daily$boug = format(weather_daily$date, format="%b %d")           

weather_daily_recent = weather_daily[weather_daily$date >= Sys.Date(),]
weather_daily_recent$rain_adj <- NA

weather_daily_recent[weather_daily_recent$rain_in > 0,]$rain_adj <- weather_daily_recent[weather_daily_recent$rain_in > 0,]$high_f

p1 <- ggplot(data=weather_daily_recent[weather_daily_recent$city=='Washington',])+
  geom_line(aes(x=date,y=low_f,group=city,colour='Low'),stat='identity')+
  geom_line(aes(x=date,y=high_f,group=city,colour='High'))+
  geom_point(aes(x=date,y=rain_adj,group=city,colour='Rain',size=rain_in))+
  scale_y_continuous(limits=c(min(weather_daily_recent$low_f)-10,max(weather_daily_recent$high_f)+10)
                     ,breaks=seq(0,110,5))+
  ggtitle('Upcoming Forecast for Washington DC')+
  xlab("Date")+
  ylab("Tempature")+
   scale_x_date(breaks = date_breaks('days'),labels = date_format("%b %d"))
 
p2 <- ggplot(data=weather_daily_recent[weather_daily_recent$city=='New_York',])+
  geom_line(aes(x=date,y=low_f,group=city,colour='Low'))+
  geom_line(aes(x=date,y=high_f,group=city,colour='High'))+
  geom_point(aes(x=date,y=rain_adj,group=city,colour='Rain',size=rain_in))+
  scale_y_continuous(limits=c(min(weather_daily_recent$low_f)-10,max(weather_daily_recent$high_f)+10)
                     ,breaks=seq(0,110,5))+
  ggtitle('Upcoming Forecast for New York, NY')+
  xlab("Date")+
  ylab("Tempature")+
  scale_x_date(breaks = date_breaks('days'),labels = date_format("%b %d"))


p3 <- ggplot(data=weather_daily_recent[weather_daily_recent$city=='Liverpool',])+
  geom_line(aes(x=date,y=low_f,group=city,colour='Low'))+
  geom_line(aes(x=date,y=high_f,group=city,colour='High'))+
  geom_point(aes(x=date,y=rain_adj,group=city,colour='Rain',size=rain_in))+
  scale_y_continuous(limits=c(min(weather_daily_recent$low_f)-10,max(weather_daily_recent$high_f)+10)
                     ,breaks=seq(0,110,5))+
  ggtitle('Upcoming Forecast for Liverpool, England')+
  xlab("Date")+
  ylab("Tempature")+
  scale_x_date(breaks = date_breaks('days'),labels = date_format("%b %d"))

p4 <- ggplot(data=weather_daily_recent[weather_daily_recent$city=='Sydney',])+
  geom_line(aes(x=date,y=low_f,group=city,colour='Low'))+
  geom_line(aes(x=date,y=high_f,group=city,colour='High'))+
  geom_point(aes(x=date,y=rain_adj,group=city,colour='Rain',size=rain_in))+
  scale_y_continuous(limits=c(min(weather_daily_recent$low_f)-10,max(weather_daily_recent$high_f)+10)
                     ,breaks=seq(0,110,5))+
  ggtitle('Upcoming Forecast for Sydney, Australia')+
  xlab("Date")+
  ylab("Tempature")+
  scale_x_date(breaks = date_breaks('days'),labels = date_format("%b %d"))

p5 <- multiplot(p1, p2, p3, p4, cols=2)


png(paste('weather_daily_',Sys.Date(),'.png',sep=''),width =900,height =580)
multiplot(p1, p2, p3, p4, cols=2)
dev.off()

