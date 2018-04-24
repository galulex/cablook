ActiveAdmin.register_page 'Calculations' do
  content do
    render 'index'
  end

  controller do
    def index
      status = params[:status] || Constants::Trip::FINISHED
      @data = Trip.beetwen(from, to).by_status(status).sum_cost
    end
  end
end

def from
  params[:from].blank? ? Time.now.beginning_of_day : params[:from]
end

def to
  params[:to].blank? ? Time.now.end_of_day : params[:to]
end
