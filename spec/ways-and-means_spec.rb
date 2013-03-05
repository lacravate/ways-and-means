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
      browser.last_response.status.should_not >= 400
    end

    it "should respond to GET /where" do
      browser.get '/where'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to POST /there" do
      browser.post '/there'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to PATCH /there" do
      browser.patch '/there'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to GET /index" do
      browser.get '/index'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to POST /list" do
      browser.post '/list'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to GET /show/:person_id" do
      browser.get '/show/42'
      browser.last_response.status.should_not >= 400
    end
  end

  describe "output" do
    it "should have the right response to GET /here" do
      browser.get '/here'
      browser.last_response.body.should == 'here'
      WaysAndMeansTester.settings.hook.should == 'before_here'
    end

    it "should have the right response to GET /where" do
      browser.get '/where'
      browser.last_response.body.should == 'i rendered where'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should have the right response to POST /there" do
      browser.post '/there'
      browser.last_response.body.should == 'i rendered post_there'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should have the right response to PATCH /there" do
      browser.patch '/there'
      browser.last_response.body.should == 'patch_there'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should have the right response to GET /index" do
      browser.get '/index'
      browser.last_response.body.should == 'show_index'
      WaysAndMeansTester.settings.hook.should == 'after_show_index'
    end

    it "should have the right response to POST /list" do
      browser.post '/list'
      browser.last_response.body.should == 'post_list'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should have the right response to GET /show/:person_id" do
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

  describe 'renderer' do
    it 'should define methods where renderer is called' do
      WaysAndMeansTester.instance_methods.should include(:where)
      WaysAndMeansTester.instance_methods.should include(:post_there)
    end
  end

  describe 'clean endpoints' do
    let(:routes_array) { [ 'browse', 'browse/*', 'show/*', 'read/*', :plop, 'plip/plap/?', 'show/:resource_id' ] }

    it "should build a set of routes/endpoints from an array" do
      WaysAndMeansTester.ways_and_means! ways: routes_array do |endpoint, dispatch|
        [ 'show_resource', 'plop', 'plip_plap', 'browse', 'show', 'read' ].include?(dispatch[:to]).should be_true
      end
    end
  end
end
