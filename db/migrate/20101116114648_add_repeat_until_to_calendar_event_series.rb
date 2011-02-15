class AddRepeatUntilToCalendarEventSeries < ActiveRecord::Migration
  def self.up
    add_column :calendar_event_series, :repeat_until, :datetime
    add_column :calendar_event_series, :title, :string
    add_column :calendar_event_series, :description, :text
    add_column :calendar_event_series, :object_id, :integer
    add_column :calendar_event_series, :object_type, :string
  end

  def self.down
    remove_column :calendar_event_series, :repeat_until
    remove_column :calendar_event_series, :title
    remove_column :calendar_event_series, :description
    remove_column :calendar_event_series, :object_id
    remove_column :calendar_event_series, :object_type
  end
end
