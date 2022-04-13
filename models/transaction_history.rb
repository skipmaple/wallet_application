# frozen_string_literal: true

class TransactionHistory < ApplicationRecord
  connection.create_table :transaction_histories, force: :cascade do |t|
    t.bigint :sender_id, null: false, comment: "sender userid"
    t.bigint :recipient_id, comment: "recipient userid"
    t.decimal :amount, precision: 20, scale: 6, default: '0', null: false, comment: "operate amount"
    t.integer :category, null: false, comment: "operate category"
    t.timestamps
  end unless table_exists?

  validates :sender_id, :amount, :category, presence: true

  belongs_to :sender, class_name: "Account", foreign_key: :sender_id
  belongs_to :recipient, class_name: "Account", foreign_key: :recipient_id

  enum category: [:deposit, :withdraw, :transfer]

end
