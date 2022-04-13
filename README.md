# Wallet Application

## Description

Write code for a Wallet Application that behaves as follows:

Required features:

- [x] User can deposit money into her wallet
- [x] User can withdraw money from her wallet
- [x] User can send money to another user
- [x] User can check her wallet balance

Optional features:

- [x] User can see her wallet transaction history

## Run

```shell
bundle install

rspec test/wallet_application_spec.rb
```

## Features

- To make as less codes as possible, I just use active_record gem
- Use database sqlite to store data
- Use active_record lucky lock to handle transfer
- Transfer have retry function when failed, max retry time is 5
- `balance` and `amount` use decimal type to store, precision 20 and scale 6

## Design

Account data demo:

```ruby
{
  "id" => 23,
  "address" => "7f6da095-2253-40e6-845c-cfae4a5d502f", # generate random address when create account
  "balance" => 0.2e2, # use big_decimal precision 20 and scale 6
  "lock_version" => 1, # use active_record lucky lock to handle transfer
  "created_at" => 2022 - 04 - 13 09 : 01 : 16.894498 UTC,
  "updated_at" => 2022 - 04 - 13 09 : 01 : 20.784188 UTC
}
```

Transaction history data demo

`user_1.deposit(20)` generate transaction_history:

```ruby
{
  "id" => 19,
  "sender_id" => 23, # sender_userid
  "recipient_id" => nil, # recipient_userid
  "amount" => 0.2e2, # operate amount store by big_decimal
  "category" => "deposit", # use enum { 0:deposit, 1:withdraw, 2:transfer }
  "created_at" => 2022 - 04 - 13 09 : 01 : 20.801962 UTC,
  "updated_at" => 2022 - 04 - 13 09 : 01 : 20.801962 UTC
}
```

`user_1.transfer(5.000001, user_2)` generate transaction_history:

```ruby
{
  "id" => 20,
  "sender_id" => 23, # user_1 id
  "recipient_id" => 24, # user_2 id
  "amount" => 0.5000001e1, # operate amount
  "category" => "transfer", # operate category
  "created_at" => 2022 - 04 - 13 09 : 14 : 46.461924 UTC,
  "updated_at" => 2022 - 04 - 13 09 : 14 : 46.461924 UTC
}
```

## Future Consideration

- One account has many wallets
- Develop a gem to accomplish wallet application
