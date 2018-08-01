# frozen_string_literal: true

require 'byebug'
require 'sinatra/base'
require 'sinatra/partial'
require './models/movie'

class App < Sinatra::Base
  register Sinatra::Partial
  enable :static, :logging, :partial_underscores
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :views, Proc.new { File.join(root, 'views') }
  set :partial_template_engine, :erb
  set :run, false

  before do
    @movie = Movie.find(params[:id]) unless params[:id].blank?
  end

  get '/' do
    redirect '/movies'
  end

  get '/movies' do
    @movies = Movie.all
    erb :'movies/index'
  end

  post '/movies' do
    @movie = Movie.create(params[:movie])
    redirect '/movies'
  end

  get '/movies/new' do
    @movie = Movie.new
    erb :'movies/new'
  end

  put '/movies/:id' do
    @movie.update(params[:movie])
    redirect '/movies'
  end

  delete '/movies/:id' do
    @movie.destroy
    redirect '/movies'
  end

  get '/movies/:id/edit' do
    erb :'movies/edit'
  end

  post '/write' do
    puts env
    puts '_' * 88
    if env['CONTENT_TYPE'] == 'application/json'
      params ||= MultiJson.load(env['rack.input'].read, symbolize_keys: true)
    end
    params[:MetaData][:content_type] =~ %r{^video} ? '0' : '1'
  end
end
