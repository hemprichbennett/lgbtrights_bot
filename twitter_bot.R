# Assuming that the table was nicely formatted, which it isn't

library(rtweet)
library(here)
library(jsonlite)
library(rvest)

setwd(here())

flag <- F

continents_vec <- c(
  "https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Africa",
  "https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Americas",
  "https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Asia",
  "https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Europe",
  "https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Oceania"
)


# Flags files and json sourced from https://github.com/hjnilsson/country-flags
codes <- fromJSON("countrycodes.json", simplifyVector = FALSE)
countries <- as.list(names(unlist(codes)))
names(countries) <- unlist(codes)


## twitter token should be generated with the instructions here(http://rtweet.info/articles/auth.html), but I found it easier to just load the token rather than making it an environment variable
twitter_token <- readRDS("twitter_token.RDS")



table_list <- html_table(read_html(continents_vec[sample(length(continents_vec), 1)]), fill = TRUE)
table_list <- table_list[which(unlist(lapply(table_list, nrow) > 1))]

df <- table_list[[sample(length(table_list), 1)]]

# Chose the values to tweet
column_chosen <- sample(seq(2, ncol(df)), 1)
row_chosen <- sample(nrow(df), 1)

good_string <- F
i <- 1
while (good_string == F| i < 100) {
  string <- df[row_chosen, column_chosen]
  string <- gsub("\\[.+\\]", "", string) # Get rid of any citations
  string <- gsub("\\\n", " ", string) # get rid of any newlines
  string <- gsub("\\/", "", string)
  string <- tolower(string)
  string <- gsub(" un ", "UN", string)
  if (!is.na(string) && nchar(string)> 1){
    good_string <- T
  }
  i <- i + 1
}
rights_name <- gsub("\\.", " ", colnames(df)[column_chosen])
country <- df[row_chosen, 1]
country <- gsub(" \\(.+$", "", country)
country <- gsub("\\(.+$", "", country)
country <- gsub("\\\n", " ", country)
outstring <- paste(country, ". ", rights_name, ": ", string, " #LGBTQ #equality", sep = "")

if (nchar(outstring) <= 240) {
  tweetable <- T
} else {
  tweetable <- F
}

if (!is.null(countries[[country]])) { # If we find the country name in the list of countries
  flag <- T
  flagname <- paste("png1000px/", countries[[country]], ".png", sep = "")
  flagname <- tolower(flagname)
  print(flagname)
}


# #Now to send the tweet
if (flag == T) {
  post_tweet(
    status = outstring, token = twitter_token,
    in_reply_to_status_id = NULL, media = flagname
  )
  print("flag used")
} else {
  post_tweet(
    status = outstring, token = twitter_token,
    in_reply_to_status_id = NULL
  )
  print("flag not used")
}




print(outstring)

# End
print(Sys.time())
