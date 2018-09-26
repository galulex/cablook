document.addEventListener('turbolinks:load', function(event) {
  var $page = $("[data-page='analytics']");
  if ($page.length > 0) {
    init();
  }
});

var chart_labels = [];
var chart_values = [];

function init() {
  document.getElementById("defaultOpen").click();
  $('.js-trip').each(function(index, trip) {
    data = $(trip).data('trips');
    chart_labels = data.days || data.hours;
    chart_values.push(data);
  });
  byDaysChart();
}

function byDaysChart() {
  data = {
    labels: chart_labels,
    datasets: chart_values
  }

  new frappe.Chart( "#daysChart", {
    data: data,
    type: 'bar',
    height: 500,
    barOptions: {
      stacked: 1
    },
    colors: ['#FF8C00', '#32CD32', '#FF0000', '#696969']
  });
}

function byHoursChart() {
  data = {
    labels: chart_labels,
    datasets: chart_values
  }

  new frappe.Chart( "#hoursChart", {
    data: data,
    type: 'bar',
    height: 500,
    barOptions: {
      stacked: 1
    },
    colors: ['#FF8C00', '#32CD32', '#FF0000', '#696969']
  });
}

function openTab(evt, tabName) {
  var i, tabcontent, tablinks;
  
  tabcontent = document.getElementsByClassName("tabcontent");
  for (i = 0; i < tabcontent.length; i++) {
      tabcontent[i].style.display = "none";
  }

  tablinks = document.getElementsByClassName("tablinks");
  for (i = 0; i < tablinks.length; i++) {
      tablinks[i].className = tablinks[i].className.replace(" active", "");
  }

  document.getElementById(tabName).style.display = "block";
  evt.currentTarget.className += " active";
}