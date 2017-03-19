require 'IMGKit'
require 'ERB'
require 'JSON'
require 'securerandom'
require 'color'

module SyncTemplate
  class TemplateParser
    attr_accessor :content, :name

    def initialize(content)
      @content = JSON.parse content
      @content['pencil'] = pencil_colour
      @name = @content['name']
      # Is this collision safe?  No.  Do I care?  Also no.
      @filename = SecureRandom.hex(13)
    end

    def render
      kit = IMGKit.new(compile_html, quality: 100, width: 810)
      kit.stylesheets.push(compile_css)
      kit.to_file("images/#{@filename}.jpg")
      File.join(Dir.pwd, 'images', "#{@filename}.jpg")
    end

    def cleanup
      File.delete(File.join(Dir.pwd, 'images', "#{@filename}.jpg"))
      File.delete(File.join(Dir.pwd, 'stylesheets', "#{@filename}.css"))
    end

    private

    def pencil_colour
      # Uses same algo as ljdawson to calculate brightness, but this is inverse
      # So we have to compare against 0.8 instead of 0.2
      brightness = Color::RGB.from_html(@content['accent_color']).brightness
      brightness < 0.8 ? '#FFFFFF' : '#000000'
    end

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
