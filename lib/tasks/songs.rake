# frozen_string_literal: true

namespace :songs do
  desc 'Backfill missing queue titles from YouTube metadata'
  task backfill_titles: :environment do
    abort 'YOUTUBE_API_KEY is required to backfill song titles.' if ENV['YOUTUBE_API_KEY'].blank?

    result = SongTitleBackfill.call
    puts "Scanned #{result.scanned}; updated #{result.updated}; skipped #{result.skipped}."
  end
end
