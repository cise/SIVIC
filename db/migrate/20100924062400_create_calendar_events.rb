class CreateCalendarEvents < ActiveRecord::Migration
  def self.up
    create_table :calendar_events do |t|
      t.string :title, :url
      t.text :description
      t.datetime :starttime, :endtime
      t.boolean :all_day, :default => false
      t.integer :calendar_event_series_id
      t.string :object_type
      t.integer :object_id
      t.string :type
      
      t.timestamps
    end
  end

  def self.down
    drop_table :calendar_events
  end
end
