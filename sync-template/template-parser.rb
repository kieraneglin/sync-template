require 'IMGKit'
require 'ERB'
require 'JSON'
require 'securerandom'
require 'color'
require 'CGI'

module SyncTemplate
  class TemplateParser
    attr_accessor :content, :name

    def initialize(content)
      @content = clean_content(content)
      @content['pencil'] = item_colour(@content['accent_color'])
      @content['header_text'] = item_colour(@content['primary_color'])
      @name = @content['name']
      # Is this superfluous? Yes.
      @filename = SecureRandom.hex(13)
    end

    def render
      filepath = File.join(Dir.pwd, 'images', "#{@filename}.jpg")
      kit = IMGKit.new(compile_html, quality: 100, width: 810)
      kit.stylesheets.push(compile_css)
      kit.to_file(filepath)
      filepath
    end

    def cleanup
      File.delete(File.join(Dir.pwd, 'images', "#{@filename}.jpg"))
      File.delete(File.join(Dir.pwd, 'stylesheets', "#{@filename}.css"))
    end

    private

    def clean_content(content)
      content = JSON.parse(content)
      # Escape malicious HTML
      content.each do |_,str|
        str.replace CGI.escapeHTML(str) if str.is_a? String
      end
      content
    end

    def item_colour(item)
      # Uses same algo as ljdawson to calculate brightness, but this is inverse
      # So we have to compare against 0.8 instead of 0.2
      brightness = Color::RGB.from_html(item).brightness
      brightness < 0.8 ? '#FFFFFF' : '#000000'
    end

    def compile_css
      # IMGKit can only take files as args, not strings
      stylesheet = File.open(File.join('template', "template.css")).read
      filename = File.join(Dir.pwd, 'stylesheets', "#{@filename}.css")
      File.open(filename, 'w') do |f|
        f.write(ERB.new(stylesheet).result(binding))
      end
      filename
    end

    def compile_html
      template = File.open(File.join('template', "template.html")).read
      ERB.new(template).result(binding)
    end
  end
end
