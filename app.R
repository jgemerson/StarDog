# Jojo Emerson
# March 27, 2019
# Star Dog scatter plot maker
# Purpose: create star/dog graphs for restaurant menu analytics
# Version: 1.4.0
# Changes:
# - improve ggplot download
# - add credit

library(shiny)
library(readxl)
library(ggplot2)
library(ggrepel)
library(writexl)
library(plotly)
library(tidyverse)
library(shinyjs)
library(dplyr)

#Breaks function:
  #creates vector that begins at minimum axis value, increments every break #, and stops at max value
breaks <- function(min, max, breaks_every){
  #define start of vector
  break_vector<-c(min)
  #define counter, starting at min+break
  counter<-min+breaks_every
  while(counter<=max){
    break_vector<-c(break_vector, counter)
    counter<-counter+breaks_every
  }
  return(break_vector)
}

#UI#
ui <- fluidPage(
  
   #Enable shinyjs
    useShinyjs(),
  
   # Title
   titlePanel("Star/Dog Graph Creator"),
   
   # Sidebar with a template download, data upload, and create graph button 
   sidebarLayout(
      sidebarPanel(
        
        tags$h4("Download Excel Template:"),
         downloadButton(outputId = "template_download", label = "Download template"),
        
         tags$br(),tags$br(),tags$br(),
        
        tags$h4("Upload Data:"),
        "File must be .xlsx (Excel) format",
         fileInput("data_upload", label = NULL, multiple = FALSE,
                   accept = c(".xlsx")), 
        
        tags$h4("Create Star/Dog Graph:"),
         actionButton("create", label = "Create!"),
        
        tags$br(), tags$br(),
        
      tags$h4("Download current graph:"),
      downloadButton(outputId = "download_plot", label = "Download plot!")
      ),
      
      mainPanel(
        # Scatterplot of Star/Dog analysis
        fluidRow(
         plotOutput("stardog"),
         shinyjs::hidden(plotOutput("stardog_update")),
         
         tags$br(),tags$br(),tags$br()
        ),
        
        # Options
        fluidRow(
          #Graph options
          column(width = 4,
                 uiOutput("graph_options")
          ),
          
          #Y axis options
          column(width = 4,
                 uiOutput("y_options")
          ),
          
          #X axis options
          column(width = 4,
            uiOutput("x_options")
          )
        ),
        
        fluidRow(align = "center",
          #update graph
          uiOutput("update"),
          
          tags$br(),tags$br(),tags$br()
        )
      )
   ),
   fluidRow(
     #footer
     tags$footer(hr(),"Developer: ", tags$a(href="mailto:jgemerson93@gmail.com", "Joanna Emerson"),
                 align = "left", style = "
                  bottom:0;
                  width:100%;
                  padding: 20px;
        "
     )
   )
)

#SEVER#
server <- function(input, output, session) {
   
  ## Downloadable template ##
    #Upload template
    template<-read_xlsx("data/StarDogTemplate.xlsx")
  
    #Download template on click
    output$template_download <- downloadHandler(
      filename = function() {
        paste("StarDogTemplate",".xlsx", sep="")
      },
      content = function(file) {
        write_xlsx(template, file)
      }
    )
    
  ## Data ##
    
    dfs<-reactiveValues(data = NULL, update = NULL)
    
    observeEvent(input$data_upload, {
      inFile <- input$data_upload
      dfs$data<-read_xlsx(inFile$datapath)
    })
    
  ## Scatterplot ##
    observeEvent(input$create, {  
      
      req(input$data_upload)
      
      #Create Star/Dog scatterplot on clickd
          #X axis: Sales
          #Y axis: Contribution
          #Points labeled with item name
          #Quadrant lines are the median value for Sales/Contribution
      
        final_plot<-reactive({
          ggplot(dfs$data, aes(x=Sales, y=Contribution)) + geom_point(color = "orangered3") +

          #Horizontal line at the median Contribution point
          geom_hline(yintercept=median(dfs$data$Contribution), color = "blue", alpha = .7) +

          #Bertical line at the median Sales point
          geom_vline(xintercept=median(dfs$data$Sales), color = "blue", alpha = .7) +

          #Scale of the y axis (Contribution)
            #Defaults: ggplot to fit break points max/min of data are max/min of plot
          scale_y_continuous(breaks=waiver(),limits= NULL) +

          #Scale of the y axis (Sales)
            #Defaults: ggplot to fit break points max/min of data are max/min of plot
          scale_x_continuous(breaks=waiver(), limits = NULL) +

          #Add repel labels of the items to the points on the graph
          geom_text_repel(label=dfs$data$Item, size = 4) +

          #Title
            #Default: nothing
          ggtitle("")
          
          #theme done in render plot for download size regulation
      })
        
        output$stardog <- renderPlot(final_plot()+theme_minimal(base_size = 17))
        download_plot<<-final_plot()+theme_minimal(base_size = 14)
      
      #Store min and max values
      ymin<-min(dfs$data$Contribution)
      ymax<-max(dfs$data$Contribution)
      xmin<-min(dfs$data$Sales)
      xmax<-max(dfs$data$Sales)
      
      #Render options buttons below plot
        #Y axis options
        output$y_options<-renderUI({
          tagList(
            #Minimum: 25% lower than actual minimum
            numericInput("ymin", label = "Minimum Contribution value:", value = round((ymin-.25*ymin),0)),
            #Maximum: 25% higher than actual maximum
            numericInput("ymax", label = "Maximum Contribution value:", value = round(ymax+.25*ymax,0)),
            #Breaks
            numericInput("ybreaks", label = "Contribution ticks every:", value = 1)
          )
        })
      
        #X axis buttons
        output$x_options<-renderUI({
          tagList(
            #Minimum: 25% lower than actual minimum
            numericInput("xmin", label = "Minimum Sales value:", value = round(xmin-.25*xmin,0)),
            #Maximum: 25% higher than actual maximum
            numericInput("xmax", label = "Maximum Sales value:", value = round(xmax+.25*xmax,0)),
            #Breaks
            numericInput("xbreaks", label = "Sales ticks every: ", value = 500)
          )
        })
      
        #Overall graph options
        output$graph_options<-renderUI({
          tagList(
            #Title
            textInput("title", label = "Graph title:"),
            #Graph by item category
            selectInput("by_cat", label = "Graph by item category:", 
                        choices = ifelse(is.na(dfs$data$Category), c("All categories"), c("All categories", unique(dfs$data$Category))),
                        selected = TRUE))
        })
      
        #Update button
        output$update<-renderUI({
          #Title
          actionButton("update_graph", label = "Update graph!")
        })
        
      })
    
    #update dataaset per category selection
    observeEvent(input$by_cat, {
      dfs$update<-filter(dfs$data, Category == input$by_cat)
    })
    
    #observe the update click
    observeEvent(input$update_graph,{
      req(input$by_cat)
      ifelse(input$by_cat == "All categories",
             dfs$update<-dfs$data,
             dfs$update<-filter(dfs$data, Category == input$by_cat)
      )
      
      #hide original
      shinyjs::hide("stardog")
      #show update
      shinyjs::show("stardog_update")
  
        #Update scatterplot on update click
        updated_plot<-reactive({
          ggplot(dfs$update, aes(x=Sales, y=Contribution)) + geom_point(color = "orangered3") +
            
            #Horizontal line at the median Contribution point
            geom_hline(yintercept=median(dfs$update$Contribution), color = "blue", alpha = .7) +
            
            #Bertical line at the median Sales point
            geom_vline(xintercept=median(dfs$update$Sales), color = "blue", alpha = .7) +
            
            #Scale of the y axis (Contribution)
            #Defaults: ggplot to fit break points max/min of data are max/min of plot
            scale_y_continuous(breaks=breaks(input$ymin, input$ymax, input$ybreaks),
                               limits= c(input$ymin, input$ymax)) +
            
            #Scale of the y axis (Sales)
            #Defaults: ggplot to fit break points max/min of data are max/min of plot
            scale_x_continuous(breaks=breaks(input$xmin, input$xmax, input$xbreaks), 
                               limits = c(input$xmin, input$xmax)) +
            
            #Add repel labels of the items to the points on the graph
            geom_text_repel(label=dfs$update$Item, size = 4) +
            
            #Title
            #Default: nothing
            ggtitle(input$title)
            
          #theme done in render plot for download size regulation
        })
        
        #Render updated plot
        output$stardog_update<-renderPlot(updated_plot()+theme_minimal(base_size = 17))
        download_plot<<-updated_plot()+theme_minimal(base_size = 14)
      })
    
    #Download plot on click
    output$download_plot <-downloadHandler(
        filename = function() {
          paste("Stardog-",input$title, ".png", sep="")
        },
        content = function(file) {
          ggsave(file, plot=download_plot, device = 'png', width = 8, height = 6, units = "in", dpi = 72)
        }
      )
}

# Run the application 
shinyApp(ui = ui, server = server)




