require_relative '../spec_helper'

FIXTURE_DIR = "#{File.dirname(__FILE__)}/../fixtures/php/simple_brats"
OPTIONS_JSON = "#{FIXTURE_DIR}/.bp-config/options.json"

RSpec.shared_examples :a_deploy_of_php_app_to_cf do |php_runtime_binary, web_server_binary|

  php_runtime        = php_runtime_binary['name']
  runtime_version    = php_runtime_binary['version']
  web_server         = web_server_binary['name']
  web_server_version = web_server_binary['version']

  context "with #{php_runtime}-#{runtime_version} and web_server: #{web_server}-#{web_server_version}" do

    before :all do
      create_options_json({
        :php_runtime        => php_runtime,
        :runtime_version    => runtime_version,
        :web_server         => web_server,
        :web_server_version => web_server_version
      })
      @app = Machete.deploy_app('php/simple_brats', buildpack: 'php-brat-buildpack')
      @browser = Machete::Browser.new(@app)
    end

    it 'should be running' do
      expect(@app).to be_running
      2.times do
        @browser.visit_path('/')
        expect(@browser).to have_body('Hello World!')
      end
    end

    it 'should have the correct version' do
      expect(@app).to have_logged("Installing #{php_runtime.upcase}")
      expect(@app).to have_logged("#{php_runtime.upcase} #{runtime_version}")
    end

    it 'should not have internet traffic with a cached buildpack' do
      expect(@app.host).not_to have_internet_traffic if Machete::BuildpackMode.offline?
    end

    after :all do
      FileUtils.rm OPTIONS_JSON
    end
  end
end

describe 'Deploying CF apps' do

  binaries = YAML.load(
    open('https://raw.githubusercontent.com/cloudfoundry/php-buildpack/master/manifest.yml').read
  )['dependencies']

  valid_php_runtimes = ['php', 'hhvm']
  valid_web_servers  = ['httpd', 'nginx']
  php_runtimes       = binaries.select {|binary| valid_php_runtimes.include?(binary['name']) }
  web_servers        = binaries.select {|binary| valid_web_servers.include?(binary['name']) }

  ['lucid64', 'cflinuxfs2'].each do |stack|
    context "on the #{stack} stack" do

      before :all do
        ENV['CF_STACK'] = stack
      end

      php_runtimes.select { |php_runtime|
        php_runtime['cf_stacks'].include?(stack)
      }.each do |php_runtime|

        web_servers.select {|web_server|
          web_server['cf_stacks'].include?(stack)
        }.each do |web_server|

          it_behaves_like :a_deploy_of_php_app_to_cf, php_runtime, web_server
        end
      end
    end
  end
end

def create_options_json(options = {})
  php_vm             = options[:php_runtime]
  runtime_version    = options[:runtime_version]
  web_server         = options[:web_server]
  web_server_version = options[:web_server_version]

  options = {
    'PHP_VM' => php_vm,
    "#{php_vm.upcase}_VERSION" => runtime_version,
    'WEB_SERVER' => web_server,
    "#{web_server.upcase}_VERSION" => web_server_version
  }

  File.open(OPTIONS_JSON, 'w') do |file|
    file << JSON.generate(options)
  end
end
