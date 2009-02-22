class CreateMailcarTables < ActiveRecord::Migration

  def self.up
    create_table :mailcar_messages, :force => true do |t|
      t.string :from
      t.text :body
      t.text :subject
      t.timestamps
    end
    
    create_table :mailcar_sendings, :force => true do |t|
      t.integer :mailcar_message_id
      t.string :email_address
      t.datetime :sent_at
    end
    
    add_index :mailcar_sendings, :mailcar_message_id
    add_index :mailcar_sendings, [:sent_at, :mailcar_message_id]
  end

  def self.down
    drop_table :mailcar_messages
    drop_table :mailcar_sendings
  end

end