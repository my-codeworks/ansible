RAILS_ROOT = "/home/rails/sweplex/current"

God.watch do |w|
  pid_file = File.join(RAILS_ROOT, "tmp/pids/unicorn.pid")

  w.name = "unicorn"
  w.start = "bundle exec unicorn -Dc #{RAILS_ROOT}/config/unicorn.rb -E staging"
  w.stop = "kill -QUIT $(cat #{pid_file})"
  w.restart = "kill -USR2 $(cat #{pid_file})"

  w.stop_signal = 'QUIT'

  w.pid_file = pid_file

  w.behavior(:clean_pid_file)

  # When to start?
  w.start_if do |start|
    start.condition(:process_running) do |c|
      # We want to check if deamon is running every ten seconds
      # and start it if itsn't running
      c.interval = 10.seconds
      c.running = false
    end
  end

  # When to restart a running deamon?
  w.restart_if do |restart|
    restart.condition(:memory_usage) do |c|
      # Pick five memory usage at different times
      # if three of them are above memory limit (100Mb)
      # then we restart the deamon
      c.above = 100.megabytes
      c.times = [3, 5]
    end

    restart.condition(:cpu_usage) do |c|
      # Restart deamon if cpu usage goes
      # above 90% at least five times
      c.above = 90.percent
      c.times = 5
    end
  end

  # lifecycle
  w.lifecycle do |on|
    on.condition(:flapping) do |c|
      c.to_state = [:start, :restart]
      c.times = 5
      c.within = 5.minute
      c.transition = :unmonitored
      c.retry_in = 10.minutes
      c.retry_times = 5
      c.retry_within = 2.hours
    end
  end
end