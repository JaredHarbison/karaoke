# frozen_string_literal: true

# Adds a client-held idempotency key for queue submissions.
class AddSongSubmissionTokens < ActiveRecord::Migration[7.2]
  def change
    add_column :songs, :submission_token, :string
    add_index :songs, :submission_token, unique: true, where: 'submission_token IS NOT NULL'
  end
end
