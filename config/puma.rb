max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Bind to Unix socket in production, TCP in development
if ENV.fetch("RAILS_ENV", "development") == "production"
  bind "unix:///home/deploy/apps/eloy-back-timer/tmp/sockets/puma.sock"
else
  port ENV.fetch("PORT", 3000)
end

environment ENV.fetch("RAILS_ENV", "development")

workers ENV.fetch("WEB_CONCURRENCY", 1).to_i

preload_app! if ENV.fetch("RAILS_ENV", "development") == "production"

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

plugin :tmp_restart
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# Puma worker lifecycle hooks (only relevant with workers > 0)
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end
