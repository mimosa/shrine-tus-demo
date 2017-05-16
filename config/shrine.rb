# frozen_string_literal: true

require './jobs/shrine_job'
require 'dotenv'
require 'shrine'
require 'shrine/storage/s3'
require 'shrine/storage/tus'
require 'shrine/storage/url'

Dotenv.load

s3_options = {
  endpoint:          ENV.fetch('S3_ENDPOINT') { 'https://play.minio.io:9000' },
  access_key_id:     ENV.fetch('AWS_ACCESS_KEY_ID') { 'Q3AM3UQ867SPQQA43P2F' },
  secret_access_key: ENV.fetch('AWS_SECRET_ACCESS_KEY') { 'zuf+tfteSlswRu7BJ86wekitnifILbZam1KYY3TG' },
  force_path_style:  true,
  region:            ENV.fetch('S3_REGION') { 'us-east-1' },
  bucket: ENV.fetch('AWS_REGION') { 'testbucket' },
  upload_options: {
    acl: ENV.fetch('AWS_PERMISSION') { 'public-read' }
  }
}

Shrine.storages = {
  cache: Shrine::Storage::S3.new(s3_options), # not used for tus
  store: Shrine::Storage::S3.new(s3_options),
  tus:   Shrine::Storage::Tus.new(downloader: :down)
}

Shrine.plugin :sequel
Shrine.plugin :logging
Shrine.plugin :backgrounding
Shrine.plugin :cached_attachment_data

Shrine::Attacher.promote do |data|
  ShrineJob.perform_async(:promote, data)
end

Shrine::Attacher.delete do |data|
  ShrineJob.perform_async(:delete, data)
end
