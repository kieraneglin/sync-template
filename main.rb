require_relative 'sync-template'

content = '{ "name": "Peachy",
  "primary_color": "#b95289",
  "accent_color": "#fbb2b3",
  "highlight_color": "#59c99d",
  "primary_text_color": "#697c8f",
  "secondary_text_color": "#8d8d8d",
  "window_color": "#e4e4e4",
  "content_color": "#ffffff",
  "auto_subreddit_themes": false }'

s = SyncTemplate.new content
s.render

# puts s.compile_css
