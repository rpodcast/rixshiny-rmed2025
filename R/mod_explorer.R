#' explorer UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
#' @import reactable
#' @import bslib
#' @import bsicons
mod_explorer_ui <- function(id) {
  ns <- NS(id)
  tagList(
    card(
      full_screen = TRUE,
      id = ns("table_card"),
      card_header(
        "Data Table",
        tooltip(
          bs_icon("info-circle"),
          "Use the bottom scrollbar to view additional columns",
          placement = "right"
        ),
        popover(
          bs_icon("download", class = "ms-auto"),
          shiny::downloadButton(
            ns("download"),
            "Download"
          ),
          id = ns("download_popover"),
          title = "Download Table"
        ),
        class = "bg-dark d-flex align-items-center gap-1"
      ),
      reactableOutput(ns("table"))
    )
  )
}
    
#' explorer Server Functions
#'
#' @noRd 
mod_explorer_server <- function(id, full_report_df){
  moduleServer(id, function(input, output, session){
    ns <- session$ns

    rv <- reactiveValues(download_flag = 0)

    output$table <- renderReactable({
      req(full_report_df())
      reactable(full_report_df())
    })

    output$download <- downloadHandler(
      filename = function() {
        "data_table.xlsx"
      },
      content = function(file) {
        writexl::write_xlsx(full_report_df(), path = file)
        rv$download_flag <- rv$download_flag + 1
        
        if (rv$download_flag > 0) {
          toggle_popover("download_popover", show = NULL, session = session)
        }
      }
    )
  })
}
    
## To be copied in the UI
# mod_explorer_ui("explorer_1")
    
## To be copied in the server
# mod_explorer_server("explorer_1")
