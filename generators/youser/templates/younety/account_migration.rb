class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    create_table "<%= table_name %>", :force => true do |t|
      t.column :fullname, :string
      t.column :nickname, :string
      t.column :primary_email, :string
      t.column :remember_token, :string
      t.column :remember_token_expires_at, :datetime
      t.column :younety_token, :string
      t.column :salt, :string
      t.timestamps
    end
  end

  def self.down
    drop_table "<%= table_name %>"
  end
end