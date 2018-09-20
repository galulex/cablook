ActiveAdmin.register_page 'Analytics' do
  content do
    render 'index'
  end

  controller do
    def index
      @trips = Trip.beetwen(from, to).by_status(trip_status).pluck(:id, :status, :created_at).as_json
    end
  end
end

def from
  params[:from].blank? ? Time.now.beginning_of_day : params[:from]
end

def to
  params[:to].blank? ? Time.now.end_of_day : params[:to]
end

def trip_status
  params[:status].blank? ? (0..6).to_a : params[:status]
end
