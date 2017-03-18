require 'IMGKit'
require 'ERB'
require 'JSON'
require 'securerandom'

module SyncTemplate
  class TemplateParser
    attr_accessor :content

    def initialize content
      @content = JSON.parse content
      # Is this collision safe?  No.  Do I care?  Also no.
      @filename = SecureRandom.hex(13)
    end

    def render
      kit = IMGKit.new(compile_html, quality: 100, width: 810)
      kit.stylesheets << compile_css
      kit.to_file("images/#{@filename}.jpg")
    end

    private

    def compile_css
      # IMGKit can only take files as args, not strings
      stylesheet = File.open('template/template.css').read
      filename = "stylesheets/#{@filename}.css"
      File.open(filename, 'w') do |f|
        f.write(ERB.new(stylesheet).result(binding))
      end
      filename
    end

    def compile_html
      template = File.open('template/template.html').read
      ERB.new(template).result(binding)
    end
  end
end
