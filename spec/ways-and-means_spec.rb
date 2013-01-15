# encoding: utf-8

require 'spec_helper'

describe Sinatra::WaysAndMeans do

  let(:browser) { Rack::Test::Session.new(Rack::MockSession.new(WaysAndMeansTester)) }

  describe "routes" do
    it "should not respond to /" do
      browser.get '/'
      browser.last_response.status.should == 404
    end

    it "should respond to GET /here" do
      browser.get '/here'
      browser.last_response.body.should == 'here'
      WaysAndMeansTester.settings.hook.should == 'before_here'
    end

    it "should respond to POST /there" do
      browser.post '/there'
      browser.last_response.body.should == 'post_there'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should respond to PATCH /there" do
      browser.patch '/there'
      browser.last_response.body.should == 'patch_there'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should respond to GET /index" do
      browser.get '/index'
      browser.last_response.body.should == 'show_index'
      WaysAndMeansTester.settings.hook.should == 'after_show_index'
    end

    it "should respond to POST /list" do
      browser.post '/list'
      browser.last_response.body.should == 'post_list'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should respond to GET /show/:person_id" do
      browser.get '/show/42'
      browser.last_response.body.should == 'show_person'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

  end

  describe 'settings' do
    it 'should gather settings' do
      WaysAndMeansTester.settings.location.should == 'plop'
      WaysAndMeansTester.settings.respond_to?(:ways).should be_false
    end 
  end
end
