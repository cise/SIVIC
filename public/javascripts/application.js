/* jQuery.ajaxSetup({ 
  'beforeSend': function(xhr) {xhr.setRequestHeader("Accept", "text/javascript")}
})
*/

jQuery.fn.submitWithAjax = function() {
  this.submit(function() {
    $.post(this.action, $(this).serialize(), null, "script");
    return false;
  })
  return this;
};

/*
 * Post ajax submit form
 */

jQuery.fn.postsForm = function(route){
	this.ajaxForm({
		dataType: 'script',
		success: function(data){
			if (data == "") {
				window.location = route;
			}
		}
	});
};

/*
 * Link with ajax the same url
 */

jQuery.fn.ajaxLink = function(){
  this.click(function(data) {
    $.get(this.href,{},function(data){
		  eval(data);
	  },"script");
    return false;
  })
  return this;
};

/*
 *  Input files style
 */
 
style_file_input = function(){
  $("input[type=file]")
	  .filter(function(index) {
      if ($(this).css("opacity") != "0") return true;
    }).filestyle({ 
        image: "/images/buttons/browse.png",
        imageheight : 23,
        imagewidth : 63,
        width : 115
      });
};

/*
 * Fullscreen online conference
 */

setFullScreen = function(){

	var windowHeight = window.innerHeight ? window.innerHeight : document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body.clientHeight;
          
  $("#header").hide();
  $("#selector").hide();
  $("#menu").hide();
  $("#global-wrapper").hide();
  $("#footer").hide();
  $("#space").css({height:"100%",width:"100%"});
  $("#content").css({height:"100%",width:"100%"});
  $("#main").css({height:"100%",width:"100%"});
  $("#embed").css({height:windowHeight,width:"100%"});
	$("div").css({padding:"0",margin:"0"});
};

unsetFullScreen = function(){
  $("#header").show();
  $("#selector").show();
  $("#menu").show();
  $("#global-wrapper").show();
  $("#footer").show();
  $("#space").css({height:"",width:""});
  $("#content").css({height:"",width:""});
  $("#main").css({height:"",width:""});
  $("#embed").css({height:"",width:""});
	$("div").css({padding:"",margin:""});
};

// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
function createNotAvailableEvent(title, start, end, allDay, room_id){
	jQuery.ajax({
        data: 'calendar_event[title]='+title+
		'&calendar_event[description]='+title+
		'&calendar_event[period]=Does%20not%20repeat'+
		'&calendar_event[starttime]='+start.toString().substring(0, 24)+ 
		'&calendar_event[endtime]='+end.toString().substring(0, 24)+
		'&calendar_event[all_day]='+allDay+
                '&calendar_event[object_id]='+room_id+
                '&calendar_event[object_type]=Room',
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/create"
	});
}

function createReservationEvent(title, start, end, allDay){
	jQuery.ajax({
        data: 'calendar_event[title]='+title+
		'&calendar_event[description]='+title+
		'&calendar_event[period]=Does%20not%20repeat'+
		'&calendar_event[starttime]='+start.toString().substring(0, 24)+ 
		'&calendar_event[endtime]='+end.toString().substring(0, 24)+
		'&calendar_event[all_day]='+allDay,
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/create"
	});
}

function createEvent(title, start, end, object_id, object_type){
	jQuery.ajax({
        data: 'calendar_event[title]='+title+
		'&calendar_event[description]='+title+
		'&calendar_event[period]=Does%20not%20repeat'+
		'&calendar_event[starttime]='+start.toString().substring(0, 24)+ 
		'&calendar_event[endtime]='+end.toString().substring(0, 24)+
		'&calendar_event[object_id]='+object_id+
		'&calendar_event[object_type]='+object_type,
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/create"
	});
}

function moveEvent(event, dayDelta, minuteDelta, allDay){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta + '&all_day=' + allDay,
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/move"
    });
}

function resizeEvent(event, dayDelta, minuteDelta){
    jQuery.ajax({
        data: 'id=' + event.id + '&title=' + event.title + '&day_delta=' + dayDelta + '&minute_delta=' + minuteDelta,
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/resize"
    });
}

function showEventDetails(event){
	$('#event_desc').html(event.description);
	$('#edit_event').html("<a href = 'javascript:void(0);' onclick ='editEvent(" + event.id + ")'>Editar</a>");

	if (event.recurring) {
		title = event.title + "(Recurring)";
		$('#delete_event').html("&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Eliminar solo esta ocurrencia</a>");
		$('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + true + ")'>Eliminar toda la serie</a>");
		$('#delete_event').append("&nbsp;&nbsp; <a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", \"future\")'>Eliminar todos los eventos futuros</a>");
	}
	else {
		title = event.title;
		$('#delete_event').html("<a href = 'javascript:void(0);' onclick ='deleteEvent(" + event.id + ", " + false + ")'>Eliminar</a>");
	}
	$('#desc_dialog').dialog({
		title: title,
		modal: true,
		width: 500,
		close: function(event, ui){
			$('#desc_dialog').dialog('destroy')
		}
		
	});
}

function showEventDescription(event){
	$('#event_desc').html(event.description);
        $('#edit_event').html("");
	$('#delete_event').html("");

	$('#desc_dialog').dialog({
		title: event.title,
		modal: true,
		width: 500,
		close: function(event, ui){
			$('#desc_dialog').dialog('destroy')
		}
	});
}

function editEvent(event_id){
    jQuery.ajax({
        data: 'id=' + event_id,
        dataType: 'script',
        type: 'get',
        url: "/calendar_events/edit"
    });
}

function deleteEvent(event_id, delete_all){
    jQuery.ajax({
        data: 'id=' + event_id + '&delete_all='+delete_all,
        dataType: 'script',
        type: 'post',
        url: "/calendar_events/destroy"
    });
}

function showRepeatUntil(value) {
    if (value) {
      $('#repeat_until').show();
    } else {
      $('#repeat_until').hide();

      $('#repeat_until_year').val("");
      $('#repeat_until_month').val("");
      $('#repeat_until_day').val("");
    }
}

function showPeriodAndFrequency(value){

    switch (value) {
        case 'Daily':
            $('#period').html('día(s)');
            $('#frequency').show();
            break;
        case 'Weekly':
            $('#period').html('semana(s)');
            $('#frequency').show();
            break;
        case 'Monthly':
            $('#period').html('mes(es)');
            $('#frequency').show();
            break;
        case 'Yearly':
            $('#period').html('año(s)');
            $('#frequency').show();
            break;
            
        default:
            $('#frequency').hide();
    }   
}

function dateScheduleAvailable(start, end, allDay){
	return $('#calendar').fullCalendar('clientEvents', function(event) 
	{
		if ((event.start < start && start < event.end) ||
		    (event.start < end && end < event.end) ||
		    (compareDate(event.start, start) && (event.allDay || allDay))
		   ) 
			{
				return true;
			}
			return false;
	}) == '';
}

function dateAvailable(start, end, allDay){
	return $('#calendar').fullCalendar('clientEvents', function(event) 
	{ 
		if (event.start < start && start < event.end)
			return true;
		else if (event.start < end && end < event.end)
			return true;
                else if (event.start > start && (event.end && event.end < end))
                        return true;
		else if (compareDateWithMinutes(event.start, start))
			return true;
		else if (event.end && compareDateWithMinutes(event.end, end))
			return true;
		else if (compareDate(event.start, start) && (event.allDay || allDay))
			return true;
		else	
			return false;
	}) == '' && (start >= new Date(new Date().getTime() + 2*60*60*1000) && start <= new Date(new Date().getTime() + 3*30*24*60*60*1000));
}

function compareDate(date1, date2)
{
	return $.fullCalendar.formatDate(date1, "yyyy-MM-dd") == $.fullCalendar.formatDate(date2, "yyyy-MM-dd"); 
}

function compareDateWithMinutes(date1, date2)
{
	return $.fullCalendar.formatDate(date1, "yyyy-MM-dd HH:mm") == $.fullCalendar.formatDate(date2, "yyyy-MM-dd HH:mm"); 
}

