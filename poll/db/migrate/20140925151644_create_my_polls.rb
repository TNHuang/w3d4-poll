class CreateMyPolls < ActiveRecord::Migration
  def change
    create_table :my_polls do |t|
      t.string :title
      t.integer :author_id

      t.timestamps
    end

    add_index :my_polls, :author_id
  end
end
