preload_app!

threads ENV.fetch('PUMA_MIN_THREADS_PER_WORKER', 0).to_i,
        ENV.fetch('PUMA_MAX_THREADS_PER_WORKER', 8).to_i

workers ENV.fetch('PUMA_WORKERS', 1).to_i

on_worker_boot do
  ActiveSupport.on_load(:active_record) do
    ActiveRecord::Base.establish_connection
  end
end
