require './config/environment'
require './app/models/user'
class ApplicationController < Sinatra::Base
  configure do
    set :views, 'app/views'
    enable :sessions
    set :session_secret, 'password_security'
  end

  get '/' do
    erb :index
  end

  get '/signup' do
    session.clear if logged_in?
    erb :signup
  end

  post '/signup' do
    if (params[:username].nil? || params[:username] == '') || (params[:password].nil? || params[:password] == '')
      redirect '/failure'
    else
      user = User.new(username: params[:username], password: params[:password])
      if user.save
        session[:user_id] = user.id
        redirect '/login'
      else
        redirect '/failure'
      end
    end
  end

  get '/account' do
    @user = current_user
    erb :account
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    user = User.find_by_username(params[:username])
    if !user.nil? && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get '/failure' do
    erb :failure
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  post '/account' do
    user = current_user
    deposit = params[:deposit].to_f || 0.0
    withdraw = params[:withdraw].to_f || 0.0
    amount = deposit - withdraw
    new_balance = (user.balance + amount).to_f.round(2)
    user.update_column(:balance, new_balance) if new_balance >= 0.0
    redirect '/account'
  end

  helpers do
    def logged_in?
      !session[:user_id].nil?
    end

    def current_user
      User.find_by_id(session[:user_id])
    end
  end
end
