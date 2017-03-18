##########################################################
# Until basic classes are finished, this is for testing. #
# This will be the main loop that interacts with reddit. #
##########################################################

require_relative 'sync-template/template-parser'
require_relative 'sync-template/imgur-uploader'

content = '{ "name": "Peachy",
  "primary_color": "#b95289",
  "accent_color": "#FFFFFF",
  "highlight_color": "#59c99d",
  "primary_text_color": "#697c8f",
  "secondary_text_color": "#8d8d8d",
  "window_color": "#e4e4e4",
  "content_color": "#ffffff",
  "auto_subreddit_themes": false }'

s = SyncTemplate::TemplateParser.new content
puts s.render.path


# puts SyncTemplate::ImgurUploader.upload_template "/Users/Kieran/Documents/Programming/redditsync/images/4fb6ca2836f406c7d6bd0eb316.jpg"
