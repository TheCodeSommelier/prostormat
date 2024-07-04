# frozen_string_literal: true

class AddDetailsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :company_name, :string
    add_column :users, :phone_number, :string
    add_column :users, :company_address, :string
    add_column :users, :ico, :string
    add_column :users, :dic, :string
  end
end
