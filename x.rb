require 'irb'


class Account
  attr_accessor :state

  def initialize(state)
    @state = state
  end
end

module Debit
  def transaction(amount)
    self.state = state - amount
  end
end

module Credit
  def transaction(amount)
    self.state = state + amount
  end
end

account = Account.new(100)
account.state                       # => 100
puts account.public_methods(false)  # => [:state, :state=]

debit = Debit.instance_method(:transaction)
credit = Credit.instance_method(:transaction)

# Lets do debit transactions
transaction = debit.bind(account)
transaction.call(6)

puts account.state                       # => 94
puts account.public_methods(false)  # => [:state, :state=]


# Lets do credit transactions
transaction = credit.bind(account)
transaction.call(15)

puts account.state                  # => 109
puts account.public_methods(false)  # => [:state, :state=]







binding.irb

