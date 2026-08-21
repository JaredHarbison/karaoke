# This file creates local development records for manual feature testing.
# It is intentionally a no-op in test and production environments.
#
return unless Rails.env.development?

password = 'KaraokeDemo123!'

owner = User.find_or_create_by!(email: 'owner@karaoke.test') do |user|
  user.password = password
  user.password_confirmation = password
end
owner.update!(password: password, password_confirmation: password)

host = User.find_or_create_by!(email: 'host@karaoke.test') do |user|
  user.password = password
  user.password_confirmation = password
end
host.update!(password: password, password_confirmation: password)

performer = User.find_or_create_by!(email: 'performer@karaoke.test') do |user|
  user.password = password
  user.password_confirmation = password
end
performer.update!(password: password, password_confirmation: password)

performer_demo = User.find_or_create_by!(email: 'performer.demo@karaoke.test') do |user|
  user.password = password
  user.password_confirmation = password
end
performer_demo.update!(password: password, password_confirmation: password)

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
  venue.songs.find_or_create_by!(performer: performer_name, url: url) do |song|
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
