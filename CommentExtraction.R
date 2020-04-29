# library(jsonlite)
# library(tidyverse)
# library(xml2)
# library(foreach)
# library(doParallel)

# cl <- makeCluster(2)
# registerDoParallel(cl)
# 
# tests<-function(){
#   foreach(n=1:100) %dopar% print("Shubham")
# }
# 
# tests()
library(jsonlite)
library(tidyverse)
library(xml2)

#postURLs <- read_csv("postURLs.csv")

#postURLs <- read_csv("./output/combineop/euro2016.csv",col_names = TRUE)
#url_start <- "https://www.instagram.com/p/B3uSLnghafw/?__a=1"

#url_start <- "https://www.instagram.com/p/B3uSLnghafw/?__a=1"
#url_start <- "https://www.instagram.com/p/B52Wfl4Aa5W/?__a=1"
#url_start <- "http://instagram.com/p/B526Ju2h-_e/?__a=1"
#url_start <- "https://www.instagram.com/p/B52z2Q9hJzN/?__a=1"

#postURLs <- c("https://www.instagram.com/p/B3uSLnghafw/?__a=1","https://www.instagram.com/p/B3uSLnghafw/?__a=1","https://www.instagram.com/p/B52Wfl4Aa5W/?__a=1","http://instagram.com/p/B526Ju2h-_e/?__a=1","https://www.instagram.com/p/B52z2Q9hJzN/?__a=1")

#postURLs <- postURL$Post_URL

extractPostCommentData <- function(url,conPost,conComment){
  #s <- toString(postURLs[i,"Post_URL"])
  
  #print(s)
  #print(paste(s,i))
  #Sys.sleep(0.5)
  # con <- mongo(
  #   collection = "post",
  #   db = "admin",
  #   url = "mongodb://localhost",
  #   verbose = FALSE,
  #   options = ssl_options()
  # )
    s <- toString(url)
    url_start <- paste(s,"/?__a=1",sep = "")
    err <- tryCatch(post <<- fromJSON(url_start), error = function(e) NA)
    if(is.na(err)){
      write_csv(data.frame(url_start), "output/failedURLs_1.csv", append = TRUE)
    }else{
      getPostData(conPost,conComment,url)
    } 
  
}

#post <- fromJSON(url_start)

##Not needed for our approach
#has_next_page <<- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["page_info"]][["has_next_page"]]
#end_cursor <<- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["page_info"]][["end_cursor"]]

getPostData <- function(conPost,conComment,url) {
  ####################### POSTDATA - NEED JUST ONCE #######################
  
  #PostData
  post_Id <- post[["graphql"]][["shortcode_media"]][["id"]]
  
  if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_caption"]][["edges"]][["node"]][["text"]]) >=1){
    post_Caption <- gsub("\n", "", post[["graphql"]][["shortcode_media"]][["edge_media_to_caption"]][["edges"]][["node"]][["text"]])  
  } else{
    post_Caption <- "NULL"
  }
  
  #post_Caption <- gsub("\n", "", post[["graphql"]][["shortcode_media"]][["edge_media_to_caption"]][["edges"]][["node"]][["text"]])
  post_Time_Posted <- toString(as.POSIXct(post[["graphql"]][["shortcode_media"]][["taken_at_timestamp"]], origin = "1970-01-01"))
  post_Like_Count <- post[["graphql"]][["shortcode_media"]][["edge_media_preview_like"]][["count"]]
  post_Comment_Count <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["count"]]
  post_is_video <- post[["graphql"]][["shortcode_media"]][["is_video"]]
  
  if(post_is_video==FALSE)
  {
    post_video_view_count <- "NULL"
    post_video_duration <- "NULL"
  }else{
    post_video_view_count <- post[["graphql"]][["shortcode_media"]][["video_view_count"]]
    post_video_duration <- post[["graphql"]][["shortcode_media"]][["video_duration"]]
  }
  
  
  post_is_ad <- post[["graphql"]][["shortcode_media"]][["is_ad"]]
  if (length(post[["graphql"]][["shortcode_media"]][["location"]]) >= 1) {
    post_location <- post[["graphql"]][["shortcode_media"]][["location"]][["name"]]
  } else {
    post_location <- "NULL"
  }
  
  #PostOwnerData
  owner_id <- post[["graphql"]][["shortcode_media"]][["owner"]][["id"]]
  owner_is_verified <- post[["graphql"]][["shortcode_media"]][["owner"]][["is_verified"]]
  owner_profile_pic_url <- post[["graphql"]][["shortcode_media"]][["owner"]][["profile_pic_url"]]
  owner_username <- post[["graphql"]][["shortcode_media"]][["owner"]][["username"]]
  owner_full_name <- post[["graphql"]][["shortcode_media"]][["owner"]][["full_name"]]
  post_url <- url
  
  postDataFrame <- do.call(rbind.data.frame, Map(
    'c',
    post_Id,
    post_Caption,
    post_Time_Posted,
    post_Like_Count,
    post_Comment_Count,
    post_is_video,
    post_video_view_count,
    post_video_duration,
    post_is_ad,
    post_location,
    post_url,
    owner_id,
    owner_is_verified,
    owner_profile_pic_url,
    owner_username,
    owner_full_name
  ))
  
  colnames(postDataFrame) <- c(
    "post_Id",
    "post_Caption",
    "post_Time_Posted",
    "post_Like_Count",
    "post_Comment_Count",
    "post_is_video",
    "post_video_view_count",
    "post_video_duration",
    "post_is_ad",
    "post_location",
    "post_url",
    "owner_id",
    "owner_is_verified",
    "owner_profile_pic_url",
    "owner_username",
    "owner_full_name"
  )
  
  #write_csv(postDataFrame, "output/postExportTest.csv",append = TRUE)
  conPost$insert(postDataFrame)
  
  # conComment <- mongo(
  #   collection = "comment",
  #   db = "admin",
  #   url = "mongodb://localhost",
  #   verbose = FALSE,
  #   options = ssl_options()
  # )
  
  extractComments(conComment,url)
  
}

extractComments <- function(con,url) {
  index = 1
  #print("ExtractComment function exectued")
  
  if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["id"]])>=1){
    for (i in 1:length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["id"]])) {
      ####################### COMMENTDATA #######################
      #PostId for Lookup
      post_Id <- post[["graphql"]][["shortcode_media"]][["id"]]
      
      #CommentData
      comment_id <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["id"]][[i]]
      comment_Text <- gsub("\n", "", post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["text"]][[i]])
      comment_Time_Posted <- toString(as.POSIXct(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["created_at"]][[i]], origin = "1970-01-01"))
      comment_owner_id <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["id"]][[i]]
      comment_owner_is_verfied <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["owner"]][["is_verified"]][[i]]
      comment_owner_profile_pic_url <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["owner"]][["profile_pic_url"]][[i]]
      comment_owner_username <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["owner"]][["username"]][[i]]
      comment_liked_count <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_liked_by"]][["count"]][[i]]
      
      #CommentCommentData
      if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["count"]][[i]]) >= 1) {
        comment_comment_count <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["count"]][[i]]
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["id"]])>=1){
          comment_comment_id <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["id"]]
        }else{
          comment_comment_id <- "NULL"
        }
        
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["text"]])>=1){
          comment_comment_text <- gsub("\n", "", post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["text"]])  
        }else{
          comment_comment_text <- "NULL"  
        }
        
        
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["created_at"]])>=1){
          comment_comment_Time_Posted <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["created_at"]]
        }else{
          comment_comment_Time_Posted <- "NULL"
        }
        
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["id"]])>=1){
          comment_comment_owner_id <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["id"]]
        }else{
          comment_comment_owner_id <- "NULL"
        }
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["is_verfiied"]]) >= 1) {
          comment_comment_owner_is_verified <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["is_verfiied"]]
        } else {
          comment_comment_owner_is_verified <- "NULL"
        }
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["profile_pic_url"]])>=1){
          comment_comment_owner_profile_pic_url <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["profile_pic_url"]]
        }else{
          comment_comment_owner_profile_pic_url <- "NULL"
        }
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["username"]])>=1){
          comment_comment_owner_username <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["owner"]][["username"]]
        }else{
          comment_comment_owner_username <- "NULL"
        }
        
        
        if(length(post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["created_at"]][i])>=1){
          comment_comment_liked_count <- post[["graphql"]][["shortcode_media"]][["edge_media_to_parent_comment"]][["edges"]][["node"]][["edge_threaded_comments"]][["edges"]][[i]][["node"]][["created_at"]][i]
        }else{
          comment_comment_liked_count <- "NULL"
        }
        
      } else {
        comment_comment_count <- "NULL"
        comment_comment_id <- "NULL"
        comment_comment_text <- "NULL"
        comment_comment_Time_Posted <- "NULL"
        comment_comment_owner_id <- "NULL"
        comment_comment_owner_is_verified <- "NULL"
        comment_comment_owner_profile_pic_url <- "NULL"
        comment_comment_owner_username <- "NULL"
        comment_comment_liked_count <- "NULL"
      }
      
      post_url <- url
      
      ####################### SAVING #######################
      commentDataFrame <- do.call(rbind.data.frame, Map(
        'c',
        post_Id,
        comment_id,
        comment_Text,
        comment_Time_Posted,
        comment_owner_id,
        comment_owner_is_verfied,
        comment_owner_profile_pic_url,
        comment_owner_username,
        comment_liked_count,
        comment_comment_count,
        comment_comment_id,
        comment_comment_text,
        comment_comment_Time_Posted,
        comment_comment_owner_id,
        comment_comment_owner_is_verified,
        comment_comment_owner_profile_pic_url,
        comment_comment_owner_username,
        comment_comment_liked_count,
        post_url
      ))
      
      colnames(commentDataFrame) <- c(
        "post_Id",
        "comment_id",
        "comment_Text",
        "comment_Time_Posted",
        "comment_owner_id",
        "comment_owner_is_verfied",
        "comment_owner_profile_pic_url",
        "comment_owner_username",
        "comment_liked_count",
        "comment_comment_count",
        "comment_comment_id",
        "comment_comment_text",
        "comment_comment_Time_Posted",
        "comment_comment_owner_id",
        "comment_comment_owner_is_verified",
        "comment_comment_owner_profile_pic_url",
        "comment_comment_owner_username",
        "comment_comment_liked_count",
        "post_url"
      )
      
      #write_csv(commentDataFrame, "output/commentExportTest.csv", append = TRUE)
      con$insert(commentDataFrame)
      index = index + 1
    } ##End of for getting comments
  }  # else{
  #   #print("Zero Comments")
  #   #print("")
  # }
}
