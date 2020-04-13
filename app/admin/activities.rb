ActiveAdmin.register PaperTrail::Version, as: 'Activity' do
  remove_filter :whodunnit

  index do
    selectable_column
    %w[id item_type item_id event].each { |title| column title }
    column :whodunnit do |activity|
      actioner(activity)
    end
    actions
  end

  show do
    attributes_table do
      %w[id item_type event].each { |title| row title }
      row :item do
        link_to('Item', "/admin/#{activity.item_type.downcase}s/#{activity.item_id}") if activity.item_type && activity.item_id
      end
      row :whodunnit do
        actioner(activity)
      end
      panel 'Changes' do
        attributes_table_for activity.changeset do
          row 'Field' do
            th 'Was'
            th 'Became'
          end
          activity.changeset.each do |key, value|
            row key do
              td check_value_type(show_value(value[0]))
              td check_value_type(show_value(value[1]))
            end
          end
        end
      end
    end
  end
end

def actioner(activity)
  activity.whodunnit ? link_to(activity.whodunnit_type, "/admin/#{activity.whodunnit_type.downcase}s/#{activity.whodunnit}") : 'Admin'
end

def show_value(value)
  value.nil? ? 'Empty' : value
end

def check_value_type(value)
  value.instance_of? Array ? value.join(', ') : value
end

