  
$.headPos = (start_time, speed) ->
  seconds_from_start = (Date.now() - start_time) / 1000
  seconds_from_start * speed
  
unless Array::min?
  Array::min = ->
    Math.min.apply Math, this
    
$.closestPointOnALineBetween = (a, b, c) ->
  a_x = a.latitude
  a_y = a.longitude
  b_x = b.latitude
  b_y = b.longitude
  c_x = c.latitude
  c_y = c.longitude
  v = ((a_x - b_x) * (c_x - b_x) + (a_y - b_y) * (c_y - b_y)) / (Math.pow((c_x - b_x), 2) + Math.pow((c_y - b_y), 2))
  t_x = b_x + v * (c_x - b_x)
  t_y = b_y + v * (c_y - b_y)
  {latitude: t_x, longitude: t_y}

$.closestPointOnLine = (point, path) ->
  len = path.length
  e_array = []
  t_array = []
  i = 0
  while i < len - 1
    b = path[i]
    c = path[i+1]
    t = $.closestPointOnALineBetween(point, b, c)
    e = $.distanceBetweenPoints(point, t)
    e_array.push e
    t_array.push t
    i++
  t_array[e_array.indexOf(e_array.min())]

$.indexOfClosestPointOnLine = (point, path) ->
  len = path.length
  e_array = []
  i = 0
  while i < len - 1
    b = path[i]
    c = path[i + 1]
    t = $.closestPointOnALineBetween(point, b, c)
    e = $.distanceBetweenPoints(point, t)
    e_array.push e
    i++
  e_array.indexOf(e_array.min()) + 1

$.distanceBetweenPoints = (a, b) ->
  a_x = a.latitude
  a_y = a.longitude
  b_x = b.latitude
  b_y = b.longitude
  lat = (a_x + b_x)/2
  d_y = (a_y - b_y) * Math.cos(lat)
  c = Math.pow (Math.pow((a_x - b_x), 2) + Math.pow((d_y), 2)), 0.5
  6371000 * Math.PI / 180 * c

$.distanceAlongLine = (point, path, distances_array, position_index) ->
  distances_array[position_index - 1] + $.distanceBetweenPoints(path[position_index - 1], point)
