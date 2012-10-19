jQuery ($) ->      
  class Slider
    constructor: (element) ->
      @_slider = $(element)
      @_slider_floats = @_slider.children('.float')
      @_window = @_slider.parent()
      @_content_window = $('#content_window')
      @_speed = 10
      @_start_time = Date.now()
      @_float = $('#float')
      @_pointer = @_slider.find('.pointer')
      @_updatable = true
      @getPath()
      @getFloats()
      @setSwiper()
      @setContentSwiper()
      $('#find_me a').bind "click", @findPointer
      $.each @_slider_floats, (i, float) =>
        $(float).bind "click", @displayFloat
      
    # Prevent the content swiper from scrolling automatically.
    # If the index of the clicked block is different to the index of the
    # @_content_swiper object, slide the content_swiper to the same index
    displayFloat: (e) =>
      e.preventDefault()
      @contentStick()
      block = $(e.currentTarget)
      float_index = block.attr('data-index')
      index = @_content_swiper.index
      unless float_index == index
        i = parseInt(block.attr("data-index"), 10)
        @_content_swiper.slide(i)
  
  
    # swipeTo: (i) =>
    #   @_content_swiper.slide(i)
    #   
    #   
    # showAndStick: (i) =>
    #   @_updatable = false
    #   @_content_swiper.slide(i)
    #   

    # create a swiper to scroll through the float blocks
    setSwiper: () =>
      @_swiper = new Swipe @_window[0]
      
      # For non-swiping test purposes
      $('.next').bind "click", () =>
        @_swiper.next()
      $('.prev').bind "click", () =>
        @_swiper.slide @_swiper.index-1, @_swiper.speed
      
    # Set up swiper for the displayed floats.
    setContentSwiper: () =>
      @_content_swiper = new Swipe @_content_window[0], {moved_callback: @contentStick}
      
      # For non-swiping test purposes
      $('.next_float').bind "click", () =>
        @_content_swiper.next()
      $('.prev_float').bind "click", () =>
        @_content_swiper.prev()
      
      
    # Prevent content slider from sliding automatically.
    contentStick: () =>
      @_updatable = false
    
    # Get floats data from server and start updating the position
    # of the procession.
    getFloats: () =>
      $.getJSON "/procession_floats", (data) =>
        @_floats = data
        @setUpdater()
      window.setInterval () =>
        $.getJSON "/procession_floats", (data) =>
          @_floats = data
          $.each data, (i, float) =>
            @_slider_floats.find("[data-index='#{i}']").css
              left: float.offset
      , 10000

    # Slide the slider to the position of the pointer.
    # Allow the content swiper to slide automatically.
    findPointer: (e) =>
      e.preventDefault()
      @deviceLocation()
      unless @_swiper.index == 0
        @_swiper.slide 0
      @_updatable = true

    # Get route data from the server and calculate the distance of each point
    # from the start of the route.
    getPath: () =>
      @_path = []
      $.getJSON "1/points", (data) =>
        $.each data, (i, point) =>
          p =
            latitude: parseFloat point.latitude
            longitude: parseFloat point.longitude
          @_path.push p
        @calculatePositionDistances @_path

    # Find the position of the device.
    # Check every x seconds for the device position.
    setUpdater: (x) =>
      x ||= 3
      @deviceLocation()
      @_updater = window.setInterval () =>
        @deviceLocation()
      , x * 1000

    # Get location of the device and callback to getPosition or reportError
    # or alert lack of Geolocation support.
    deviceLocation: () =>
      geolocation = window.navigator.geolocation
      if geolocation
        timeoutVal = 20 * 1000
        geolocation.getCurrentPosition @getPosition, @reportError,
          enableHighAccuracy: true
          timeout: timeoutVal
          maximumAge: 0
      else
        alert "Geolocation is not supported by this browser"

    # Get latitude and longitude from geolocation object to create
    # a latitude/longitude object.
    # Calculate the offset between device and head of procession.
    getPosition: (location) =>
      point =
        latitude: location.coords.latitude
        longitude: location.coords.longitude
      @calcOffset point

    # Return error message.
    reportError = (error) =>
      errors = {
        1: 'Permission denied',
        2: 'Position unavailable',
        3: 'Request timeout'
      };
      alert("Error: " + errors[error.code])

    # Calculate distance between rote start and procession head.
    # Find the closest point on the route to the device.
    # Calculate distance from the start of the route to
    # the device.
    # Calculate distance between head of procession and device.
    # Update the slider position
    calcOffset: (geo_point) =>
      head_distance = $.headPos @_start_time, @_speed
      position = $.closestPointOnLine geo_point, @_path
      index = $.indexOfClosestPointOnLine position, @_path
      start_dist = $.distanceAlongLine position, @_path, @_distances, index
      distance_from_head = head_distance - start_dist
      slider_offset = - Math.round(distance_from_head)
      @updatePosition(slider_offset)

    # Set the left position of the slider to the offset.
    # Move the pointer to the device's position in procession.
    # Move the content swiper to the right float.
    updatePosition: (offset) =>
      @_slider.css
        left: offset
      @_pointer.css
        left: -offset
      if @_updatable == true
        @findFloat offset

    # Find the float being pointed at (or the next one if there is a next one)
    # and slide the content swiper to the same index
    # If no float, scroll the content swiper back to the start
    findFloat: (offset) =>
      floats = @_floats.filter (float) =>
        (float.offset <= -offset) and (float.length + float.offset >= (-offset))
      float = floats[0]
      content = @_float.find('.content')
      if float
        i = @_floats.indexOf(float)
        @_content_swiper.slide i
      else
        # find the next float
        floats = @_floats.filter (float) =>
          float.offset > -offset
        float = floats[0]
        if float
          i = @_floats.indexOf(float)
          @_content_swiper.slide i
        else
          @_content_swiper.slide 0

    # Calculate the total distance of each point from the start of the route
    # and push into parallel array
    calculatePositionDistances: (array) =>
      @_distances = [0]
      for point in array 
        unless array.indexOf(point) == 0
          i = array.indexOf(point) - 1
          @_distances.push($.distanceBetweenPoints(point, array[i]) + @_distances[i])

  # set up slider
  $.fn.start_sliding = () ->
    @each ->
      slider = new Slider @

$ ->
  $('.slider').start_sliding()

  # -------------------- benchmarking -------------------- #
  
  # suite = new Benchmark.Suite
  # 
  # a = {latitude: 0, longitude: 0}
  # b = {latitude: 1, longitude: 1}
  # c = {latitude: -1, longitude: 1}
  # path = [
  #   {latitude: 54.198061, longitude: -3.092934},
  #   {latitude: 54.196981, longitude: -3.0957},
  #   {latitude: 54.196021, longitude: -3.096365},
  #   {latitude: 54.195876, longitude: -3.096472}
  # ]
  # closest_point = $.closestPointOnLine(a, path)
  # index_of_closest_point = $.indexOfClosestPointOnLine(closest_point, path)
  # distances_array = $.calculatePositionDistances(path)
  # 
  # suite
  # .add 'distanceBetweenPoints', () ->
  #   $.distanceBetweenPoints(a, b)
  #   
  # .add 'headPos', () ->
  #   $.headPos(start_time, speed)
  #   
  # .add 'distanceAlongLine', () ->
  #   $.distanceAlongLine(a, path, distances_array, index_of_closest_point)
  #   
  # # .add 'degreesToPoint', () ->
  # #   $.degreesToPoint(a, b)
  #   
  # .add 'closestPointOnLine', () ->
  #   $.closestPointOnLine(a, path)
  #   
  # .add 'indexOfClosestPointOnLine', () ->
  #   $.indexOfClosestPointOnLine(a, path)
  #   
  # .add 'calculatePositionDistances', () ->
  #   $.calculatePositionDistances(path)
  #   
  # .add 'closestPointOnALineBetween', () ->
  #   $.closestPointOnALineBetween(a, b, c)
  # 
  # .add 'calcOffset', () ->
  #   $('.slider').calcOffset(a)
  #   
  # # .add 'personPos', () ->
  # #   $.personPos()
  #   
  # .on 'cycle', (event) ->
  #   console.log(String(event.target))
  # 
  # # .on 'complete', () ->
  # #   console.log('Fastest is ' + this.filter('fastest').pluck('name'))
  # 
  # .run({ 'async': true })
  