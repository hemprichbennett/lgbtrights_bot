#Assuming that the table was nicely formatted, which it isn't

library(rtweet)
library(here)
library(jsonlite)


setwd(here())

wait_in_r <- T
wait_duration <- 211*60 #Number of seconds to wait if wait_in_r == true
#df <- read.csv('unformatted_rights.csv', stringsAsFactors = F)
flag <- F

continents_vec <- c('https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Africa',
                    'https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Americas',
                    'https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Asia',
                    'https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Europe',
                    'https://en.wikipedia.org/wiki/Template:LGBT_rights_table_Oceania')


#Flags files and json sourced from https://github.com/hjnilsson/country-flags
codes <- fromJSON('countrycodes.json', simplifyVector = FALSE)
countries <- as.list(names(unlist(codes)))
names(countries) <- unlist(codes)


##twitter token should be generated with the instructions here(http://rtweet.info/articles/auth.html), but I found it easier to just load the token rather than making it an environment variable
twitter_token <- readRDS('twitter_token.RDS')


A <- FALSE
while(A==FALSE){
  

  
  table_list <- html_table(read_html(continents_vec[sample(length(continents_vec),1)]), fill=TRUE)
  table_list <- table_list[which(unlist(lapply(table_list, nrow)>1))]
  
  df <- table_list[[sample(length(table_list),1)]]
  
  #Chose the values to tweet
  column_chosen <- sample(seq(2,ncol(df)), 1)
  row_chosen <- sample(nrow(df), 1)
  
  
  string <- df[row_chosen, column_chosen]
  string <- gsub('\\[.+\\]', '', string) #Get rid of any citations
  if(is.na(string)){
    next()#skip any truly empty fields
  }
  if(nchar(string)<2){
    next()#Skip any fields which are blank
  }
  rights_name <- gsub('\\.', ' ', colnames(df)[column_chosen])
  country <- df[row_chosen, 1]
  
  outstring <- paste(country, '. ', rights_name, ': ', tolower(string), sep = '', '#LGBTQ #equality')
  
  if(nchar(outstring)<=240){
    tweetable <- T
  }else{
    tweetable <- F
  }
  
  if(!is.null(countries[[country]])){ #If we find the country name in the list of countries
    flag <- T
    flagname <- paste('png1000px/',countries[[country]] ,'.png', sep='')
  }
  
  
  #Now to send the tweet. the 'flag' variable assumes that I one day write the code to download the country's flag 
  if(flag==T){
    post_tweet(status = outstring, token = twitter_token,
               in_reply_to_status_id = NULL, media = flagname)
    
  }else{
    
    post_tweet(status = outstring, token = twitter_token,
               in_reply_to_status_id = NULL)
  }
  
  
  flag==F #Reset the flag variable in case we can't find it in the next iteration
  
  print(outstring)
  
  #End, or wait for next iteration
  print(Sys.time())
  
  if(wait_in_r==TRUE){
    Sys.sleep(wait_duration) #The number of seconds to sleep for
  }else{
    A <- TRUE
  }
  
}

