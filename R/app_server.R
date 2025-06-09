#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#'     DO NOT REMOVE.
#' @import shiny
#' @import teal.slice
#' @noRd
app_server <- function(input, output, session) {
  # reactive values
  custom_datasets_rv <- reactiveVal(NULL)
  reset_trigger <- reactiveVal(NULL)

  # update to sub-page/sub-URL when we move to a new tab from the navbar
  observeEvent(session$clientData$url_hash, {
    currentHash <- sub("#", "", session$clientData$url_hash)
    if(is.null(input$nhanes_app_navbar) || !is.null(currentHash) && currentHash != input$nhanes_app_navbar) {
      freezeReactiveValue(input, "nhanes_app_navbar")
      updateNavbarPage(session, "nhanes_app_navbar", selected = currentHash)
    }
  }, priority = 1)
  
  # push changes to the sub-URL to the browser history so that back/forward browser buttons work
  observeEvent(input$nhanes_app_navbar, {
    currentHash <- sub("#", "", session$clientData$url_hash) 
    pushQueryString <- paste0("#", input$nhanes_app_navbar)
    if(is.null(currentHash) || currentHash != input$nhanes_app_navbar){
      freezeReactiveValue(input, "nhanes_app_navbar")
      updateQueryString(pushQueryString, mode = "push", session)
    }
  }, priority = 0)

  # combine data sets
  all_df <- dplyr::left_join(
    nhanes.shinyapp::nhanes_demo,
    nhanes.shinyapp::nhanes_bp,
    by = "SEQN"
  )

  survey_year <- reactive({
    req(input$survey_year)
    input$survey_year
  })

  all_df_rv <- reactive({
    req(survey_year())
    all_df |>
      dplyr::filter(stringr::str_detect(SDDSRVYR, survey_year()))

  })

  # create FilteredData object
  observe({
    req(survey_year())
    req(all_df_rv())
    datasets <- init_filtered_data(
      list(nhanes_data = all_df_rv())
    )
    
    # set initial state
    set_filter_state(
      datasets = datasets,
      filter = teal_slices(
        allow_add = TRUE
      )
    )

    custom_datasets_rv(datasets)
  })  

  # render filter widgets
  output$filters_placeholder <- renderUI({
    tagList(
      custom_datasets_rv()$ui_active("filter_panel")
    )
  })

  # dynamically add filter variable choices and settings panel
  observe({
    custom_datasets_rv()$srv_active("filter_panel")
  })

  # reactive for filtered data
  full_report_df <- reactive({
    custom_report_df <- custom_datasets_rv()$get_data(
      dataname = "nhanes_data",
      filtered = TRUE
    )
    return(custom_report_df)
  })

  # clear all filter choices and refresh data to original state
  observeEvent(input$remove_all_filters, {
    clear_filter_states(custom_datasets_rv())
    reset_trigger(rnorm(1))
  })

  # execute modules
  mod_explorer_server("explorer_1", full_report_df)
}
