FactoryBot.define do
  factory :account do
    name { "Test Account" }
    plan { "light" }
  end

  factory :user do
    account
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}_#{Time.current.to_f}@example.com" }
    phone { Faker::PhoneNumber.phone_number }
    password { "password123" }
    role { "user" }
    confirmed { true }

    trait :manager do
      role { "manager" }
    end

    factory :manager, traits: [:manager]
  end

  factory :user_token do
    user
    token { SecureRandom.hex(10) }
    kind { :password_reset }
    issued_at { Time.current }
    expires_at { 1.day.from_now }
  end

  factory :address do
    user
    account { user.account }
    sequence(:ean) { |n| "859182400#{format("%09d", n)}" }
    role { "customer" }
    street { "Hlavní 1" }
    city { "Praha" }
    zip { "11000" }
  end

  factory :group do
    account
    name { "Test Group" }
    sequence(:identifier) { |n| "GRP-#{n}" }
  end

  factory :group_customer do
    group
    sequence(:ean) { |n| "859182400#{format("%09d", n + 100)}" }
  end

  factory :group_supplier_allocation do
    group_customer
    sequence(:ean) { |n| "859182400#{format("%09d", n + 200)}" }
    allocation_ratio { 1.0 }
    allocation_order { 1 }
  end

  factory :sharing do
    account
    from_address { association :address, role: "supplier", account: account }
    to_address { association :address, role: "customer", account: account }
    from_ean { from_address.ean }
    to_ean { to_address.ean }
    status { "active" }
    fixed_price { 2.50 }
  end
end
