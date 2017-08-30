# frozen_string_literal: true

require './jobs/shrine_job'
require 'dotenv'
require 'shrine'
require 'shrine/storage/s3'
require 'shrine/storage/tus'

Dotenv.load

s3_options = {
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID') { 'Q3AM3UQ867SPQQA43P2F' },
  bucket:            ENV.fetch('S3_BUCKET') { 'testbucket' },
  endpoint:          ENV.fetch('S3_ENDPOINT') { 'https://play.minio.io:9000' },
  force_path_style:  true,
  region:            ENV.fetch('AWS_REGION') { 'us-east-1' },
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY') { 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG' },
  upload_options: {
    acl:             ENV.fetch('AWS_PERMISSION') { 'public-read' },
  },
}

Shrine.storages = {
  cache: Shrine::Storage::Tus.new(downloader: :wget),
  store: Shrine::Storage::S3.new(s3_options),
}

Shrine.plugin :backgrounding
Shrine.plugin :cached_attachment_data
Shrine.plugin :determine_mime_type
Shrine.plugin :logging
Shrine.plugin :sequel

Shrine::Attacher.promote do |data|
  ShrineJob.perform_async(:promote, data)
end

Shrine::Attacher.delete do |data|
  ShrineJob.perform_async(:delete, data)
end
