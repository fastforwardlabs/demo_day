# R script that launches a Shiny app to facilitate
# exploration of the largest pharmacies represented
# in the ARCOS data

# This step enabled me to manually identify the 100
# largest non-community pharmacies and flag them
# for exclusion from county-level analyses

# Ian Cook
# 2019-07-25

library(implyr)
library(dplyr)
library(shiny)
library(DT)

impala <- src_impala(odbc::odbc(), dsn = "Impala DSN")

arcos_dirty <-
  tbl(impala, in_schema("arcos","arcos"))
buyers_to_exclude <- 
  tbl(impala, in_schema("arcos","buyers_to_exclude"))

summary_table <- arcos_dirty %>%
  group_by(buyer_dea_no) %>%
  summarise(
    buyer_name = max(buyer_name, na.rm = T),
    buyer_city = max(buyer_city, na.rm = T),
    buyer_state = max(buyer_state, na.rm = T),
    num_pills = round(sum(dosage_unit, na.rm = T))
  ) %>%
  arrange(desc(num_pills)) %>%
  head(300) %>%
  collect()

ui <- fluidPage(
  title = "Buyer Drilldown",
  dataTableOutput("summary"),
  dataTableOutput("drilldown")
)

server <- function(input, output){
  output$summary <- renderDataTable(
    summary_table,
    selection = "single"
  )

  # subset the records to the row that was clicked
  drilldata <- reactive({
    shiny::validate(
      need(
        length(input$summary_rows_selected) > 0,
        "Select a row to drill down"
      )
    )
    selected_pharmacy <- 
      summary_table[as.integer(input$summary_rows_selected), ]$buyer_dea_no
    arcos_dirty %>% 
      filter(buyer_dea_no == !!selected_pharmacy) %>%
      select(starts_with("buyer_")) %>%
      head(1) %>%
      collect()
  })

  # display the subsetted data
  output$drilldown <- renderDataTable(drilldata())
}

shinyApp(
  ui,
  server,
  options = list(
    port=as.numeric(Sys.getenv("CDSW_PUBLIC_PORT")),
    host=Sys.getenv("CDSW_IP_ADDRESS"),
    launch.browser="FALSE"
  )
)

dbDisconnect(impala)
