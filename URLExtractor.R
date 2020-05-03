#Functions
# con <- mongo(
#   collection = "test",
#   db = "admin",
#   url = "mongodb://localhost",
#   verbose = FALSE,
#   options = ssl_options()
# )
######

extractInfo <- function(index,conTest,conPost,conComment) {

  print(paste("extractInfo function called for hashtag", hashtag))
  maxrows <- nrow(posts)
  #print(paste("MaxRow on Page:",maxrows))
  
  for(i in 1:maxrows) {
    if(i == maxrows) { #If last post on page
      
      if(length(end_cursor > 0)) {
        getNewPosts(index)
        
      } else {
        hashtagCounter <<- hashtagCounter + 1
        hashtag <<- hashtagsData[hashtagCounter,1]
        index <- 1
        print(paste("All posts from", hashtagsData[hashtagCounter - 1,1], "scanned, start scanning hashtag", hashtag))
        
        if(hashtagCounter <= nrow(hashtagsData)) {
          print("Inside this If")
          url_start <<- paste("http://instagram.com/explore/tags/", hashtag, "/?__a=1", sep = "")
          json <<- fromJSON(url_start)
          edge_hashtag_to_media <<- json$graphql$hashtag$edge_hashtag_to_media
          end_cursor <<- edge_hashtag_to_media$page_info$end_cursor
          posts <<- edge_hashtag_to_media$edges$node
          totalPostCount <<- json[["graphql"]][["hashtag"]][["edge_hashtag_to_media"]][["count"]]
          
          print(paste("Hashtag:", hashtag))
          print(paste("TotalPosts:", totalPostCount))
          extractInfo(index,conTest,conPost,conComment)
          
        } else {
          print("all hashtags scanned")
          on.exit()
          
        }
      }
    } else { #All other posts on page
      if(length(posts$edge_media_to_caption$edges[[i]][["node"]][["text"]]) == 0){ #If length of post_text is 0
        post_text <- "no-text"
        print("no text in post")
        
      } else {
        temp <- posts$edge_media_to_caption$edges[[i]][["node"]][["text"]] #If length of post_text is >= 1
        #post_text[index] <- gsub("\n", " ", temp)
        post_text <- gsub("\n", " ", temp)
        
      }
      
      postDataFrame <- data.frame(matrix(ncol = 7, nrow = 0),stringsAsFactors = FALSE)
      
      post_comments_disabled <- posts[i,1]
      post_id_temp <- posts[i,5]
      post_url <-  str_glue("http://instagram.com/p/{post_id_temp}")
      post_id <- post_id_temp
      post_comment_count <- posts[i,6]
      post_time <- toString(as.POSIXct(posts[i,7], origin = "1970-01-01"))
      post_dimensions_height <- posts[i,8]$height
      post_dimensions_width <- posts[i,8]$width
      post_img_url <- posts[i,9]
      post_likes <- posts[i,11]
      post_owner <- posts[i,12]
      post_is_Video <- posts[i,15]
      post_accessibility_caption <- posts[i,16]
      post_video_view_count <- posts[i,17]
      
      postDataFrame <- do.call(rbind.data.frame, Map('c',
                                                     post_id,
                                                     post_time,
                                                     post_likes,
                                                     post_comment_count,
                                                     post_owner,
                                                     post_is_Video,
                                                     post_video_view_count,
                                                     post_url,
                                                     post_img_url,
                                                     post_text,
                                                     post_accessibility_caption,
                                                     post_dimensions_height,
                                                     post_dimensions_width,
                                                     post_comments_disabled))
      
      #Add to CSV
      if (index == 1) {
        colnames(postDataFrame) <- c("ID", 
                                     "Date", 
                                     "Likes",
                                     "Comment_Count",
                                     "Owner", 
                                     "isVideo", 
                                     "video_view_count", 
                                     "Post_URL", 
                                     "Img_URL", 
                                     "Title", 
                                     "Accessibility_Text",
                                     "Post_Dimenisons_Height",
                                     "Post_Dimenisons_Width",
                                     "Post_Comments_Disabled")
        
        #write_csv(postDataFrame, paste(saveDirectory, hashtag, ".csv", sep = ""))
        
        # l <- postDataFrame$Post_URL[1]
        # print(paste("URL IS: ",postDataFrame$Post_URL[1]))
        # print(typeof(str(postDataFrame$Post_URL)))
        url <- postDataFrame$Post_URL
        #print(url)
        quer = paste('{"post_url":"',url,'"}',sep = "")
        countPost <- conTest$count(query = quer)
        if(countPost > 0){
          print("Post Data Already Exisits")
        }else{
          # if(alternativeCode == 1){
          #   conTest$insert(postDataFrame)
          #   #Sys.sleep(0.15)
          # }else{
            extractPostCommentData(url,conPost,conComment)
            conTest$insert(postDataFrame)
            #Sys.sleep(0.15)            
          # }
          

        }
        
      } else {       
        colnames(postDataFrame) <- c("ID", 
                                     "Date", 
                                     "Likes",
                                     "Comment_Count",
                                     "Owner", 
                                     "isVideo", 
                                     "video_view_count", 
                                     "Post_URL", 
                                     "Img_URL", 
                                     "Title", 
                                     "Accessibility_Text",
                                     "Post_Dimenisons_Height",
                                     "Post_Dimenisons_Width",
                                     "Post_Comments_Disabled")
        #write_csv(postDataFrame, paste(saveDirectory, hashtag, ".csv", sep = ""), append = TRUE)
        
        # print(paste("URL IS: ",str(postDataFrame$Post_URL[1])))
        # print(typeof(str(postDataFrame$Post_URL)))
        #as <<- postDataFrame$Post_URL
        url <- postDataFrame$Post_URL
        #print(url)
        
        quer = paste('{"post_url":"',url,'"}',sep = "")
        countPost <- conTest$count(query = quer)
        if(countPost > 0){
          print("Post Data Already Exisits")
          print("Post Data Already Exisits")
          print("Post Data Already Exisits")
          print("Post Data Already Exisits")
          print("Post Data Already Exisits")
        }else{
          # if(alternativeCode == 1){
          #   conTest$insert(postDataFrame)
          #   Sys.sleep(0.15)
          # }else{
            extractPostCommentData(url,conPost,conComment)
            conTest$insert(postDataFrame)
          #   Sys.sleep(0.15)            
          # }
        }
        
      }
      
      #optional: download image
      #img_dir <- str_glue("images/{index}_{hashtag}_post_img.jpg")
      #download.file(posts[i,8], img_dir, mode = 'wb')
      index <- index + 1
      
    } # End else
  } # End for info extracter
} # End function

#Get New Posts from Instagram
getNewPosts <- function(index){
  print(paste("getNewPosts function called for hashtag", hashtag))
  
  url_next <- str_glue("{url_start}&max_id={end_cursor}")
  json <- fromJSON(url_next)
  
  edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
  end_cursor <<- edge_hashtag_to_media$page_info$end_cursor
  
  
  timestamps <- Sys.time()
  
  end_cursor.df <- data.frame('EC',timestamps,end_cursor)
  colnames(end_cursor.df) <- c("Type", 
                               "Date", 
                               "End_Cursor")
  conTest$insert(end_cursor.df)
  print(paste("Current Cursor:",end_cursor))
  
  
  
  
  
  #Just in case that something went horrible wrong and my end_cursor is lost. For resume scanning
  end_cursor_for_resume_scan <<- as.data.frame(edge_hashtag_to_media$page_info$end_cursor)
  #to save the cursor in end cursors
  #write_csv(end_cursor_for_resume_scan, paste(saveDirectory, "EndCursors", ".csv", sep = ""), append = TRUE)
  
  posts <- edge_hashtag_to_media$edges$node
  
  assign("end_cursor", end_cursor, envir = .GlobalEnv)
  assign("posts", posts, envir = .GlobalEnv)
  
  print(paste(index, "posts crawled"))
  print(paste(totalPostCount - index, "posts left"))
  Sys.sleep(sysSleepTimer)
  # if(index > 10000)
  # {
  #   end.time <- Sys.time()
  #   time.taken <- end.time - start.time
  #   print(paste("RunTime: ",index,"Records Loaded in",time.taken,"Seconds"))
  #   createNewDatasetFromExistingCrawler()
  # }
  # else{
    extractInfo(index,conTest,conPost,conComment)
  # }
}

createNewDatasetFromExistingCrawler <- function(){
  rm(list = ls())
  hashtagCounter <- 1
  sysSleepTimer <- 5
  index <- 1
  
  recentFolder = tail(list.files("./output/instagram/"),n=1)
  #Create directory for saving
  cursorFilePath = paste("./output/instagram/",recentFolder,"/EndCursors.csv",sep="")
  
  cursorData <- tail(read_csv(file = cursorFilePath,col_names = FALSE),1)
  l <- cursorData[1]
  end_cursor <- paste( unlist(l), collapse='')
  print(paste("New Cursor:",end_cursor))
  
  createDirectory()
  
  #Load and set first hashtag
  hashtagsData <- read_csv("input/hashtags.txt")
  hashtag <<- hashtagsData[hashtagCounter,1]
  hashtag <<- "euro2016"
  #Get first posts
  url_start <- paste("http://instagram.com/explore/tags/", hashtag, "/?__a=1", sep = "")
  json <- fromJSON(url_start)
  edge_hashtag_to_media <- json$graphql$hashtag$edge_hashtag_to_media
  #end_cursor <- edge_hashtag_to_media$page_info$end_cursor
  posts <- edge_hashtag_to_media$edges$node
  totalPostCount <- json[["graphql"]][["hashtag"]][["edge_hashtag_to_media"]][["count"]]
  
  #Start crawling
  print(paste("Hashtag:", hashtag))
  print(paste("TotalPosts:", totalPostCount))
  extractInfo(index,conTest,conPost,conComment)
}

createDirectory <- function() {
  time <- Sys.time()
  time <- gsub(":", "_", time)
  time <- gsub(" ", "_", time)
  
  dir.create("output")
  dir.create("instagram")
  
  saveDirectory <<- paste("output/instagram_new/", time, "/", sep = "")
  
  print(paste("Start Time:",Sys.time()))
  
  
  if(!dir.exists(saveDirectory)) {
    dir.create(saveDirectory)
  } else {
    print("Directory already exists")
  }
}