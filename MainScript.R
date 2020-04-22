#Libraries and Functions
setwd("E:/National Identity")
source("./scripts/packages.R")
#source("scripts/InstaScrapperMongo/UR")

#Set (initial) parameters
hashtagCounter <- 1
sysSleepTimer <- 5
index <- 1
start.time <- Sys.time()
#Create directory for saving
#createDirectory()

#Load and set first hashtag
hashtagsData <- read_csv("input/hashtags.txt")
hashtag <<- hashtagsData[hashtagCounter,1]
hashtag <<- "euro2016"
#Get first posts
url_start <- paste("http://instagram.com/explore/tags/", hashtag, "/?__a=1", sep = "")
json <- fromJSON(url_start)
edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
posts <- edge_hashtag_to_media$edges$node
totalPostCount <- json[["graphql"]][["hashtag"]][["edge_hashtag_to_media"]][["count"]]

#Start crawling
print(paste("Hashtag:", hashtag))
print(paste("TotalPosts:", totalPostCount))

#1db.test.find({"Type":"EC"}).sort({'_id':-1}).limit(1)


latest_end_cursor <- function(){
  con <- mongo(
    collection = "test",
    db = "admin",
    url = "mongodb://localhost",
    verbose = FALSE,
    options = ssl_options()
  )
  
  end_cursor_lastest <- con$find(query = '{"Type":"EC"}',sort = '{"_id":-1}',limit = 1)
  if(nrow(end_cursor_lastest) > 0){
    end_cursor <- end_cursor_lastest$End_Cursor
  }
  else{
    end_cursor <- edge_hashtag_to_media$page_info$end_cursor
  }
  tryCatch(extractInfo(index), error = function(err){ latest_end_cursor()} )
}



latest_end_cursor()

#For testing
#end_cursor = "QVFBdDRBSWJMRG1sT2NQYjVRd3Z1TWo5YVpWWG5oSEd0aWx6V2R4eUpBS2owUUMwY0NFempPdFVoeEE5dkJZdnZabzFhX1Jra3FsdDhVeXE0dUtabnV2RA=="
#QVFEMnZLX19HNzltOG56aHRKWGl4MnNRUDRvSXRCc1FLek9vU200NWN2Nk14U042V3lkVmxtZXR1ZEdlSXU4bWZpdHptVmJLRlU0NzY0VTF5SmlhV1NfQw==










