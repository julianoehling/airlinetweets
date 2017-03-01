library(shiny)
library(tm)
library(wordcloud2)
library(memoise)
#library(data.table)

load("tweets.Rdata")
airlines <- unique(tweets$airline)

shinyServer(function(input, output) {
  
  output$airlineUI <- renderUI({
    selectInput("selection", "Pick an Airline:",
                choices = airlines, selected = "United")
  })
  
  getTermMatrix <- memoise(function(airline, frequency) {
    if (!(airline %in% airlines))
      stop("Unknown airline")
    
    text <- tweets$text[tweets$airline == airline]
    
    tweet.corp <- Corpus(VectorSource(text))
    tweet.corp <- tm_map(tweet.corp, content_transformer(tolower))
    tweet.corp <- tm_map(tweet.corp, removePunctuation)
    tweet.corp <- tm_map(tweet.corp, removeNumbers)
    tweet.corp <- tm_map(tweet.corp, removeWords,
                         c(stopwords("SMART")))
    
    tweets.dtm <-TermDocumentMatrix(tweet.corp)
    tweets.freq <- rowSums(as.matrix(tweets.dtm))
    tweets.freq <- subset(tweets.freq, tweets.freq >= frequency)
    tweets.df <- data.frame(word = names(tweets.freq), freq = tweets.freq)
    
  })
  
  getSatisfaction <- function(airline) {
    sent <- tweets$airline_sentiment[tweets$airline == airline]
    sent <- as.factor(sent)
    res <- summary(sent)
  }
  
  terms <- reactive({
    input$update
    if(input$update != 0) {
      isolate({
        withProgress({
          setProgress(message = "Processing...")
          getTermMatrix(input$selection, input$freq)
        })
      }) }
  })
  
  
  output$tweetcloud <- renderWordcloud2({
    if(input$update != 0) {
      wordcloud2(terms(), size=input$size)}
  })
  
  output$satisfaction <- renderPlot({
    input$update
    if(input$update != 0) {
      data <- isolate(getSatisfaction(input$selection))
      pie(x = data ,labels = names(data), col =  c("red3", "grey", "springgreen3"), 
          main = paste(round(100* data[3] / sum(data[1:3]), digits = 1), "% positive tweets", sep=""))}
  })
}
)

