require 'net/http'
require 'json'

class YoutubeService
  API_KEY = ENV['YOUTUBE_API_KEY']
  BASE_URL = 'https://www.googleapis.com/youtube/v3'
  
  def self.search(query, max_results: 10)
    return { error: 'YouTube API key not configured' } unless API_KEY.present?
    
    # Append "karaoke" to search to prioritize karaoke videos
    search_query = "#{query} karaoke"
    
    url = URI("#{BASE_URL}/search")
    params = {
      part: 'snippet',
      q: search_query,
      type: 'video',
      maxResults: max_results,
      key: API_KEY,
      videoDefinition: 'any',
      videoEmbeddable: 'true'
    }
    url.query = URI.encode_www_form(params)
    
    response = make_request(url)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      format_search_results(data)
    else
      { error: 'Failed to fetch YouTube results' }
    end
  rescue => e
    { error: e.message }
  end
  
  def self.get_video_details(video_id)
    return { error: 'YouTube API key not configured' } unless API_KEY.present?
    
    url = URI("#{BASE_URL}/videos")
    params = {
      part: 'snippet,contentDetails',
      id: video_id,
      key: API_KEY
    }
    url.query = URI.encode_www_form(params)
    
    response = make_request(url)
    
    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      data['items'].first if data['items'].any?
    else
      { error: 'Failed to fetch video details' }
    end
  rescue => e
    { error: e.message }
  end
  
  def self.extract_video_id(url)
    # Handle various YouTube URL formats
    patterns = [
      /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\?\/]+)/,
      /^([a-zA-Z0-9_-]{11})$/ # Direct video ID
    ]
    
    patterns.each do |pattern|
      match = url.match(pattern)
      return match[1] if match
    end
    
    nil
  end
  
  def self.build_embed_url(video_id)
    "https://www.youtube.com/embed/#{video_id}"
  end
  
  def self.build_watch_url(video_id)
    "https://www.youtube.com/watch?v=#{video_id}"
  end
  
  def self.validate_karaoke_video(video_id_or_url)
    video_id = extract_video_id(video_id_or_url)
    return { valid: false, error: 'Invalid YouTube URL or video ID' } unless video_id
    
    video = get_video_details(video_id)
    return { valid: false, error: 'Video not found' } unless video && !video.key?('error')
    
    title = video.dig('snippet', 'title')&.downcase || ''
    description = video.dig('snippet', 'description')&.downcase || ''
    
    has_karaoke = title.include?('karaoke') || description.include?('karaoke')
    has_lyrics = title.include?('lyrics') || title.include?('lyric') || description.include?('lyrics')
    
    {
      valid: has_karaoke || has_lyrics,
      video_id: video_id,
      title: video.dig('snippet', 'title'),
      has_karaoke: has_karaoke,
      has_lyrics: has_lyrics,
      thumbnail: video.dig('snippet', 'thumbnails', 'medium', 'url')
    }
  end
  
  private
  
  def self.make_request(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    
    # In development, skip SSL verification (you can also set ENV variable)
    if Rails.env.development?
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    
    request = Net::HTTP::Get.new(url)
    http.request(request)
  end
  
  def self.format_search_results(data)
    return { items: [] } unless data['items']
    
    {
      items: data['items'].map do |item|
        {
          video_id: item.dig('id', 'videoId'),
          title: item.dig('snippet', 'title'),
          description: item.dig('snippet', 'description'),
          thumbnail: item.dig('snippet', 'thumbnails', 'medium', 'url'),
          channel: item.dig('snippet', 'channelTitle'),
          url: build_watch_url(item.dig('id', 'videoId'))
        }
      end
    }
  end
end
