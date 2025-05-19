###########################
### download gbif data ####
###########################
#usethis::edit_r_environ()
#GBIF_USER="tavakol5272"
#GBIF_PWD="Radmehr89*"
#GBIF_EMAIL="ntavakol@ab.mpg.de"

library(rgbif)
library(readr)

#define the year range
end_year <- 2025
start_year <- end_year - 2
#start_year <- end_year - 9

# Define  custom geographic area
region_polygon <- "POLYGON((8.96136 47.7155,9.02477 47.7155,9.02477 47.74642,8.96136 47.74642,8.96136 47.7155))"
#region_polygon <- "POLYGON((-26.01051 33.20471,-25.27652 33.20471,47.9298 32.46067,48.89006 71.94297,-25.27652 71.22729,-26.01051 71.22729,-26.01051 33.20471))"

# Define download path
download_path <- "E:/Neuer Ordner/konstany study/hiwi/animove/animove_R/rgbif"
#download_path <- "/home/ascharf/Documents/Projects/E4Warning"# Define download path

output_path <- file.path(download_path, "output")
dir.create(output_path, showWarnings = FALSE, recursive = TRUE)


occ_d <- occ_download(
  pred("hasGeospatialIssue", FALSE),
  pred("hasCoordinate", TRUE),
  pred("occurrenceStatus", "PRESENT"),
  pred_and(pred_gte("year", start_year), pred_lte("year", end_year)),
  pred_within(region_polygon),
  pred("taxonKey", 212),  
  pred_lte("coordinateUncertaintyInMeters", "100"),
  format = "SIMPLE_CSV"
)

#str(occ_d)

download_key <- as.character(occ_d)
print(download_key)

zip_file <- file.path(output_path, paste0(download_key, ".zip"))

occ_download_wait(occ_d)
dwn <- occ_download_get(occ_d, path = output_path)


################################################
### get citation and save it ####
################################################

# Occurrence data downloads
#https://www.gbif.org/citation-guidelines#occDataDownload

citation_text <- attr(occ_d, "citation")
citation_file <- file.path(output_path, paste0("GBIF_citation_", download_key, ".txt"))
writeLines(citation_text, citation_file)


################################################
### get all species names included in table ####
################################################
unzip(dwn[[1]], exdir = output_path)

csv_file <- file.path(output_path, paste0(download_key, ".csv"))  ##make sure we have correct file name

dir.create(file.path(output_path, "gbifData"), showWarnings = FALSE)
rds_path <- file.path(output_path, "gbifData", paste0("species_in_", download_key, ".rds"))
dta <- read_delim(csv_file, delim = "\t")
#head(dta)
#summary(dta)

spsunique<-unique(dta$species)
length(spsunique)

saveRDS(spsunique, rds_path)

###########################################
### extract and save table per species ####
###########################################


species_tables_folder <- file.path(output_path, "gbifData", paste0("spsTBof_", download_key))
dir.create(species_tables_folder, showWarnings = FALSE, recursive = TRUE)

spsL <- readRDS(rds_path)

lapply(spsL, function(x){
  print(x)
  bb <- dta[dta$species == x, ]
  print(nrow(bb))
  file_name <- paste0(gsub(" ", "_", x), ".rds")
  saveRDS(bb, file.path(species_tables_folder, file_name))
  
})



### checking if all tables are created, if not, run again those that are missing. 

spsLasFn <- paste0(gsub(" ","_",spsL),".rds")
lf <- list.files(species_tables_folder, pattern = "\\.rds$", full.names = F)

missingSps <- setdiff(spsLasFn, lf)

#missingSps <- missingSps[-1]

misSpsNms <- gsub(".rds","",gsub("_"," ",missingSps))

lapply(misSpsNms, function(x){
  print(x)
  bb <- dta[dta$species == x, ]
  print(nrow(bb))
  file_name <- paste0(gsub(" ", "_", x), ".rds")
  saveRDS(bb, file.path(species_tables_folder, file_name))
  
})


