#Assuming that the table was nicely formatted, which it isn't

library(rtweet)
library(here)

setwd(here())

wait_in_r <- T
wait_duration <- 211*60 #Number of seconds to wait if wait_in_r == true
df <- read.csv('unformatted_rights.csv', stringsAsFactors = F)



##twitter token should be generated with the instructions here(http://rtweet.info/articles/auth.html), but I found it easier to just load the token rather than making it an environment variable
twitter_token <- readRDS() #insert token location here


A <- FALSE
while(A==FALSE){
  
  
  #Chose the values to tweet
  column_chosen <- sample(ncol(df), 1)
  row_chosen <- sample(nrow(df), 1)
  
  
  string <- df[row_chosen, column_chosen]
  rights_name <- gsub('\\.', ' ', colnames(df)[column_chosen])
  country <- df[row_chosen, 1]
  
  outstring <- paste(country, '. ', rights_name, ': ', string, sep = '', '#lgbtpride')
  
  #Now to send the tweet. the 'photo' variable assumes that I one day write the code to download the country's flag 
  if(photo==T){
    post_tweet(status = outstring, token = twitter_token,
               in_reply_to_status_id = NULL, media = './temp.jpg')
    file.remove('temp.jpg')
  }else{
    post_tweet(status = outstring, token = twitter_token,
               in_reply_to_status_id = NULL)
  }
  
  
  
  
  #End, or wait for next iteration
  print(Sys.time())
  
  if(wait_in_r==TRUE){
    Sys.sleep(wait_duration) #The number of seconds to sleep for
  }else{
    A <- TRUE
  }
  
}

