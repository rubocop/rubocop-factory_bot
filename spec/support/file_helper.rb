# frozen_string_literal: true

require 'fileutils'

module FileHelper
  def create_file(file_path, content)
    file_path = File.expand_path(file_path)
    dir_path = File.dirname(file_path)
    FileUtils.mkdir_p dir_path
    File.open(file_path, 'w') do |file|
      if content.is_a?(String)
        file.puts content
      elsif content.is_a?(Array)
        file.puts content.join("\n")
      end
    end
  end

  # rubocop:disable InternalAffairs/CreateEmptyFile
  def create_empty_file(file_path)
    create_file(file_path, '')
  end
  # rubocop:enable InternalAffairs/CreateEmptyFile
end
