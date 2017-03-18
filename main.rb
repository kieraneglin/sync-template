require_relative 'sync-template/reddit-client'

r = SyncTemplate::RedditClient.new
r.monitor_posts 'SyncTemplateTest'
