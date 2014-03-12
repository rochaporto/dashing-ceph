Batman.Filters.bytesNumber = (num) ->
  return num if isNaN(num)
  if num >= 1000000000000000000
    (num / 1000000000000000000).toFixed(1) + 'E'
  else if num >= 1000000000000000
    (num / 1000000000000000).toFixed(1) + 'P'
  else if num >= 1000000000000
    (num / 1000000000000).toFixed(1) + 'T'
  else if num >= 1000000000
    (num / 1000000000).toFixed(1) + 'G'
  else if num >= 1000000
    (num / 1000000).toFixed(1) + 'M'
  else if num >= 1000
    (num / 1000).toFixed(1) + 'K'
  else
    num

class Dashing.Meter extends Dashing.Widget

  @accessor 'value', Dashing.AnimatedValue

  constructor: ->
    super
    @observe 'value', (value) ->
      $(@node).find(".meter").val(value).trigger('change')

  ready: ->
    meter = $(@node).find(".meter")
    meter.attr("data-bgcolor", meter.css("background-color"))
    meter.attr("data-fgcolor", meter.css("color"))
    meter.knob()
