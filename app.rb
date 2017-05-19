# frozen_string_literal: true

require 'roda'
require './models/movie'

class ShrineTusDemo < Roda
  plugin :public
  plugin :render
  plugin :partials
  plugin :assets, js: 'app.js', css: 'app.css'
  plugin :all_verbs
  plugin :indifferent_params

  route do |r| # rubocop:disable Metrics/BlockLength
    r.public # serve static assets
    r.assets # serve dynamic assets

    r.root do
      r.redirect '/movies'
    end

    r.post 'write' do
      if r.env['CONTENT_TYPE'] == 'application/json'
        params ||= MultiJson.load(r.env['rack.input'].read, symbolize_keys: true)
      end
      puts params
      puts '_' * 88 + r.env['HTTP_HOOK_NAME']

      if params[:MetaData][:content_type] =~ %r{^video}
        '0'
      else
        '1'
      end
    end

    r.on 'movies' do # rubocop:disable Metrics/BlockLength
      r.get true do
        @movies = Movie.all
        puts @movies[0].video unless @movies[0].nil?
        view('movies/index')
      end

      r.get 'new' do
        @movie = Movie.new
        view('movies/new')
      end

      r.post true do
        _movie = Movie.create(params[:movie])
        r.redirect '/movies'
      end

      r.on ':id' do |id|
        @movie = Movie[id]

        r.get 'edit' do
          view('movies/edit')
        end

        r.put do
          @movie.update(params[:movie])
          r.redirect '/movies'
        end

        r.delete do
          @movie.destroy
          r.redirect '/movies'
        end
      end
    end
  end
end
