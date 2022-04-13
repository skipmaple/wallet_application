# frozen_string_literal: true

require 'active_record'
require './models/application_record'
require './models/account'
require './models/transaction_history'

RSpec.describe Account do

  subject(:user_1) { Account.create }
  subject(:user_2) { Account.create }

  context 'When testing the Account class' do
    before do
      @account = Account.create
    end

    it 'should create new account' do
      new_account = Account.new
      expect(new_account).to be_valid
    end

    it 'should address not be empty' do
      new_account = Account.new
      expect(new_account.address).not_to be_empty
    end

    it 'should not update account address' do
      @account.update(address: "updated_address")
      @account.reload
      expect(@account.address).not_to eq "updated_address"
    end

    it 'should delete the account' do
      @account.destroy
      expect { @account.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'When testing Wallet operation' do
    it 'should deposit money to wallet' do
      user_1.deposit(100)
      expect(user_1.balance).to eq BigDecimal('100')
    end

    it 'should withdraw money from wallet' do
      user_1.deposit(100)
      user_1.withdraw(99.99)
      expect(user_1.balance).to eq BigDecimal('0.01')
    end

    it 'should not withdraw if amount greater than wallet balance' do
      user_1.deposit(100)
      expect { user_1.withdraw(200) }.to raise_error(RuntimeError, "Wallet do not have enough money.")
    end

    it 'should transfer money from user_1 to user_2' do
      user_1.deposit(100)
      user_1.transfer(9.99999, user_2)
      expect(user_1.balance).to eq BigDecimal('90.00001')
      expect(user_2.balance).to eq BigDecimal('9.99999')
    end

    it 'should have transaction_histories' do
      user_1.deposit(100)
      expect(user_1.transfers.count).to eq 1
      user_1.withdraw(20)
      expect(user_1.transfers.count).to eq 2
      user_1.transfer(10, user_2)
      expect(user_1.transfers.count).to eq 3
      expect(user_2.transfers.count).to eq 1
    end

  end
end
