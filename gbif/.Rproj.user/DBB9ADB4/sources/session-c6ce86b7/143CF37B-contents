occ_d <- occ_download(
  # Start GBIF occurrence data download query and store the request in 'occ_d'
  
  pred("hasGeospatialIssue", FALSE),
  # Include only records that do NOT have known geospatial issues (e.g., flagged for suspicious coordinates)
  
  pred("hasCoordinate", TRUE),
  # Include only records that have geographic coordinates (latitude and longitude available)
  
  pred("occurrenceStatus", "PRESENT"), 
  # Include only records that indicate the species was observed (not absent or fossil)
  
  pred_and(pred_gte("year", 2013), pred_lte("year", 2022)),
  # Include only records from the years 2013 to 2022 (inclusive)
  
  pred_within("POLYGON((-26.01051 33.20471,-25.27652 33.20471,47.9298 32.46067,48.89006 71.94297,-25.27652 71.22729,-26.01051 71.22729,-26.01051 33.20471))"),
  # Spatial filter: Include only records within this custom polygon (covers most of Europe but excludes Turkey)
  #WKT stands for Well-Known Text, and it’s a standard text format used to represent geometries like points, lines, and polygons in GIS (geographic information systems).
  
  # pred_within("POLYGON((8.96136 47.7155,9.02477 47.7155,9.02477 47.74642,8.96136 47.74642,8.96136 47.7155))"),
  # (Commented out) – an alternative small test polygon for Metnau, used during testing
  
  pred("taxonKey", 212),
  # Filter to include only records of the taxonomic group with GBIF taxonKey 212 (which corresponds to Class Aves = birds)
  
  pred_lte("coordinateUncertaintyInMeters", "100"),
  # Include only records with a spatial uncertainty of 100 meters or less (to ensure higher location accuracy)
  
  format = "SIMPLE_CSV"
  # Request the download in SIMPLE_CSV format (clean, easy to parse format with standard fields)
)

#The following functions take one key and one value:
  #• pred: equals
#• pred_lt: lessThan
#• pred_lte: lessThanOrEquals
#• pred_gt: greaterThan
#• pred_gte: greaterThanOrEquals
#• pred_like: like
#The following function is only for geospatial queries, and only accepts a WKT string:
  #• pred_within: within
#The following function is only for stating the you don’t want a key to be null, so only accepts one
#key:
  #• pred_notnull: isNotNull
#The following function is only for stating that you want a key to be null.
#• pred_isnull : isNull
#The following two functions accept multiple individual predicates, separating them by either "and"
#or "or":
  #• pred_and: and
#• pred_or: or




occ_download_wait(occ_d)
# Waits for the GBIF download request to be processed and marked as ready.
# 'occ_d' is the object from occ_download(), containing the download key.
# This checks the status repeatedly until the data is ready to download.

dwn <- occ_download_get(occ_d, path = "/home/ascharf/Documents/Projects/E4Warning")
# Once the download is ready, this downloads the corresponding .zip file from GBIF.
# It saves the file into the specified directory.
# The 'dwn' object contains metadata including the path to the .zip file.

# dta <- occ_download_import(dwn)
# This would import the occurrence data from the downloaded .zip file into R as a data frame.
# It uses the result stored in 'dwn' directly (commented out in this case).

dta <- occ_download_import(as.download("/home/ascharf/Documents/Projects/E4Warning/0015360-231002084531237.zip"))
# Alternatively, if the .zip file is already downloaded, you can load it directly from its path.
# 'as.download()' wraps the .zip path into the correct object format.
# 'occ_download_import()' then reads the CSV file inside the .zip into a usable R data frame (stored in 'dta').


write_delim: Write a data frame to a delimited file

library(readr)
# Load the 'readr' package for fast and efficient reading of tabular data.

mycsv <- "/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv"
# Define the file path to the downloaded GBIF CSV file.

df <- read_delim(mycsv, 
                 delim = "\t",
                 col_select = "species")
# Read the CSV file using tab ("\t") as the delimiter.
# Only the "species" column is selected for reading to save memory.
#“Read the file at mycsv. The columns are separated by tab characters, not commas or semicolons. And only read the species column.”
# GBIF Data Format: Tab-separated (TSV)

spsunique <- unique(df$species)
# Extract the unique species names from the "species" column.

length(spsunique)
# Count how many unique species are in the dataset (expected output: 1182)

saveRDS(spsunique, "/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")
# Save the unique species list as an .rds file for later use.
# .rds files are compact, binary R objects that can be quickly loaded back into R.




###########################################
### extract and save table per species ####
###########################################

library(readr) 
# Load readr for efficient reading/writing of tabular data.

dir.create(paste0("/home/ascharf/Documents/Projects/E4Warning/gbifData/","spsTBof_0015360_231002084531237"))
# Create a new directory to store individual species tables if it doesn't already exist.

spsL <- readRDS("/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")
# Load the list of unique species names from a previously saved RDS file.

lapply(spsL, function(x){
  print(x) 
  # Print the current species name to track progress.
  
  bb <- read_delim(pipe(paste0(
    "cat '",
    "/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv",
    "' | grep '", x, "\\|species'")), delim = "\t")
  # Use grep via a pipe to extract only rows that match the current species name.
  # Also include the header row by matching the word 'species'.
  # This avoids loading the entire large file into memory.
  
  print(nrow(bb)) 
  # Show how many rows were extracted for this species.
  
  saveRDS(bb, paste0(
    "/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/",
    gsub(" ","_",x), ".rds"))
  # Save the extracted table as an RDS file using the species name (spaces replaced with underscores).
})


#####################################################
### check for missing species and re-extract them ###
#####################################################

library(readr) 
# Re-load the readr package (in case this part is run separately).

spsL <- readRDS("/home/ascharf/Documents/Projects/E4Warning/gbifData/species_in_0015360-231002084531237.rds")
# Load the full list of species names again.

spsLasFn <- paste0(gsub(" ","_",spsL), ".rds")
# Create the expected file names by replacing spaces with underscores and adding ".rds".

lf <- list.files(path = "/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/", full.names = FALSE)
# List all files already saved in the output directory.

missingSps <- spsLasFn[!spsLasFn %in% lf]
# Find which species files are missing by comparing expected vs. actual filenames.

missingSps <- missingSps[-1]
# Remove the first element (possibly header or corrupted entry).

misSpsNms <- gsub(".rds", "", gsub("_", " ", missingSps))
# Convert the filenames back to original species names by reversing the underscore replacement.

lapply(misSpsNms, function(x){
  print(x) 
  # Print missing species name for tracking.
  
  bb <- read_delim(pipe(paste0(
    "cat '",
    "/home/ascharf/Documents/Projects/E4Warning/gbifData/0015360-231002084531237.csv",
    "' | grep '", x, "\\|species'")), delim = "\t")
  # Re-run grep to extract data for the missing species (plus the header row).
  
  print(nrow(bb)) 
  # Print the number of rows retrieved.
  
  saveRDS(bb, paste0(
    "/home/ascharf/Documents/Projects/E4Warning/gbifData/spsTBof_0015360_231002084531237/",
    gsub(" ","_",x), ".rds"))
  # Save the re-extracted data using the same file-naming convention.
})

