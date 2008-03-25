class CreateYouserAuthenticators < ActiveRecord::Migration
  def self.up
    create_table :youser_authenticators, :force => true do |t|
      t.column :type,                      :string
      t.column :email,                     :string
      t.column :account_id,                :integer
      #facebook features
      t.column :facebook_uid,              :integer
      t.column :facebook_session_key,      :string
      #open_id features
      t.column :identity_url,              :string
      t.column :nickname,                  :string
      t.column :fullname,                  :string
      #local user features
      t.column :login,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
    end
  end

  def self.down
    drop_table :youser_authenticators
  end
end
