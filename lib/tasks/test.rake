#!/usr/bin/env ruby
# Rake task to run only critical tests

desc 'Run critical tests only'
task 'test:critical' do
  sh 'bundle exec rspec --tag critical'
end

desc 'Run all tests'
task 'test:all' do
  sh 'bundle exec rspec'
end

desc 'Run tests with coverage report'
task 'test:coverage' do
  sh 'COVERAGE=true bundle exec rspec'
end

desc 'Run model tests only'
task 'test:models' do
  sh 'bundle exec rspec spec/models/'
end

desc 'Run request tests only'
task 'test:requests' do
  sh 'bundle exec rspec spec/requests/'
end
