class Dashing.Health extends Dashing.Widget
  onData: (data) ->
    if data.status
      if data.status == "ok"
        $(@node).css("background-color", "green");
      if data.status == "warn"
        $(@node).css("background-color", "orange");
      if data.status == "err"
        $(@node).css("background-color", "red");
