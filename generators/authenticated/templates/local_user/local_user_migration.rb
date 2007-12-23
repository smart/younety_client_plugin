class CreateLocalUsers < ActiveRecord::Migration
  def self.up
    create_table :local_users, :force => true do |t|
      t.column :login,                     :string
      t.column :email,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      <% if options[:include_activation] %>
      t.column :activation_code, :string, :limit => 40
      t.column :activated_at, :datetime<% end %>
    end
  end

  def self.down
    drop_table :local_users
  end
end
