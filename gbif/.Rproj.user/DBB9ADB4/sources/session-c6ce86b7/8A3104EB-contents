## this scrip downloads data from GBIF with the following criteria:
# - download critera:
# * scientific name: Aves
# * occurrence status: present
# * has geospatial issue: F
# * has coordinates: T
# * coordinate uncertainty in meters: 0-100
# * year: between beginning of year xx (eg. 2013) and end of year xx (eg. 2022) - always 10 years
# * restricted to a polygon drawn around Europe 

### for testing:
## use a smaller timerange, e.g. 2-3 years
## use the polygon corresponding to "metnau" that is commented out


## ToDo
## 1.# create a variable to easily change the years of download. Given that we always will want 10 years, maybe the variable could be 'currentYear', and than it would be something like e.g.
# currentYear <- 2025
# startYear<-currentYear-9 
# pred_and(pred_gte("year", startYear),pred_lte("year", currentYear))'

## 2.# create a variable so the path to the folder can be easily changed
## 3.# add a line of code to unzip the downloaded file (just before extracting the species names)
## 4.# check if it is possible to get though R the citation for the specific download. On the gibf user account page, all downloads & citation a visible, it would be great to save the citation though R (in a e.g. txt file)
## 5.# put the variables that need/can be modified, eg year and path to folder at the top of the scrip so it can easily be accessed

###########################
### download gbif data ####
###########################
usethis::edit_r_environ()
# GBIF_USER="xxx"
# GBIF_PWD="xxx"
# GBIF_EMAIL="xxx@xx"

library(rgbif)

occ_d <- occ_download(
  pred("hasGeospatialIssue", FALSE),
  pred("hasCoordinate", TRUE),
  pred("occurrenceStatus","PRESENT"), 
  pred_and(pred_gte("year", 2013),pred_lte("year", 2022)),
  pred_within("POLYGON((-26.01051 33.20471,-25.27652 33.20471,47.9298 32.46067,48.89006 71.94297,-25.27652 71.22729,-26.01051 71.22729,-26.01051 33.20471))"), # eu, drew polygon on gbif as tukey is not included in the continent:europe
  # pred_within("POLYGON((8.96136 47.7155,9.02477 47.7155,9.02477 47.74642,8.96136 47.74642,8.96136 47.7155))"), # metnau for testing code
  pred("taxonKey", 212), # download all of class Aves
  pred_lte("coordinateUncertaintyInMeters","100"),
  format = "SIMPLE_CSV"
)

occ_download_wait(occ_d) # check now and again, as connection fails. Status can also be looked up on gbif webpage names in "occ_d"
dwn <- occ_download_get(occ_d,path="/home/ascharf/Documents/Projects/E4Warning")
# dta <- occ_download_import(dwn) # if dwn is loaded, else
dta <- occ_download_import(as.download("/home/ascharf/Documents/Projects/E4Warning/0015360-231002084531237.zip"))


################################################
### get all species names included in table ####
################################################
library(readr)
mycsv <- "/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv"
df <- read_delim(mycsv, 
                 delim="\t",
                 col_select = "species")

spsunique<-unique(df$species)
length(spsunique)
# [1] 1182

saveRDS(spsunique,"/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")


###########################################
### extract and save table per species ####
###########################################

library(readr)

dir.create(paste0("/home/ascharf/Documents/Projects/E4Warning/gbifData/","spsTBof_0015360_231002084531237"))

spsL <- readRDS("/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")
lapply(spsL, function(x){
  print(x)
  bb <- read_delim(pipe(paste0("cat ","'","/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv","'"," | grep ","'",x,"\\|species","'")),delim="\t")
  print(nrow(bb))
  saveRDS(bb, paste0("/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/",gsub(" ","_",x),".rds"))
})


### checking if all tables are created, if not, run again those that are missing. 
library(readr)

spsL <- readRDS("/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")
spsLasFn <- paste0(gsub(" ","_",spsL),".rds")
lf <- list.files(path="/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/", full.names = F)

missingSps <- spsLasFn[!spsLasFn%in%lf]
missingSps <- missingSps[-1]

misSpsNms <- gsub(".rds","",gsub("_"," ",missingSps))

lapply(misSpsNms, function(x){
  print(x)
  bb <- read_delim(pipe(paste0("cat ","'","/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv","'"," | grep ","'",x,"\\|species","'")),delim="\t")
  print(nrow(bb))
  saveRDS(bb, paste0("/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/",gsub(" ","_",x),".rds"))
})
