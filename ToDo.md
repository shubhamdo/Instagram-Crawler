22/4/2020 


# 1
Fail proof
If try except fails


1. ~Check for the lastest cursor from mongodb test~ 
2. ~set the end_cursor as lastest~
3. ~start extracting again~
4. put a wait of 10 min

# 2 
Remove Duplicates
While inserting the documents in, sas
1. ~test for urls --> if same url exists do not add~
2. ~test for cursor~
3. ~post --> if postid exists do not add new~
4. check if can be split into sub comments

# 3
Remove the existing fail safe created in the code

# 4
* ~Create all the connection objects for the mongodb database in the mainscript, pass it to other code through functions~
* Remove unnecessary code from the script
* Try to make different functions and reduce clutter of the code
* Make it in a sequence, that the code could be easily followed
* Create an alternative code that runs, the extract links first then it extracts all the posts and the comments from the urls extracted.

# 5 
Create a desktop application to
1. Add Hashtag
2. View Data from all the Collections
3. Show the progress, how many posts have been completed

===========================================================================

# Instagram Crawler

We have created an Instagram Crawler which can crawl, posts with some of it comments. It stores the data to MonogDB Database. Very easy to use.

Simple Steps to Setup:
1. Install MonogDB
2. Create 3 collections in 1 Database
3. Add the db & collections names in the code as shown in screenshot below



