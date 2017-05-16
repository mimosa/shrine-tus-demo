# frozen_string_literal: true

require './config/shrine'
require 'mini_magick'
require 'streamio-ffmpeg'

class VideoUploader < Shrine
  storages[:cache] = storages[:tus]

  plugin :add_metadata
  plugin :processing
  plugin :versions   # enable Shrine to handle a hash of files
  plugin :delete_raw # delete processed files after uploading

  add_metadata do |io, _context|
    case File.extname(io.path)
    when '.mp4'
      movie = FFMPEG::Movie.new(io.path)

      {
        duration:  movie.duration,
        fps:       movie.frame_rate,
        width:     movie.width,
        height:    movie.height,
        mime_type: 'video/mp4',
      }
    when '.jpg'
      image = MiniMagick::Image.open(io.path)

      {
        width:     image[:width],
        height:    image[:height],
        mime_type: image[:mime_type],
      }
    end
  end

  process(:store) do |io, _context|
    case io.mime_type
    when /video/
      raw_file   = io.download
      video      = Tempfile.new(['video', '.mp4'], binmode: true)
      screenshot = Tempfile.new(['screenshot', '.jpg'], binmode: true)

      movie = FFMPEG::Movie.new(raw_file.path)

      options = {
        video_codec: 'libx264',
        audio_codec: 'libmp3lame',
        video_bitrate: 1300,
        video_max_bitrate: 500,
        audio_bitrate: 32,
        audio_sample_rate: '22050',
        resolution: '400x400',
      }

      movie.transcode(video.path, options, preserve_aspect_ratio: :width)

      raw_file.delete

      movie = FFMPEG::Movie.new(video.path)
      movie.screenshot(screenshot.path, seek_time: 5, custom: %w[-an])

      {
        original: video,
        thumb: screenshot,
      }
    end
  end

  private

  def generate_location(io, context)
    type  = context[:record].class.name.downcase if context[:record]
    style = context[:version] == :video ? 'videos' : 'screenshots' if context[:version]
    name  = super # the default unique identifier

    [type, style, name].compact.join('/')
  end
end
