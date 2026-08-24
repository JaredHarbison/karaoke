# frozen_string_literal: true

# Fills missing legacy queue titles from the provider without changing queue
# admission state or replacing titles that are already present.
class SongTitleBackfill
  Result = Struct.new(:scanned, :updated, :skipped, keyword_init: true)

  def self.call(scope: Performance.unscoped.where(title: nil))
    new(scope).call
  end

  def initialize(scope)
    @scope = scope
  end

  def call
    result = Result.new(scanned: 0, updated: 0, skipped: 0)

    @scope.where(title: nil).find_each { |performance| process(performance, result) }

    result
  end

  private

  def title_for(performance)
    metadata = YoutubeService.validate_karaoke_video(performance.url)
    return if metadata[:error] || metadata[:valid] == false

    metadata[:title].presence
  end

  def process(performance, result)
    result.scanned += 1
    title = title_for(performance)
    return result.skipped += 1 unless title

    performance.update!(title: title)
    result.updated += 1
  end
end
