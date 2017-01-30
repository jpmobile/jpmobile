class AddSessionsTable < ActiveRecord::Migration[5.0]
  def change
    create_table :sessions do |t|
      t.string :session_id, null: false
      t.text :data

      t.timestamps null: false
    end

    add_index :sessions, :session_id
    add_index :sessions, :updated_at
  end
end
