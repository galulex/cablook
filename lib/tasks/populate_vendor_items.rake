task populate_vendor_items: :environment do
  Dir['public/*.json'].each do |json_file|
    vendor_file_name = File.basename json_file, '.json'
    vendor = Vendor.pluck(:id, :name).find { |v| v[1].downcase.tr(' ', '_') == vendor_file_name }

    Vendor.find(vendor[0]).update(items: JSON.parse(File.read(json_file))) if vendor
  end
end
