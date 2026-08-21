# frozen_string_literal: true

FactoryBot.define do
  factory :theme do
    association :venue
    name { 'Decades Night' }
    description { 'Songs from a selected decade.' }
    rules { {} }
    active { true }
  end
end
