require 'spec_helper'

RSpec.describe 'When testing for safeness of a buildpack' do
  context 'a Python app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'python')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'python', position: 1)

      manifest     = parsed_manifest(buildpack: 'python')
      python_version = manifest['dependencies'].find{ |d| d['name'] == 'python' }['version']

      template = PythonTemplateApp.new(python_version)
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end

  context 'a golang app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'go')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'go', position: 1)

      manifest     = parsed_manifest(buildpack: 'go')
      go_version = manifest['dependencies'].find{ |d| d['name'] == 'go' }['version']

      template = GoTemplateApp.new(go_version)
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end

  context 'a PHP app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'php')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'php', position: 1)

      manifest     = parsed_manifest(buildpack: 'php')
      php_version = manifest['dependencies'].find{ |d| d['name'] == 'php' }['version']
      nginx_version = manifest['dependencies'].find{ |d| d['name'] == 'nginx' }['version']

      template = PHPTemplateApp.new(
        runtime_version: php_version,
        web_server: 'nginx',
        web_server_version: nginx_version
      )
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end

  context 'a nodeJS app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'nodejs')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'nodejs', position: 1)

      manifest     = parsed_manifest(buildpack: 'nodejs')
      nodejs_version = manifest['dependencies'].find{ |d| d['name'] == 'node' }['version']

      template = NodeJSTemplateApp.new(nodejs_version)
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end

  context 'a staticfile app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'staticfile')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'staticfile', position: 1)

      template =StaticfileTemplateApp.new
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end

  end

  context 'a Ruby app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'ruby')
    end

    it 'will be safe' do
      install_buildpack(buildpack: 'ruby', position: 1)

      manifest     = parsed_manifest(buildpack: 'ruby')
      ruby_version = manifest['dependencies'].find{ |d| d['name'] == 'ruby' }['version']

      template = RubyTemplateApp.new(ruby_version)
      template.generate!

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end

  context 'a Java app' do
    after do
      Machete::CF::DeleteApp.new.execute(@app)
      cleanup_buildpack(buildpack: 'java')
    end

    it 'will be safe' do
      install_java_buildpack(position: 1)
      template = JavaTemplateApp.new

      @app = Machete.deploy_app(
        template.path,
        name: template.name,
        service: true
      )

      expect(@app).to be_running
      expect(template.name).to be_safe
    end
  end
end
