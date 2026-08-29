# frozen_string_literal: true

require 'rails_helper'

RSpec.describe YoutubeService, type: :service do
  describe '.search' do
    it 'asks YouTube to return only embeddable videos' do
      stub_const('YoutubeService::API_KEY', 'test-key')
      response = instance_double(Net::HTTPSuccess, body: { items: [] }.to_json)
      allow(response).to receive(:is_a?).with(Net::HTTPSuccess).and_return(true)
      requested_uri = nil

      allow(described_class).to receive(:make_request) do |uri|
        requested_uri = uri
        response
      end

      described_class.search('Dolly Parton karaoke')

      expect(CGI.parse(requested_uri.query)).to include('videoEmbeddable' => ['true'])
    end
  end
end
