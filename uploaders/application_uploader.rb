# frozen_string_literal: true

require './config/shrine'

class ApplicationUploader < Shrine
  plugin :add_metadata
  plugin :delete_raw, storages: [:cache] # delete processed files after uploading
  plugin :hooks
  plugin :processing
  plugin :versions # enable Shrine to handle a hash of files
end
