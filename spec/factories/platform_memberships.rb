# frozen_string_literal: true

FactoryBot.define do
  factory :platform_membership do
    association :user
    role { :admin }
  end
end
