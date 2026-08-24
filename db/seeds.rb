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
venue.update!(name: 'Demo Karaoke', public: true, owner: owner, time_zone: 'America/New_York')
venue.add_host(host)

[
  ['Alex', 'Take On Me', 'https://www.youtube.com/watch?v=demo-alex', performer],
  ['Jamie', 'Dreams', 'https://www.youtube.com/watch?v=demo-jamie', performer]
].each do |performer_name, title, url, user|
  song = venue.performances.find_or_initialize_by(performer: performer_name, url: url)
  song.assign_attributes(user: user, category: 'pop', title: title)
  song.save!
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
  qa_venue.update!(
    name: '523 Franklin Ave', location: '523 Franklin Ave', public: true, owner: qa_owner,
    time_zone: 'America/New_York'
  )
  qa_venue.remove_host(qa_host)

  qa_event = qa_venue.events.find_or_initialize_by(name: 'Franklin Karaoke QA')
  qa_event.assign_attributes(
    starts_at: 1.hour.from_now,
    ends_at: 5.hours.from_now,
    status: :scheduled
  )
  qa_event.save!

  [
    ['QA Performer', 'Faithfully - Journey', 'https://www.youtube.com/watch?v=qa-performer-song', qa_performer],
    ['QA Guest', 'Dream On - Aerosmith', 'https://www.youtube.com/watch?v=qa-guest-song', nil]
  ].each do |performer_name, title, url, user|
    performance = qa_venue.performances.find_or_initialize_by(event: qa_event, performer: performer_name, url: url)
    performance.assign_attributes(user: user, category: 'qa', title: title)
    performance.save!
  end

  puts <<~MESSAGE
    Optional QA fixture:
      Venue:     523 Franklin Ave (/523-franklin-ave/events)
      Owner:     #{qa_owner.email}
      Host:      #{qa_host.email} (registered user; owner must add as host)
      Performer: #{qa_performer.email}
      Event:     Franklin Karaoke QA (scheduled; two pending queue entries)
      Password:  supplied through KARAOKE_QA_PASSWORD (local only)
  MESSAGE
end
