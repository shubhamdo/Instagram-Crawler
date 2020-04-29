#Libraries
if(!require(tidyverse)){
  install.packages("tidyverse")
  library(tidyverse)
}

if(!require(jsonlite)){
  install.packages("jsonlite")
  library(jsonlite)
}

if(!require("jpeg")){
  install.packages("jpeg")
  library("jpeg")
}

if(!require(utf8)){
  install.packages("utf8")
  library(utf8)
}

if(!require(RedditExtractoR)){
  install.packages("RedditExtractoR")
  library(RedditExtractoR)
}

if(!require(RSelenium)){
  install.packages("RSelenium")
  library(RSelenium)
}

if(!require(xml2)){
  install.packages("xml2")
  library(xml2)
}

if(!require(rvest)){
  install.packages("rvest")
  library(rvest)
}

if(!require(lubridate)){
  install.packages("lubridate")
  library(lubridate)
}

if(!require(tidytext)){
  install.packages("tidytext")
  library(tidytext)
}

if(!require(mongolite)){
  install.packages("mongolite")
  library(mongolite)
}

if(!require(cld3)){
  install.packages("cld3")
  library(cld3)
}

if(!require(reticulate)){
  install.packages("reticulate")
  library(reticulate)
}

if(!require(rredis)){
  install.packages("rredis")
  library(rredis)
}

if(!require(data.table)){
  install.packages("data.table")
  library(data.table)
}

# Set path to python executable




if (dir.exists("output")) {
  print('Directory "output" already exists.')
} else {
  dir.create("output")
  print('Directory "output" created.')
}

if (dir.exists("output/temp")) {
  print('Directory "temp" already exists.')
} else {
  dir.create("output/temp")
  print('Directory "temp" created.')
}

options(scipen = 1000)