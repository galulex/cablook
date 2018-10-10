ActiveAdmin.register_page 'Analytics' do
  content do
    render 'index'
  end

  controller do
    def index
      @data = chart_data
    end
  end
end

def chart_data
  { data: chart_type,
    type: 'bar',
    height: 600,
    barOptions: { stacked: 1 },
    colors: ['#32CD32', '#FF8C00', '#FF0000', '#696969'] }
end

def chart_type
  return if params[:chart].nil?
  TaxiAnalytics.run("#{params[:chart]}", trip_status, from, to)
end

def from
  params[:from].presence || Time.now.beginning_of_day.strftime('%F')
end

def to
  params[:to].presence || Time.now.end_of_day.strftime('%F')
end

def trip_status
  params[:status].presence || (4..7).to_a
end
