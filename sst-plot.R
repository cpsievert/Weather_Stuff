library(plotly)

# use scipy to read from netcdf file since R's ncdf4 
# doesn't seem to know how to read it...
dat <- reticulate::py_run_file("sst-read.py")

# generate a 2-way color gradient
breaks <- seq(0, 1, length.out = 14)
colors <- scales::colour_ramp(c('#141d43', '#004264', '#006675', '#3b877e', '#78a68f', '#afc5a9', '#c7c6a4', '#dabe9e', '#e3ae9b', '#d0817a', '#b85265', '#90315a', '#601d4a', '#330d35'))(breaks) 
colorscale <- data.frame(breaks, colors)

plot_ly() %>%
  add_sf(
    data = sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE)), 
    color = I("black"), fillcolor = "white", hoverinfo = "none"
  ) %>%
  add_contour(
    z = dat$sst, 
    x = dat$lon, 
    y = dat$lat,
    name = "sst",
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
      size = 0.25,
      start = -4
    )
  ) %>%
  layout(
    title = "Sea Surface Temperature Anomalies<br>Dec 2017-Jan 2018",
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
