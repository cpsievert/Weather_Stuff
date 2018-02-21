library(plotly)

# use scipy to read from netcdf file since R's ncdf4 
# doesn't seem to know how to read it...
dat <- reticulate::py_run_file("radiation-read.py")

# generate a 2-way color gradient
breaks <- seq(0, 1, length.out = 14)
colors <- scales::colour_ramp(c('#313695', '#3a67af', '#5994c5', '#84bbd8', '#afdbea', '#d8eff5', '#d6ffe1', '#fef4ac', '#fed987', '#fdb264', '#f78249', '#e75435', '#cc2727', '#a50026'))(breaks) 
colorscale <- data.frame(breaks, colors)

# collection of simple features which define the land boundaries
world <- sf::st_as_sf(maps::map("world", plot = FALSE, fill = TRUE))

# hide all the axes
empty_axis <- list(
  showgrid = FALSE, 
  zeroline = FALSE,
  showticklabels = FALSE,
  title = ""
)

# helper function for converting polar -> cartesian
degrees2radians <- function(degree) degree * pi / 180 

# create a grid of points for the sphere
nlat <- length(dat$lat)
nlon <- length(dat$lon) + 1
lat <- matrix(rep(dat$lat, nlon), nrow = nlat)
lon <- matrix(rep(c(dat$lon, 179.5), each = nlat), nrow = nlat)

plot_ly() %>%
  add_surface(
    x = cos(degrees2radians(lon)) * cos(degrees2radians(lat)),
    y = sin(degrees2radians(lon)) * cos(degrees2radians(lat)),
    z = sin(degrees2radians(lat)),
    surfacecolor = dat$olr,
    colorscale = colorscale,
    colorbar = list(title = "W/m²"),
    text = round(dat$olr, 2),
    hoverinfo = "text"
  ) %>%
  add_sf(
    data = world,
    x = ~ 1.001 * cos(degrees2radians(x)) * cos(degrees2radians(y)),
    y = ~ 1.001 * sin(degrees2radians(x)) * cos(degrees2radians(y)),
    z = ~ 1.001 * sin(degrees2radians(y)),
    color = I("black"), hoverinfo = "none", size = I(1)
  ) %>%
  layout(
    title = "Outgoing Longwave Radiation Anomalies<br>Dec 2017-Jan 2018",
    scene = list(
      xaxis = empty_axis, 
      yaxis = empty_axis, 
      zaxis = empty_axis,
      aspectratio = list(x = 1, y = 1, z = 1),
      camera = list(eye = list(x = 2, y = 1.15, z = 0.5))
    )
  )
