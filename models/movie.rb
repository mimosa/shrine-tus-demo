# frozen_string_literal: true

require './config/sequel'
require './uploaders/application_uploader'
require './uploaders/video_uploader'

class Movie < Sequel::Model
  include VideoUploader::Attachment.new(:video)
end
