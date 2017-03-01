library(wordcloud2)
library(shiny)

shinyUI(fluidPage(
  # Application title
  titlePanel("Airline Tweets"),
  
  sidebarLayout(
    sidebarPanel(
      uiOutput("airlineUI") ,
      sliderInput("freq",
                  "Minimum Frequency:",
                  min = 1,  max = 15, value = 2),
      actionButton("update", "Set"),
      hr(),
      sliderInput('size', 'Size of Cloud', min = 1, max = 10, value = 5),
      h2("Click the Set Button to start!"),
      p("This app produces a word cloud and a satisfaction statistic based on February 2015 tweets. Select the airline and the minimum word frequency above and click set. The output will be rendered and might take a minute. Thereafter, adjust the word cloud size as needed. The satisfaction statistic is calculated based on the tweet classification of all tweets of the selected airline. It is independent on minimum frequency and cloud size. The dataset comes from kaggle and can be found at https://www.kaggle.com/crowdflower/twitter-airline-sentiment.")
    ),
    
    # Show Word Cloud
    mainPanel(
      wordcloud2Output("tweetcloud"),
      hr(),
      plotOutput("satisfaction")
    )
  )
)
)


