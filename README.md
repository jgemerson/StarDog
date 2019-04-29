# StarDog

## Background
This basic R Shiny App serves as an analytic tool and data visualization creator for restaurant owners and managers. It determines the success and value of a dish on their menu according to the item's contribution (selling price minus food cost) and sales. 

## Usage
Users download an Excel spreadsheet template and upload their sales and contribution data per the template format. The graph creator then makes a scatter plot from all uploaded data, with quadrants defined by the median contribution and sales values of dishes. Dishes located in the top right quadrant indicates "Star" dishes that have high contribution and high sales, while the bottom left quadrant shows "Dog" dishes with low sales and low contribution. Graph axes, title, and . Dishes can also be categorized (example: by menu section) and graphed accordingly. Graphs can be downloaded as .png files using the download button in the left side panel. 

![](https://github.com/jgemerson/StarDog/blob/master/Stardog-Healthy%20Cafe_%20Breakfast%20Menu.png)

## Links and Access
### [Star/Dog Graph Creator](https://jgemerson.shinyapps.io/StarDog/)

## Code structure
Built with [R Shiny](https://shiny.rstudio.com/) via [R Studio IDE](https://www.rstudio.com/).

Packages used:
 - [ggplot2](https://ggplot2.tidyverse.org/)
 - [ggrepel](https://github.com/slowkow/ggrepel)
 - [readxl](https://readxl.tidyverse.org/)
 - [writexl](https://github.com/ropensci/writexl)
 - [plotly](https://plot.ly/r/)
 - [shinyjs](https://deanattali.com/shinyjs/)
 - [dyplr](https://www.rdocumentation.org/packages/dplyr/versions/0.7.8)

## Version
Current verion: 1.0.4. 
The app is partially completed, and has not undergone testing.
Last updated March 27, 2019.

## Screenshots
![](https://github.com/jgemerson/StarDog/blob/master/Screenshots/Overview.png)
_________________
![](https://github.com/jgemerson/StarDog/blob/master/Screenshots/Options.png)
_________________
![](https://github.com/jgemerson/StarDog/blob/master/Screenshots/Customized.png)
_________________

 
## Authors and Acknowledgement
Developed by Joanna Emerson, with the support from Dylan Gully.
