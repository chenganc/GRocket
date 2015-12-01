$(document).on 'ready page:load', ->
  $('#calendar').fullCalendar
    editable: true,
    header:
      left: 'prev,next today',
      center: 'title',
      right: 'month,agendaWeek,agendaDay'
    defaultView: 'month',
    height: 500,
    slotMinutes: 30,


    events: '/events.json'

    timeFormat: 'h:mm t{ - h:mm t} ',
    dragOpacity: "0.5"

    eventDrop: (event, dayDelta, minuteDelta, allDay, revertFunc) ->
      updateEvent(event);

    eventResize: (event, dayDelta, minuteDelta, revertFunc) ->
      updateEvent(event);


updateEvent = (event) ->
  $.update "/events/" + event.id,
    event:
      title: event.title,
      starts_at: "" + event.starts_at,
      ends_at: "" + event.ends_at,
      description: event.description
