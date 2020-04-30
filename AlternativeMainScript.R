#Libraries and Functions
setwd("E:/Instagram-Crawler")
source("packages.R")
source("CommentExtraction.R")
source("URLExtractor.R")

#Set (initial) parameters
hashtagCounter <- 1
sysSleepTimer <- 5
index <- 1
conComment <- ""
conPost <- "" 
conTest <- ""
#########################################################################################
############  MENTION THE DATABASE AND THE COLLECTIONS CREATED FOR STORAGE  #############
#########################################################################################

db_name <- "admin"
cursor_url_collection <- "test"
post_collection <-  "post"
comment_collection <- "comment"


databaseConnections <- function(){
  conComment <<- mongo(
    collection = comment_collection,
    db = db_name,
    url = "mongodb://localhost",
    verbose = FALSE,
    options = ssl_options()
  )
  
  conPost <<- mongo(
    collection = post_collection,
    db = db_name,
    url = "mongodb://localhost",
    verbose = FALSE,
    options = ssl_options()
  )
  
  conTest <<- mongo(
    collection = cursor_url_collection,
    db = db_name,
    url = "mongodb://localhost",
    verbose = FALSE,
    options = ssl_options()
  )
  
}
databaseConnections()
cursorDocuments <- conTest$find(query = "{}")
postDocuments <- as.vector(conComment$find(query = "{}", fields = '{"post_url": 1, "_id":0}'))
postDocumentsCount <- unique(postDocuments)



# Check for duplications in the mongo db collections 
testDocuments <- conTest$find(query = "{}")
testDocumentsCount <- unique(testDocuments)

postDocuments <- conPost$find(query = "{}", fields = '{"post_url": 1, "_id":0}')
postDocumentsCount <- unique(postDocuments)

commentDocuments <- conComment$find(query = "{}")
commentDocumentsCount <- unique(commentDocuments)



postCount <- conTest$find(query = "{}")

postCount1 <- unique(postCount$Post_URL) 

postDocuments <- conPost$distinct(key = "post_Id",query = "{}")
r <- postDocuments$post_Id

for(row in 1:nrow(cursorDocuments)){
  url = cursorDocuments[row,]$Post_URL
  print(row)
  quer = paste('{"post_url":"',url,'"}',sep = "")
  countPost <- conPost$count(query = quer)

   if(countPost < 1){
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
     print("NEW URLLLLLLLLLLLLLLLLLLLL")
   }else{
     print("Already Present")
   }
}

# 
# quer = paste('{"post_url":"',url,'"}',sep = "")
# countPost <- conPost$count(query = quer)







postDocuments <- conTest$distinct(key = "Post_URL",query = "{}")

url <- "http://instagram.com/p/B_Qd6rWJwfU"
{"post_url":"http://instagram.com/p/B_Qd6rWJwfU"}


quer = paste('{"post_url":"',url,'"}',sep = "")
countPost <- conPost$count(query = quer)
countPost <- conTest$count(query = quer)
countPost <- conTest$run(command = 'count({"post_url":"http://instagram.com/p/B_Qd6rWJwfU"})')
if(countPost > 0){
  print("Post Data Already Exisits")
}else{
  if(alternativeCode == 1){
    conTest$insert(postDataFrame)
    Sys.sleep(0.15)
  }else{
    extractPostCommentData(url,conPost,conComment)
    conTest$insert(postDataFrame)
    Sys.sleep(0.15)            
  }
}