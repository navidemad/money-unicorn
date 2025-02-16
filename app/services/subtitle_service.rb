# frozen_string_literal: true
class SubtitleService
  MAX_CHAR_PER_LINE = 40

  def initialize(transcript)
    @transcript = transcript
  end

  def formatted_subtitles
    words = @transcript.split(' ')
    lines = []
    current_line = ''
    words.each do |word|
      if (current_line + ' ' + word).strip.length > MAX_CHAR_PER_LINE
        lines << current_line.strip
        current_line = word
      else
        current_line += ' ' + word
      end
    end
    lines << current_line.strip unless current_line.empty?
    lines
  end
end 