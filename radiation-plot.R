library(plotly)

# use scipy to read from netcdf file since R's ncdf4 
# doesn't seem to know how to read it...
dat <- reticulate::py_run_file("radiation-read.py")

# generate a 2-way color gradient
breaks <- seq(0, 1, length.out = 14)
colors <- scales::colour_ramp(c('#313695', '#3a67af', '#5994c5', '#84bbd8', '#afdbea', '#d8eff5', '#d6ffe1', '#fef4ac', '#fed987', '#fdb264', '#f78249', '#e75435', '#cc2727', '#a50026'))(breaks) 
colorscale <- data.frame(breaks, colors)

plot_ly() %>%
  add_sf(
    data = sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)), 
    color = I("black"), fillcolor = "transparent", hoverinfo = "none"
  ) %>%
  add_contour(
    z = dat$olr, 
    x = dat$lon, 
    y = dat$lat,
    name = "radiation",
    zauto = FALSE,
    # this censors extreme values -- I would have gone with a a log scale myself ;)
    zmin = -20,      
    zmax = 20,
    colorscale = colorscale,
    colorbar = list(
      borderwidth = 0, 
      outlinewidth = 0, 
      thickness = 15, 
      tickfont = list(size = 14), 
      title = "W/m²"
    ),
    contours = list(
      end = 20, 
      showlines = FALSE, 
      size = 2,
      start = -20
    )
  ) %>%
  layout(
    title = "Outgoing Longwave Radiation Anomalies<br>Dec 2017-Jan 2018",
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
