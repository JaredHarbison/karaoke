# This file creates local development records for manual feature testing.
# It is intentionally a no-op in test and production environments.
#
return unless Rails.env.development?

password = ENV.fetch('KARAOKE_DEMO_PASSWORD', 'KaraokeDemo123!')

seed_user = lambda do |email, user_password|
  user = User.find_or_create_by!(email: email) do |record|
    record.password = user_password
    record.password_confirmation = user_password
  end
  user.update!(password: user_password, password_confirmation: user_password)
  user
end

owner = seed_user.call('owner@karaoke.test', password)
host = seed_user.call('host@karaoke.test', password)
performer = seed_user.call('performer@karaoke.test', password)
seed_user.call('performer.demo@karaoke.test', password)

venue = Venue.find_or_create_by!(slug: 'demo-karaoke') do |record|
  record.name = 'Demo Karaoke'
  record.public = true
end
venue.update!(name: 'Demo Karaoke', public: true, owner: owner)
venue.add_host(host)

[
  ['Alex', 'https://www.youtube.com/watch?v=demo-alex', performer],
  ['Jamie', 'https://www.youtube.com/watch?v=demo-jamie', performer]
].each do |performer_name, url, user|
  venue.performances.find_or_create_by!(performer: performer_name, url: url) do |song|
    song.user = user
    song.category = 'pop'
  end
end

puts <<~MESSAGE
  Seeded manual-test data:
    Venue:     Demo Karaoke (/demo-karaoke/songs)
  Owner:     owner@karaoke.test / #{password}
  Host:      host@karaoke.test / #{password}
  Performer: performer@karaoke.test / #{password}
  Demo:      performer.demo@karaoke.test / #{password}
MESSAGE

if ENV['KARAOKE_QA_FIXTURE'] == 'franklin'
  qa_password = ENV.fetch('KARAOKE_QA_PASSWORD', password)
  qa_owner = seed_user.call(ENV.fetch('KARAOKE_QA_OWNER_EMAIL', 'jared.harbison@gmail.com'), qa_password)
  qa_host = seed_user.call(ENV.fetch('KARAOKE_QA_HOST_EMAIL', 'jared.harbison+host@gmail.com'), qa_password)
  qa_performer = seed_user.call(
    ENV.fetch('KARAOKE_QA_PERFORMER_EMAIL', 'jared.harbison+performer@gmail.com'), qa_password
  )

  qa_venue = Venue.find_or_initialize_by(slug: '523-franklin-ave')
  qa_venue.update!(name: '523 Franklin Ave', location: '523 Franklin Ave', public: true, owner: qa_owner)
  qa_venue.add_host(qa_host)

  qa_event = qa_venue.events.find_or_initialize_by(name: 'Franklin Karaoke QA')
  qa_event.assign_attributes(
    starts_at: 1.hour.from_now,
    ends_at: 5.hours.from_now,
    status: :scheduled
  )
  qa_event.save!

  puts <<~MESSAGE
    Optional QA fixture:
      Venue:     523 Franklin Ave (/523-franklin-ave/events)
      Owner:     #{qa_owner.email}
      Host:      #{qa_host.email}
      Performer: #{qa_performer.email}
      Password:  supplied through KARAOKE_QA_PASSWORD (local only)
  MESSAGE
end
