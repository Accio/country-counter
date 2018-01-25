## Use restcountry.eu REST API to generate a small graph representing interactionality

library(rjson)
library(ribiosUtils)
library(RCurl)
library(ribiosCGI)
library(ribiosIO)
library(ggplot2)
library(ribiosPlot)

members <- c("France"=4,
             "Germany"=7,
             "Russian Federation"=2,
             "Hungary"=1,
             "Malaysia"=1,
             "Switzerland"=3,
             "Ukraine"=1,
             "Spain"=2,
             "Italy"=2,
             "Canada"=2,
             "Greece"=1,
             "China"=2,
             "Serbia"=1)
membersDf <- data.frame(Country=names(members), Count=members, row.names=NULL)

getCountryInfo <- function(countryName) {
  cUrl <- sprintf("https://restcountries.eu/rest/v2/name/%s?fullText=true",
                  ribiosCGI::cgiEncodeWord(countryName))
  cRes <- getURL(cUrl)
  jsonList <- rjson::fromJSON(cRes)[[1]]
  res <- list(flag=jsonList$flag, code=jsonList$alpha3Code)
  return(res)
}
membersInfo <- lapply(membersDf$Country, getCountryInfo)
membersDf$Flag <- sapply(membersInfo, function(x) x$flag)
membersDf$Code <- sapply(membersInfo, function(x) x$code)

## get flags
createDir(figDir <- "./figure")
flagFiles <- sapply(membersDf$Flag, function(url) {
  fn <- file.path(figDir, basename(url))
  download.file(url, destfile=fn)
  return(fn)
})
membersDf$FlagFiles <- flagFiles

membersDf <- sortByCol(membersDf, "Count", decreasing=TRUE)
membersDf$Country <- factor(membersDf$Country, levels=as.character(membersDf$Country))
createDir(outDir <- "./output")
writeMatrix(membersDf, file.path(outDir, "BEDA-members-byCountry-201801.txt"))

## draw the visualization
ggplot(membersDf, aes(x="", y=Count, fill=Country)) +
  geom_bar(width = 1, stat = "identity") + coord_polar("y", direction = -1) + 
  scale_fill_manual(values=fcbrewer(membersDf$Country, "Spectral")) +
  geom_text(aes(y = sum(Count)-c(0, cumsum(Count)[-length(Count)]),
                label = c(0, cumsum(Count)[-length(Count)])), size=5) +
  theme(axis.text=element_text(size=14), axis.title = element_text(size=15),
        axis.ticks = element_blank(),
        panel.border = element_blank(),
        panel.grid=element_blank()) + 
  xlab("") + ylab("")
ipdf(file.path(figDir, "Country-pie.pdf"))
