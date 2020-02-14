class Presenters::Cars::Single < Presenters::BaseSingle
  properties :id, :number, :status, :phone_number

  property :dis, exec_context: :decorator
  property :deg, exec_context: :decorator

  def dis
    rad_per_deg = Math::PI/180
    rkm = 6371
    # rm = rkm * 1000

    dlat_rad = (position[1]-location[1]) * rad_per_deg
    dlon_rad = (position[0]-location[0]) * rad_per_deg

    lat1_rad, lon1_rad = location.map {|i| i * rad_per_deg }.reverse
    lat2_rad, lon2_rad = position.map {|i| i * rad_per_deg }.reverse

    a = Math.sin(dlat_rad/2)**2 + Math.cos(lat1_rad) * Math.cos(lat2_rad) * Math.sin(dlon_rad/2)**2
    c = 2 * Math::atan2(Math::sqrt(a), Math::sqrt(1-a))

    # rm * c
    @dis ||= rkm * c
  end

  def deg
    y = Math.sin(position[1] - location[1]) * Math.cos(position[0]);
    x = Math.cos(location[0]) * Math.sin(position[0]) -
      Math.sin(location[0]) * Math.cos(position[0]) * Math.cos(position[1] - location[1]);
    @deg ||= Math::atan2(y, x) * 180 / Math::PI
  end

  private

  def location
    # binding.pry
    @location ||= represented.location
  end

  def position
    @position ||= represented.position
  end
end
