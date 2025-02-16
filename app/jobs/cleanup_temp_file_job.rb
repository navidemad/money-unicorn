# frozen_string_literal: true

class CleanupTempFileJob < ApplicationJob
  queue_as :default
  RETRY_WAIT_TIME = 5.minutes
  MAX_RETRY_ATTEMPTS = 3
  retry_on StandardError, wait: RETRY_WAIT_TIME, attempts: MAX_RETRY_ATTEMPTS

  def perform(file_path)
    return unless File.exist?(file_path)
    
    File.delete(file_path)
    Rails.logger.info("Successfully cleaned up temp file: #{file_path}")
  rescue StandardError => e
    Rails.logger.error("Failed to cleanup temp file #{file_path}: #{e.message}")
    raise # Allow retry mechanism to work
  end
end