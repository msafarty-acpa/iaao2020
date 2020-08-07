ui = dashboardPage(
  dashboardHeader(title = "This is the header"),
  dashboardSidebar(helpText(HTML("<font size = 25; color = white> This is the sidebar </font>" ))
  ),
  dashboardBody(
    fluidRow(
      box(helpText(HTML("<font size = 25; color = black> Box 1, top left, half the available space </font>" ))
      ),
      box(helpText(HTML("<font size = 25; color = black> Box 2, top right, half the available space </font>" ))
      )
    ),
    fluidRow(
      box(
        helpText(HTML("<font size = 25; color = black> Box 3, full row below the top row </font>" )), height = 300, width = 12
      )
    )
  )
)

#Server logic
server = function(input, output, session) { }
shinyApp(ui, server)