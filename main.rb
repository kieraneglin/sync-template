require_relative 'sync-template/reddit-client'

loop do
  begin
    r = SyncTemplate::RedditClient.new
    r.monitor_posts 'redditsyncthemes'
  rescue Exception => e
    puts "The script exited unexpectedly: #{e}"
    sleep 10
  end
end
