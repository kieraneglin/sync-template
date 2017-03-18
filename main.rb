require 'IMGKit'

class SyncTemplate
  def initialize

  end

  def render
    html = File.open('template/template.html')
    kit = IMGKit.new(html.read, quality: 100, width: 810)
    kit.stylesheets << 'template/template.css'

    file = kit.to_file('images/file.jpg')
  end
end
