class AddDisciplineToProfile < ActiveRecord::Migration
  def self.up
    add_column :profiles, :discipline, :string
    add_column :profiles, :subdiscipline, :string
    add_column :profiles, :grade, :string
  end

  def self.down
    remove_column :profiles, :grade
    remove_column :profiles, :subdiscipline
    remove_column :profiles, :discipline
  end
end
