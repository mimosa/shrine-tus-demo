# frozen_string_literal: true

require 'mini_magick'
require 'streamio-ffmpeg'
require './workers/message_bus_worker'
require 'active_support'
require 'active_support/core_ext'

MiniMagick.configure do |c|
  c.shell_api = 'posix-spawn'
  c.timeout = 5
  c.validate_on_create = false
  c.validate_on_write = false
end

class VideoUploader < ApplicationUploader
  add_metadata do |io, context|
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
        mime_type: 'image/jpeg',
      }
    end
  end

  process(:store) do |io, context|
    raw_file = io.download
    versions = {}

    case io.mime_type
    when /video/, /gif/
      versions[:original] = transcode_processing(raw_file, io.mime_type, true)
      versions[:thumb]    = screenshot_processing(versions[:original])
    when /image/
      image = MiniMagick::Image.open(raw_file.path)
      image.format 'jpg'

      { # versions
        original: original,
        thumb: thumb,
      }
    end

    versions.assert_valid_keys(:original, :thumb)
    versions
  end

  def around_store(_io, context)
    result = super
    data = {
      id:     context[:record].id,
      name:   context[:record].name,
      src:    result[:original].url,
      poster: result[:thumb].url,
      type:   result[:original].mime_type,
      width:  result[:original].metadata['width'],
      height: result[:original].metadata['height'],
    }

    MessageBusWorker.perform_async('/movies', data)

    result
  end

  private

  VIDEO_OPTIONS =
    {
      video: {
        resolution: '400x400',
        video_bitrate: 1300,
        video_codec: 'libx264',
        video_max_bitrate: 500,
      },
      audio: {
        audio_bitrate: 32,
        audio_codec: 'aac',
        audio_sample_rate: '22050',
      },
    }.freeze

  def generate_location(io, context)
    name  = super # the default unique identifier
    type  = context[:record].class.name.downcase
    style =
      case context[:version]
      when :original
        'video'
      when :thumb
        'screenshot'
      end

    [type, name[0..-5], "#{style}#{name[-4..-1]}"].compact.join('/')
  end

  def transcode_processing(raw_file, mime_type, unlink = false)
    movie   = FFMPEG::Movie.new(raw_file.path)
    video   = Tempfile.new(['video', '.mp4'], binmode: true)
    options = VIDEO_OPTIONS[:video].merge(
      mime_type.match?(%r{image}) ? { custom: %w[-an -pix_fmt yuv420p] } : VIDEO_OPTIONS[:audio]
    )
    movie.transcode(video.path, options, preserve_aspect_ratio: :width)
    raw_file.delete if unlink
    video
  end

  def screenshot_processing(raw_file)
    movie      = FFMPEG::Movie.new(raw_file.path)
    screenshot = Tempfile.new(['screenshot', '.jpg'], binmode: true)
    movie.screenshot(screenshot.path, seek_time: movie.duration > 600 ? 120 : movie.duration.to_i, custom: %w[-an])
    screenshot
  end
end
