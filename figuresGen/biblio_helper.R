#! /usr/bin/env Rscript
library(RMySQL)
library(ggplot2)
library(reshape)
library(grid)
#library(gridExtra)

one_col_width=3.15
two_col_width=7.25

# colors
cmi_main_blue="#0071b2"
cmi_grey="#929d9e"
cmi_light_blue="#00c4d9"
cmi_pea_green="#b5bf00"

cmi_rich_green="#73933d"
cmi_rich_purple="#8e7fac"
cmi_rich_red="#d75920"
cmi_rich_blue="#4c87a1"
cmi_rich_aqua="#66c7c3"
cmi_rich_orange="#eebf42"

cmi_vibrant_yellow="#ffd457"
cmi_vibrant_orange="#f58025"
cmi_vibrant_green="#78a22f"
cmi_vibrant_garnet="#e6006f"
cmi_vibrant_purple="#9A4d9e"
cmi_vibrant_blue="#19398a"

cmi_year_colors=c(cmi_vibrant_blue,
                  cmi_rich_blue,
                  cmi_vibrant_purple,
                  cmi_vibrant_garnet,
                  cmi_rich_red,
                  cmi_vibrant_orange,
                  cmi_vibrant_yellow,
                  cmi_vibrant_green)
# TF-conditionalDF scatter plot
tfidf <- function() {
  file = paste("tfidf_processed.txt",sep="");
  x = read.table(file, as.is=T, header=T, sep="\t")
  x = x[(nrow(x)-15):nrow(x),]
  x$term <- gsub("_", " ", x$term)
  
  text.data = x
  text.data$tf = x$y
  text.data$df = x$x
  pdf(file=paste("tfidf_top.pdf",sep=""),onefile=TRUE,width=two_col_width,height=3,
      family="Times",title="tfidf",colormodel="rgb",paper="special")
  bp <- ggplot(NULL,aes(x=df,y=tf,label=term,color=Source))+
    geom_text(data=text.data,size=3.5,family="Times",face="plain") +
    geom_point(data=x) +
    theme_bw() + 
    scale_color_manual(name="Source",values=c(cmi_main_blue,cmi_vibrant_orange,cmi_vibrant_green)) +
    ylab("conditional tf") +
    xlab("df") +
    theme(
      axis.title.x = element_text(family = "Times", face = "plain", size=12),
      axis.title.y = element_text(family = "Times", face = "plain", size=12, angle=90),
      axis.text.x  = element_text(family = "Times", face = "plain", size=10, angle=0,vjust=0.5),
      axis.text.y  = element_text(family = "Times", face = "plain", size=10, angle=0,hjust=1),
      legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
      axis.ticks.length = unit(.15, "lines"),
      axis.ticks.margin = unit(.15,"lines"),
      legend.title = element_blank(),
      legend.position = c(0.85,0.2),
      legend.direction = "vertical",
      legend.margin = unit(0.0, "lines"),
      legend.text  = element_text(family = "Times", face = "plain", size=10),
      legend.key.height = unit(1,"lines"),
      legend.key=element_blank(),
      panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"),
      plot.margin = unit(c(0.2, 0.1,0.1,0.1), "lines")
    )
  print(bp)
  dev.off()
}

# Coauthorship graph components after removing nodes/edges
coauthorship <- function() {
  all1 = read.table("connectedAfterRemovingAuthors.txt", sep="\t", as.is=T, header=T)
  all2 = read.table("connectedAfterRemovingPapers.txt", sep="\t", as.is=T, header=T)
  all1$labels = "Authors Removed"
  all2$labels = "Papers Removed"
  all = rbind(all1, all2)
  
  pdf(file="connected_after_removing.pdf",onefile=TRUE,width=one_col_width,height=4,
      family="Times",title="methods",colormodel="rgb",paper="special")
  bp <- ggplot(all,aes(y=count,x=removed,colour=labels)) + ylab("") + xlab("Quantity Removed") +
    theme_bw() + 
    scale_colour_manual(name = "",values=c(cmi_light_blue,cmi_main_blue))+
    xlim(c(0,1000))+
    ylim(c(0,4260))+
    geom_line(size=.5) + geom_point(size=2) +
    facet_grid(type~.,scale="free_y",space="free_y")+
    theme(
      axis.title.x = element_text(family = "Times", face = "plain", size=12),
      axis.title.y = element_text(family = "Times", face = "plain", size=12, angle=90),
      axis.text.x  = element_text(family = "Times", face = "plain", size=10, angle=0,vjust=0.5),
      axis.text.y  = element_text(family = "Times", face = "plain", size=10, angle=0,hjust=1),
      legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
      axis.ticks.length = unit(.15, "lines"),
      axis.ticks.margin = unit(.15,"lines"),
      legend.title = element_blank(),
      legend.position = c(0.675,0.91),
      legend.direction = "vertical",
      legend.margin = unit(0.0, "lines"),
      legend.text  = element_text(family = "Times", face = "plain", size=10),
      legend.key.height = unit(1,"lines"),
      legend.key=element_blank(),
      strip.text.x = element_text(family = "Times", face = "plain", size=12),
      strip.text.y = element_text(family = "Times", face = "plain", size=12, angle=270),
      strip.background=element_blank(),
      plot.margin = unit(c(0.2, 0.1,0.1,0.1), "lines"))
  print(bp)
  dev.off()
}

# Growth of methods
methods <- function() {
  mydb = dbConnect(MySQL(), user='root', password='renew', dbname='annotate', host='localhost')
  query = "select year, sum(if(find_in_set('graph_theory', tags)>0, 1,0)) as 'Graph Theory', sum(if(find_in_set('supervised_learning', tags)>0, 1,0)) as 'Supervised Learning', sum(if(find_in_set('unsupervised_learning', tags)>0, 1,0)) as 'Unsupervised Learning', sum(if(find_in_set('independent_component_analysis', tags)>0, 1,0)) as 'Independent Component Analysis', sum(if(find_in_set('seed_based_correlation', tags)>0, 1,0)) as 'Seed-Based Correlation'
  from refs, expert_assignments where expert_assignments.ref_id=refs.ref_id and expert_name='Master' group by year"
  x = fetch(dbSendQuery(mydb, query), n=-1)
  x = melt(x, id.vars="year")
  x$variable = reorder(x$variable, -x$value, sum)
  x = x[which(x$year>=2002),]
  #x$year = reorder(factor(x$year), x$year)
  cols = sample(cmi_year_colors, size=length(cmi_year_colors), replace=FALSE)
  bp <- ggplot(x,aes(y=value,x=year,color=factor(variable),fill=factor(variable))) +
    theme_bw() +
    geom_line(size=1.1) +
    geom_area(position="identity",alpha=0.7)+labs(color='Method')+
    scale_color_manual(name="Method", values=cols)+
    scale_fill_manual(name="Method", values=cols)+
    scale_x_continuous(expand=c(0.01, 0.01), breaks=2002:2012) +
    scale_y_continuous(expand=c(0.01, 0.01)) +
    ylab("Matching Publication Count") +
    xlab("Method") +
    theme(
      axis.title.x = element_blank(),
      axis.title.y = element_text(angle=90),
      axis.text.x  = element_text(angle=30,vjust=1,hjust=1),
      axis.text.y  = element_text(angle=0,hjust=1),
      legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
      axis.ticks.length = unit(.15, "lines"),
      axis.ticks.margin = unit(.15,"lines"),
      legend.position = c(0.19,0.78),
      legend.direction = "vertical",
      legend.margin = unit(0.05, "lines"),
      legend.text  = element_text(),
      legend.key.height = unit(1,"lines"),
      panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"),
      plot.margin = unit(c(0.2, 0.1,0.1,0.1), "lines")
    )
  ggsave(filename="../figures/methods_growth_hist.png",width=two_col_width,height=4,dpi=100,
         title="Clinical Tags")
  ggsave(file="../figures/methods_growth_hist.pdf",width=two_col_width,height=4,
         title="Clinical Tags",colormodel="rgb",paper="special")
}

# Growth of tags
tags <- function() {
  mydb = dbConnect(MySQL(), user='root', password='renew', dbname='annotate', host='localhost')
  query = "select tags_name as Tag, year as Year, count(*) as Count from tags, tags_assignments, expert_assignments, refs where tags_id=ta_tags_id and refs.ref_id=expert_assignments.ref_id and ta_assignments_id=assignment_id and status='tagging_complete' and tags_id in (select ta_tags_id as tags_id from tags_assignments, expert_assignments where ta_assignments_id=assignment_id and status='tagging_complete' group by tags_id having count(*) > 100) group by tags_name, year"
  x = fetch(dbSendQuery(mydb, query), n=-1)
  bp <- ggplot(x,aes(y=Count,x=reorder(Tag, Count, sum),fill=factor(Year))) +
    #theme_bw()+
    geom_bar()+labs(fill='Year')+
    #scale_fill_manual(name="Year", values=cmi_year_colors)+
    #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
    #scale_x_discrete(expand=c(0.01,0.01))+
    #scale_y_continuous(expand=c(0.01,0.01))+
    theme_minimal() +
    ylab("Matching Publication Count")+
    theme(axis.text.x = element_text(angle = 30, vjust = 1.0, hjust=1.0)) +
    xlab("Tag") +
    guides(fill = guide_legend(reverse = TRUE))
    #opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
#     theme(
#         axis.title.x = element_blank(),
#         axis.title.y = element_text(angle=90),
#         axis.text.x  = element_text(angle=30,vjust=1,hjust=1),
#         axis.text.y  = element_text(angle=0,hjust=1),
#         legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
#         axis.ticks.length = unit(.15, "lines"),
#         axis.ticks.margin = unit(.15,"lines"),
#         legend.position = c(0.07,0.63),
#         legend.direction = "vertical",
#         legend.margin = unit(0.05, "lines"),        
#         legend.key.height = unit(1,"lines"),
#         panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"),
#         plot.margin = unit(c(0.2, 0.05,0.05,3.5), "lines")
#     )
  ggsave(filename="../figures/clinical_bytag_hist.png",width=two_col_width,height=6,dpi=100,
      title="Clinical Tags")
  ggsave(file="../figures/clinical_bytag_hist.pdf",width=two_col_width,height=6,
         title="Clinical Tags",colormodel="rgb",paper="special")
}

# Growth of 'connectome' usage
connectome <- function() {
  citations = read.table("connectome_growth.txt", sep="\t", as.is=T, header=T)
  citations = citations[which(citations$year>=2005),]
  pdf(file="connectome_growth.pdf",onefile=TRUE,width=9,height=4,
      family="Times",title="methods",colormodel="rgb",paper="special")
  bp <- ggplot(citations,aes(y=count,x=year,colour=metric)) +labs(colour='Metric')+
    #geom_bar(fill="#660000",alpha=.5)+
    theme_bw()+
    geom_line(size=1) + geom_point(size=3) +
    #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
    scale_y_continuous() +
    ylab("Value") +
    xlab("Year") +
    opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
    opts(axis.title.y = theme_text(family = "Times", face = "plain", size=12, angle=90)) +
    opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=10, angle=45,vjust=0.5)) +
    opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=10, angle=0,hjust=1)) +
    opts(legend.background = theme_rect(fill = 'white', size = 0, colour='white', linetype='dashed')) +
    opts(axis.ticks.length = unit(.15, "lines")) +
    opts(axis.ticks.margin=unit(.15,"lines")) +
    opts(legend.position=c(0.15,0.8)) +
    opts(panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"))+
    opts(plot.margin = unit(c(0.75, 0.75,0.75,0.75), "lines"))
  
  print(bp)
  dev.off()
}

# Journal counts by year
journals <- function() {
  mydb = dbConnect(MySQL(), user='root', password='renew', dbname='annotate', host='localhost')
  dbSendQuery(mydb, "update refs left join journal_synonyms on refs.journal=js_from set refs.normalized_journal=if(js_to is not null, js_to, refs.journal)")
  query = "select year as Year, normalized_journal as journal, count(*) as Count from refs, expert_assignments where refs.ref_id=expert_assignments.ref_id and status='tagging_complete' and exists (select count(normalized_journal) from refs as refs2, expert_assignments as ea2 where refs2.ref_id=ea2.ref_id and ea2.status='tagging_complete' and refs2.normalized_journal=refs.normalized_journal group by refs2.normalized_journal having count(*)>50) group by normalized_journal, year"
  x = fetch(dbSendQuery(mydb, query), n=-1)
  bp <- ggplot(x,aes(y=Count,x=reorder(journal, Count, sum),fill=factor(Year))) +
    theme_bw() +
    #scale_fill_manual(name="Year", values=cmi_year_colors) +
    geom_bar(alpha=1.0)+ 
    labs(fill='Year')+
    #scale_x_discrete(expand=c(0.01,0.01))+
    #scale_y_continuous(expand=c(0.01,0.01))+
    theme_minimal() +
    ylab("Publication Count") +
    theme(axis.text.x = element_text(angle = 30, vjust = 1.0, hjust=1.0)) +
    xlab("Journal") + 
    guides(fill = guide_legend(reverse = TRUE))
#     theme(
#       axis.title.x = element_blank(),
#       axis.title.y = element_text(angle=90),
#       axis.text.x  = element_text(angle=30,vjust=1,hjust=1),
#       axis.text.y  = element_text(angle=0,hjust=1),
#       legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
#       axis.ticks.length = unit(.15, "lines"),
#       axis.ticks.margin = unit(.15,"lines"),
#       legend.position = c(0.07,0.63),
#       legend.direction = "vertical",
#       legend.margin = unit(0.05, "lines"),
#       legend.text  = element_text(),
#       legend.key.height = unit(1,"lines"),
#       panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"),
#       plot.margin = unit(c(0.2, 0.05,0.05,3.5), "lines")
#     )
  ggsave(filename="../figures/journal_dist.png",width=two_col_width,height=6,dpi=100,
      title="growth_rate_journal")  
  ggsave(filename="../figures/journal_dist.pdf",onefile=TRUE,width=two_col_width,height=4,
      title="growth_rate_journal",colormodel="rgb",paper="special")
  
}

# Overall corpus growth
corpusGrowth <- function() {
  cutoff = 2008
  startYear = 2003
  x = read.table("overall_growth.txt", as.is=T, header=T, sep="\t")
  x = x[which(x$year>1994),]
  print(x)
  yearFreqs = x
  yearFreqs=melt(yearFreqs,id="year")
  yearFreqs$year=yearFreqs$year
  yearFreqs$lvalue=log(yearFreqs$value)
  yearFreqs$lvalue[is.infinite(yearFreqs$lvalue)]=0
  
  yearFreqs$labels=yearFreqs$variable
  levels(yearFreqs$labels)=c("fMRI","Resting State")
  
  yearFreqs_rs=subset(yearFreqs,variable=="rsTotal",drop=TRUE)
  yearFreqs_rs$vol=cumsum(yearFreqs_rs$value)
  yearFreqs_pre2005_rs=subset(yearFreqs_rs,(year>startYear)&(year<=cutoff),drop=TRUE)
  yearFreqs_post2004_rs=subset(yearFreqs_rs,year>=cutoff,drop=TRUE)
  
  rs_model_all=lm(log(vol)~year,data=yearFreqs_rs)
  rs_model_pre2005=lm(log(vol)~year,data=yearFreqs_pre2005_rs)
  rs_model_post2004=lm(log(vol)~year,data=yearFreqs_post2004_rs)
  
  print(rs_model_pre2005)
  print(rs_model_post2004)
  
  yearFreqs$model_fit[yearFreqs$variable=="rsTotal"]=exp(fitted(rs_model_all))
  yearFreqs$model_fit_pre2005[(yearFreqs$variable=="rsTotal")&(yearFreqs$year<=cutoff)&(yearFreqs$year>startYear)]=exp(fitted(rs_model_pre2005))
  yearFreqs$model_fit_post2004[(yearFreqs$variable=="rsTotal")&(yearFreqs$year>=cutoff)]=exp(fitted(rs_model_post2004))
  yearFreqs$vol[yearFreqs$variable=="rsTotal"]=yearFreqs_rs$vol
  
  yearFreqs_fmri=subset(yearFreqs,variable=="fmriTotal",drop=TRUE)
  yearFreqs_fmri$vol=cumsum(yearFreqs_fmri$value)
  yearFreqs_pre2005_fmri=subset(yearFreqs_fmri,(year>startYear)&(year<=cutoff),drop=TRUE)
  yearFreqs_post2004_fmri=subset(yearFreqs_fmri,year>=cutoff,drop=TRUE)
  fmri_model_all=lm(log(vol)~year,data=yearFreqs_fmri)
  fmri_model_pre2005=lm(log(vol)~year,data=yearFreqs_pre2005_fmri)
  fmri_model_post2004=lm(log(vol)~year,data=yearFreqs_post2004_fmri)
  
  print(fmri_model_pre2005$residuals)
  print(fmri_model_pre2005)
  print(fmri_model_post2004)
  print(fmri_model_all)
  
  yearFreqs$model_fit[yearFreqs$variable=="fmriTotal"]=exp(fitted(fmri_model_all))
  yearFreqs$model_fit_post2004[(yearFreqs$variable=="fmriTotal")&(yearFreqs$year>=cutoff)]=exp(fitted(fmri_model_post2004))
  yearFreqs$model_fit_pre2005[(yearFreqs$variable=="fmriTotal")&(yearFreqs$year>startYear)&(yearFreqs$year<=cutoff)]=exp(fitted(fmri_model_pre2005))
  
  
  yearFreqs$vol[yearFreqs$variable=="fmriTotal"]=yearFreqs_fmri$vol
  yearFreqs$pre_2005_vol[yearFreqs$year<=cutoff]=yearFreqs$vol[yearFreqs$year<=cutoff]
  yearFreqs$post_2004_vol[yearFreqs$year>=cutoff]=yearFreqs$vol[yearFreqs$year>=cutoff]
  
  p=ggplot(yearFreqs)+
    theme_bw()+
    scale_x_continuous(expand=c(0.01,0.01))+
    scale_y_continuous(expand=c(0.01,0.01))+
    geom_area(aes(x=year,y=pre_2005_vol),fill=cmi_grey,alpha=.7)+
    geom_line(aes(x=year,y=model_fit_pre2005),color=cmi_grey)+
    geom_area(aes(x=year,y=post_2004_vol),fill=cmi_main_blue,alpha=.7)+
    geom_line(aes(x=year,y=model_fit_post2004),color=cmi_main_blue)+
    facet_grid(labels~.,scale="free")+
    ylab("Corpus Size") +
    xlab("Year") +    
    opts(axis.title.y = theme_text(angle=90)) +
    opts(strip.text.x = theme_text()) +
    opts(strip.text.y = theme_text(angle=270)) +
    opts(axis.text.x  = theme_text()) +
    opts(axis.text.y  = theme_text(angle=90)) +
    opts(axis.ticks.length = unit(.15, "lines")) +
    
    
    opts(strip.background=element_blank())
  #opts(plot.margin = unit(c(0.75, 0.25,0.5,0.75), "lines"))+
  #opts(axis.ticks.margin=unit(.15,"lines")) +
  ggsave(plot=p,filename="../figures/overall_growth.png",width=one_col_width,height=4,dpi=100,
         title="Overall Growth")  
  ggsave(plot=p,filename="../figures/overall_growth.pdf",onefile=TRUE,width=one_col_width,height=4,
      title="Overall Growth",colormodel="rgb",paper="special")
}

# Comparison of 'connectome' usage between DTI and RS libraries
dtiRs <- function() {
        all = read.table("dti_growth.txt", sep="\t", as.is=T, header=T)
	connect = all[which(all$Tag=="Connectome"),]
	all = all[which(all$Tag=="All"),]
        pdf(file="dti_vs_rs_all_growth.pdf",onefile=TRUE,width=9,height=6,
                family="Times",title="methods",colormodel="rgb",paper="special")
        bp <- ggplot(all,aes(y=count,x=Year,colour=Library)) + ylab("Count") +
            #geom_bar(fill="#660000",alpha=.5)+
            geom_line(size=1) + geom_point(size=3) +
            #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
            scale_y_continuous() +
            xlab("Year") +
	    
            opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
            opts(axis.title.y = theme_text(family = "Times", face = "plain", size=12, angle=90)) +
            opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=10, angle=45,vjust=0.5)) +
            opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=10, angle=0,hjust=1)) +
            opts(axis.ticks.length = unit(.15, "lines")) +
            opts(axis.ticks.margin=unit(.15,"lines")) +
            opts(plot.margin = unit(c(0.75, 0.75,0.75,0.75), "lines"))
	    print(bp)
        dev.off()
        pdf(file="dti_vs_rs_connectome_growth.pdf",onefile=TRUE,width=9,height=6,
                family="Times",title="methods",colormodel="rgb",paper="special")
        bp <- ggplot(connect,aes(y=count,x=Year,colour=Library)) + ylab("Count") +
            #geom_bar(fill="#660000",alpha=.5)+
            geom_line(size=1) + geom_point(size=3) +
            #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
            scale_y_continuous() +
            xlab("Year") +
	    
            opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
            opts(axis.title.y = theme_text(family = "Times", face = "plain", size=12, angle=90)) +
            opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=10, angle=45,vjust=0.5)) +
            opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=10, angle=0,hjust=1)) +
            opts(axis.ticks.length = unit(.15, "lines")) +
            opts(axis.ticks.margin=unit(.15,"lines")) +
            opts(plot.margin = unit(c(0.75, 0.75,0.75,0.75), "lines"))
	    print(bp)
        dev.off()
}

# Impact factor by author
authorImpact <- function() {
	citations = read.table("impactByAuthor.txt", as.is=T, header=T, sep="\t", allowEscapes=T)
	pdf(file="impactByAuthor.pdf",onefile=TRUE,width=9,height=6,
   		family="Times",title="citations",colormodel="rgb",paper="special")
	bp <- ggplot(citations,aes(y=impactFactor,reorder(author, impactFactor))) +
	    geom_bar(fill="#660000",alpha=.5)+
	    #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
	    scale_y_continuous() +
	    ylab("Impact Factor") +
	    xlab("Author") +
	    opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
	    opts(axis.title.y = theme_text(family = "Times", face = "plain", size=12, angle=90)) +
	    opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=10, angle=45,vjust=0.5)) +
	    opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=10, angle=0,hjust=1)) +
	    opts(axis.ticks.length = unit(.15, "lines")) +
	    opts(axis.ticks.margin=unit(.15,"lines")) +
	    opts(plot.margin = unit(c(0.75, 0.75,0.75,0.75), "lines"))
	print(bp)
   	dev.off()
}

# Citations by author
authorCitations <- function() {
	citations = read.table("citationsByAuthor.txt", as.is=T, header=T, sep="\t", allowEscapes=T)
	pdf(file="citationsByAuthor.pdf",onefile=TRUE,width=9,height=6,
   		family="Times",title="citations",colormodel="rgb",paper="special")
	bp <- ggplot(citations,aes(y=citationCount,reorder(author,citationCount))) +
	    geom_bar(fill="#660000",alpha=.5)+
	    #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
	    scale_y_continuous() +
	    ylab("Citations") +
	    xlab("Author") +
	    opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
	    opts(axis.title.y = theme_text(family = "Times", face = "plain", size=12, angle=90)) +
	    opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=10, angle=45,vjust=0.5)) +
	    opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=10, angle=0,hjust=1)) +
	    opts(axis.ticks.length = unit(.15, "lines")) +
	    opts(axis.ticks.margin=unit(.15,"lines")) +
	    opts(plot.margin = unit(c(0.75, 0.75,0.75,0.75), "lines"))
	print(bp)
   	dev.off()
}

paperCitations <- function() {
	citations = read.table("bag_report_formatted.txt", as.is=T, header=T, sep=",",quote="")
  print(citations$title)
	citations$title <- sub("!", "\n", citations$title)

	pdf(file="citation_pageranks.pdf",onefile=TRUE,width=9,height=6,
   		family="Times",title="citations",colormodel="rgb",paper="special")
	bp <- ggplot(citations,aes(y=mean,x=reorder(title,mean)))+
	    theme_bw()+
	    geom_bar(fill="#660000",alpha=0.7)+
	    geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
	    coord_flip()+
	    scale_y_continuous() +
	    ylab("Pagerank") +
	    xlab("Title") +
	    opts(axis.title.x = theme_text(family = "Times", face = "plain", size=14, hjust=0.85)) +
	    opts(axis.title.y = theme_text(family = "Times", face = "plain", size=14, angle=90)) +
	    opts(axis.text.x  = theme_text(family = "Times", face = "plain", size=12, angle=0,vjust=0.5)) +
	    opts(axis.text.y  = theme_text(family = "Times", face = "plain", size=12, angle=0,hjust=1)) +
	    opts(axis.ticks.length = unit(.15, "lines")) +
	    opts(axis.ticks.margin=unit(.15,"lines")) +
	    opts(plot.margin = unit(c(0.75, 0.25,0.25,0.75), "lines"))
	print(bp)
   	dev.off()
}

piles <- function() {
  
  mydb = dbConnect(MySQL(), user='root', password='renew', dbname='annotate', host='localhost')
  query = "select expert_name, status, count(*) as ctr from expert_assignments where expert_name != 'Master' group by expert_name, status"
  x = fetch(dbSendQuery(mydb, query), n=-1)
  x$status[which(x$status=="pending_tagging")] = "Pending Tagging"
  x$status[which(x$status=="pending_approval")] = "Pending Approval"
  x$status[which(x$status=="tagging_complete")] = "Complete"
  x$status[which(x$status=="remove_this")] = "Trash"
  x$status = factor(x$status, levels=c("Pending Approval", "Pending Tagging", "Trash", "Complete"))
    bp <- ggplot(x,aes(y=ctr,x=expert_name,fill=factor(status))) +
      theme_bw()+
      geom_bar()+labs(fill='Status')+
      scale_fill_manual(name="Status", values=(cmi_year_colors))+
      #geom_errorbar(aes(ymin = mean - stddev, ymax = mean + stddev),color="#660000",width=0.5)+
      scale_x_discrete(expand=c(0.01,0.01))+
      scale_y_continuous(expand=c(0.01,0.01))+
      ylab("Count") +
      #xlab("Tag") +
      #opts(axis.title.x = theme_text(family = "Times", face = "plain", size=12)) +
      theme(
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x  = element_text(angle=30,vjust=1,hjust=1),
        axis.text.y  = element_text(angle=0,hjust=1),
        legend.background = element_rect(fill = 'white', size = 0, colour='white', linetype='dashed'),
        axis.ticks.length = unit(.15, "lines"),
        axis.ticks.margin = unit(.15,"lines"),
        legend.position="bottom",        
        legend.key.height = unit(1,"lines"),
        legend.margin = unit(0.05, "lines"),
        panel.margin = unit(c(0.0, 0.0,0.0,0.0), "lines"),
        plot.margin = unit(c(0.05, 0.05,0.05,0.05), "lines")
      ) +
  guides(fill=guide_legend(title=""))  
    ggsave(filename="../figures/piles.png",width=two_col_width,height=4,dpi=100,
           title="Piles")
    ggsave(file="../figures/piles.pdf",width=two_col_width,height=4,
           title="Piles",colormodel="rgb",paper="special")
  }

journals()
tags()
piles()
methods()
corpusGrowth()
stop()

tfidf()
coauthorship()
methods()
tags()
connectome()
journals()
corpusGrowth()
dtiRs()
authorImpact()
authorCitations()
paperCitations()
