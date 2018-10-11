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
  Constants::Analytics::CHART_DATA.merge(data: chart_type)
end

def chart_type
  return if params[:chart].nil?
  Analytics.run("#{params[:chart]}", trip_status, from, to)
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
