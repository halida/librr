#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
require 'sinatra'

set :port, 8112

get '/' do
  redirect to('/hello/World')
end

get '/hello/:name' do
  "Hello #{params[:name]}!"
end

get '/me' do
  "我的"
end
