# frozen_string_literal: true

require 'byebug'
require 'sinatra/base'
require 'sinatra/contrib'
require 'sinatra/partial'
require './models/movie'

class App < Sinatra::Base
  register Sinatra::Contrib
  register Sinatra::Partial

  enable :static, :logging, :partial_underscores
  set :public_folder, Proc.new { File.join(root, 'public') }
  set :views, Proc.new { File.join(root, 'views') }
  set :partial_template_engine, :erb
  set :run, false

  helpers Sinatra::RequiredParams

  helpers do
    def params
      @params ||= super
    end
  end  

  before :method => :post do
    if request.content_type == 'application/json'
      params.merge!(
        MultiJson.load(request.body.read, symbolize_keys: true)
      )
    end
  end

  get '/' do
    redirect '/movies'
  end

  post '/write' do
    params[:MetaData][:content_type] =~ %r{video|image} ? '0' : '1'
  end

  post '/publish' do
    MessageBusWorker.perform_async(
      params[:channel] ||'notifications',
      params[:message]
    )

    'Done'
  end

  namespace '/movies' do
    get do
      @movies = Movie.all

      erb :'movies/index'
    end
  
    post do
      required_params movie: %i[name video]
    
      @movie = Movie.create(params[:movie])

      redirect '/movies'
    end

    namespace '/:id' do
      before do
        if params[:id].present?
          @movie = params[:id] == 'new' ? Movie.new : Movie[params[:id]]
        end
      end

      get do
        erb :'movies/new'
      end

      put do
        @movie.update(params[:movie])
        redirect '/movies'
      end
    
      delete do
        @movie.destroy
        redirect '/movies'
      end
    
      get '/edit' do
        erb :'movies/edit'
      end
    end
  end
end
