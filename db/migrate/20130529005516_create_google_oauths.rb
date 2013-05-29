class CreateGoogleOauths < ActiveRecord::Migration
  def change
    create_table :google_oauths do |t|
      t.string :access_token
      t.string :refresh_token
      t.datetime :token_expires_at
      t.integer :user_id

      t.timestamps
    end
  end
end
