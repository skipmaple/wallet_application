# frozen_string_literal: true

class Account < ApplicationRecord
  connection.create_table :accounts, force: :cascade do |t|
    t.string :address, null: false, comment: "wallet address"
    t.integer :lock_version, default: 0, comment: "locking column"
    t.decimal :balance, precision: 20, scale: 6, default: '0', null: false, comment: "wallet balance"
    t.timestamps
  end unless table_exists?

  attr_readonly :address
  after_initialize :generate_address, if: :new_record?

  validates :address, presence: true, uniqueness: true
  validates_numericality_of :balance, :greater_than_or_equal_to => 0

  has_many :transaction_histories, class_name: "TransactionHistory", foreign_key: :sender_id

  def generate_address
    self.address = SecureRandom.uuid
  end

  def transfers
    TransactionHistory.where(sender: self).or(TransactionHistory.where(recipient: self))
  end

  def deposit(amount, with_record = true)
    raise 'Transfer amount must greater than 0.' if amount <= 0
    operate_with_retry(:deposit, amount, with_record)
  end

  def withdraw(amount, with_record = true)
    check_amount(amount)
    operate_with_retry(:withdraw, amount, with_record)
  end

  def transfer(amount, recipient)
    check_amount(amount)
    ActiveRecord::Base.transaction do
      withdraw(amount, false)
      recipient.deposit(amount, false)
      transaction_histories.create(sender: self, recipient: recipient, category: TransactionHistory.categories[:transfer], amount: amount)
    end
  end

  private

  def operate_with_retry(category, amount, with_record)
    retry_times = 5
    begin
      reload
      case category
      when :deposit
        self.balance += amount
      when :withdraw
        self.balance -= amount
      end
      save!

      transaction_histories.create(sender: self, recipient: nil, category: TransactionHistory.categories[category], amount: amount) if with_record
    rescue ActiveRecord::StaleObjectError
      retry_times -= 1
      if retry_times > 0
        sleep(0.5)
        retry
      else
        raise "Account(#{address}) stuck in #{category} action, please retry later."
      end
    rescue => e
      raise e.message
    end
  end

  def check_amount(amount)
    raise 'Wallet do not have enough money.' if amount > balance
    raise 'Transfer amount must greater than 0.' if amount <= 0
  end
end
