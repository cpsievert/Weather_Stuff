library(plotly)

# use scipy to read from netcdf file since R's ncdf4 
# doesn't seem to know how to read it...
dat <- reticulate::py_run_file("precip-read.py")

# generate a 2-way color gradient
breaks <- seq(0, 1, length.out = 14)
colors <- scales::colour_ramp(c("red", "white", "blue"))(breaks) 
colorscale <- data.frame(breaks, colors)

plot_ly() %>%
  add_sf(
    data = sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)), 
    color = I("black"), fillcolor = "transparent", hoverinfo = "none"
  ) %>%
  add_contour(
    z = dat$air, 
    x = dat$lon, 
    y = dat$lat,
    name = "air temp",
    zauto = FALSE,
    # this censors extreme values -- I would have gone with a a log scale myself ;)
    zmin = -5,      
    zmax = 5,
    colorscale = colorscale,
    colorbar = list(
      borderwidth = 0, 
      outlinewidth = 0, 
      thickness = 15, 
      tickfont = list(size = 14), 
      title = "°C"
    ),
    contours = list(
      end = 4, 
      showlines = FALSE, 
      size = 0.5,
      start = -4
    )
  ) %>%
  layout(
    title = "Surface Air Temperature Anomalies<br>Dec 2017-Jan 2018",
    showlegend = FALSE,
    annotations = list(
      text = "Data courtesy of <a href='http://www.esrl.noaa.gov/psd/data/composites/day/'>NOAA Earth System Research Laboratory</a>",
      xref = 'paper',
      yref = 'paper',
      x = 0,
      y = 0,
      yanchor = 'top',
      showarrow = FALSE
    ),
    yaxis = list(title = ""),
    xaxis = list(title = "", range = range(dat$lon))
  )
