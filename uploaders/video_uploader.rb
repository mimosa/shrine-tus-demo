# frozen_string_literal: true

require 'mini_magick'
require 'streamio-ffmpeg'
require './jobs/message_bus_job'

class VideoUploader < ApplicationUploader
  add_metadata do |io, _context|
    case File.extname(io.path)
    when '.mp4', '.3gp', '.ogv', '.webm'
      movie = FFMPEG::Movie.new(io.path)

      {
        duration:  movie.duration,
        fps:       movie.frame_rate,
        width:     movie.width,
        height:    movie.height,
        mime_type: 'video/mp4',
        label:     'video',
      }
    when '.jpg', '.png', '.jpeg', '.gif'
      image = MiniMagick::Image.open(io.path)
      label = image.frames.size > 1 ? 'video' : 'image'

      {
        width:     image[:width],
        height:    image[:height],
        mime_type: image[:mime_type],
        label:     label,
      }
    end
  end

  process(:store) do |io, _context|
    raw_file = io.download
    case io.mime_type
    when /video/, /gif/
      movie      = FFMPEG::Movie.new(raw_file.path)
      video      = Tempfile.new(['video', '.mp4'], binmode: true)
      screenshot = Tempfile.new(['screenshot', '.jpg'], binmode: true)
      options    = VIDEO_OPTIONS[:video].merge(
        io.mime_type.match?(%r{image}) ? { custom: %w[-an -pix_fmt yuv420p] } : VIDEO_OPTIONS[:audio]
      )
      movie.transcode(video.path, options, preserve_aspect_ratio: :width)
      raw_file.delete
      movie = FFMPEG::Movie.new(video.path)
      movie.screenshot(screenshot.path, seek_time: movie.duration > 600 ? 120 : movie.duration.to_i, custom: %w[-an])

      { # versions
        original: video,
        thumb: screenshot,
      }
    end
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

    MessageBusJob.perform_async('/movies', data)

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
end
