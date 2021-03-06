# encoding: utf-8

require 'spec_helper'

describe Sinatra::WaysAndMeans do

  let(:ways_and_means) {
    {
      # routes
      ways: {
        # get /here => here, get is implicit
        here: nil,

        there: {
          # post /there => post_there
          post: { to: 'post_there', renderer: :my_renderer },
          # patch /there => patch_there
          patch: { to: 'patch_there' }
        },

        where: { renderer: :my_renderer },

        hither: [:put, :head],

        # get /index => show_indew, get is implicit
        index: { to: 'show_index' },

        # post /list => post_list
        list: { to: 'post_list', verb: 'post' },

        # get /show/42 => show_person
        'show/:person_id' => "show_person"
      },

      means: {
        # conf
        location: 'plop'
      },

      defaults: { renderer: :primary_renderer }
    }
  }

  let(:dsl) { ways_and_means }

  before {
    WaysAndMeansTester.ways.clear if WaysAndMeansTester.ways
    WaysAndMeansTester.conf = dsl
    WaysAndMeansTester.setup
  }

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

    it "should respond to PUT /hither" do
      browser.put '/hither'
      browser.last_response.status.should_not >= 400
    end

    it "should respond to HEAD /hither" do
      browser.head '/hither'
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
      browser.post '/there', locals: true
      browser.last_response.body.should == 'i rendered post_there with args'
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

    it "should have the right response to PUT /hither" do
      browser.put '/hither'
      browser.last_response.body.should == 'put_hither'
      WaysAndMeansTester.settings.hook.should == 'hook'
    end

    it "should have the right response to HEAD /hither" do
      browser.head '/hither'
      browser.last_response.body.should == ''
      WaysAndMeansTester.settings.hook.should == 'hook'
    end
  end

  describe 'ways' do
    it "should give a list of the set routes" do
      [
        [:here,             {verb: "get",   to: "here",        renderer: :primary_renderer } ],
        [:there,            {verb: "post",  to: "post_there",  renderer: :my_renderer}       ],
        [:there,            {verb: "patch", to: "patch_there", renderer: :primary_renderer}  ],
        [:where,            {verb: "get",   to: "where",       renderer: :my_renderer}       ],
        [:hither,           {verb: "put",   to: "put_hither",  renderer: :primary_renderer}  ],
        [:hither,           {verb: "head",  to: "head_hither", renderer: :primary_renderer}  ],
        [:index,            {verb: "get",   to: "show_index",  renderer: :primary_renderer}  ],
        [:list,             {verb: "post",  to: "post_list",   renderer: :primary_renderer}  ],
        ["show/:person_id", {verb: "get",   to: "show_person", renderer: :primary_renderer}  ]
      ].all? do |dispatch|
        WaysAndMeansTester.ways.should include(dispatch)
      end
    end
  end

  describe 'settings' do
    it 'should gather settings' do
      WaysAndMeansTester.settings.location.should == 'plop'
    end
  end

  describe 'renderer' do
    it 'should define methods where renderer is called' do
      WaysAndMeansTester.instance_methods.should include(:where)
      WaysAndMeansTester.instance_methods.should include(:post_there)
    end
  end

  describe 'clean endpoints and make_way' do
    let(:routes_array) { [ 'browse', 'browse/*', 'show/*', 'read/*', :plop, 'plip/plap/?', 'show/:resource_id' ] }
    let(:clean_endpoints) { [ 'show_resource', 'plop', 'plip_plap', 'browse', 'show', 'read' ] }

    it "should build a set of routes/endpoints from an array" do
      WaysAndMeansTester.ways_and_means! ways: routes_array, make_way: true do |endpoint, dispatch|
        clean_endpoints.include?(dispatch[:to]).should be_true
      end

      WaysAndMeansTester.ways_and_means! ways: { bim: [:post] }, make_way: true do |endpoint, dispatch|
        dispatch[:to].should == 'post_bim'
      end

      WaysAndMeansTester.new!.post_bim_url('plawp').should == '/bim/plawp'

      clean_endpoints.each do |clean|
        WaysAndMeansTester.instance_methods.should include("#{clean}_url".to_sym)
      end
    end
  end

  describe "DSL" do
    let(:config_file) { Pathstring.join 'config', 'ways-and-means.yml' }

    context "explicit DSL" do
      it "should get config from file and hash" do
        config_file.save! YAML.dump({ means: { plap: "plip" } })
        WaysAndMeansTester.ways.clear if WaysAndMeansTester.ways
        WaysAndMeansTester.ways_and_means!({file: true}, ways_and_means)

        WaysAndMeansTester.settings.location.should == 'plop'
        WaysAndMeansTester.settings.plap.should == 'plip'
        WaysAndMeansTester.ways.size.should == 9
      end
    end

    context "implicit DSL" do
      it "should get config from file only" do
        config_file.save! YAML.dump({ means: { plap: "plip" } })
        WaysAndMeansTester.ways.clear if WaysAndMeansTester.ways
        WaysAndMeansTester.ways_and_means!

        WaysAndMeansTester.settings.location.should == 'plop'
        WaysAndMeansTester.settings.plap.should == 'plip'
        WaysAndMeansTester.ways.size.should == 0
      end
    end

    after {
      config_file.delete if config_file.exist?
    }
  end

end
