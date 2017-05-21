# frozen_string_literal: true

require './config/sequel'
require './config/message_bus'
require './uploaders/video_uploader'

Sequel::Model.plugin :dirty

class Movie < Sequel::Model
  include VideoUploader::Attachment.new(:video)
end
