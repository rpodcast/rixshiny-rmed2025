#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#'     DO NOT REMOVE.
#' @import shiny
#' @import bslib
#' @noRd
app_ui <- function(request) {
  tagList(
    # Leave this function for adding external resources
    golem_add_external_resources(),
    # Your application UI logic
    # fluidPage(
    #   golem::golem_welcome_page() # Remove this line to start building your UI
    # )
    page_navbar(
      title = "NHANES Data Explorer",
      id = "nhanes_app_navbar",
      theme = bs_theme(preset = "flatly"),
      navbar_options = navbar_options(inverse = FALSE),
      sidebar = sidebar(
        title = "Data Controls",
        width = 350,
        id = "sidebar_status",
        accordion(
          id = "sidebar_accordion",
          multiple = TRUE,
          accordion_panel(
            title = "Survey Cohort",
            value = "survey_cohort",
            selectInput(
              "survey_year",
              label = "Year",
              choices = 2012:2018,
              multiple = FALSE
            )
          ),
          accordion_panel(
            title = "Custom Filters",
            value = "custom_filters",
            uiOutput("filters_placeholder")
          )
        ),
        actionButton(
          "remove_all_filters",
          "Remove Filters",
          class = "btn-danger"
        )
      ),
      nav_panel(
        "Home",
        value = "home",
        mod_home_ui("home_1")
      ),
      nav_panel(
        "Data Explorer",
        value = "data_explorer",
        mod_explorer_ui("explorer_1")
      )
    )
  )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
  add_resource_path(
    "www",
    app_sys("app/www")
  )

  tags$head(
    favicon(),
    bundle_resources(
      path = app_sys("app/www"),
      app_title = "nhanes.shinyapp"
    )
    # Add here other external resources
    # for example, you can add shinyalert::useShinyalert()
  )
}
