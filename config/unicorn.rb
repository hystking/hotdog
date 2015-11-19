require "yaml"

# ROOT
RAILS_ROOT = File.expand_path(File.dirname(__FILE__) + "/..") unless defined?(RAILS_ROOT)
# RAILS ENV
RAILS_ENV = ENV['RAILS_ENV'] || 'development'

CONFIG = YAML.load_file(RAILS_ROOT + "/config/unicorn.yml")[RAILS_ENV]

puts 'env:' + RAILS_ENV
puts 'dir:' + ENV['RAILS_RELATIVE_URL_ROOT'].to_s

worker_processes CONFIG['worker_processes']
working_directory RAILS_ROOT
timeout CONFIG['timeout']

preload_app CONFIG['preload']

pid         File.join(RAILS_ROOT, CONFIG['pid'])
stdout_path File.join(RAILS_ROOT, CONFIG['log']['out'])
stderr_path File.join(RAILS_ROOT, CONFIG['log']['err'])
listen      File.join(RAILS_ROOT, CONFIG['socket']['file']), backlog: CONFIG['socket']['backlog']

# For RubyEnterpriseEdition: http://www.rubyenterpriseedition.com/faq.html#adapt_apps_for_cow
if GC.respond_to?(:copy_on_write_friendly=)
  GC.copy_on_write_friendly = true
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  old_pid = RAILS_ROOT + '/tmp/pids/unicorn.pid.oldbin'

  if File.exists?(old_pid) && server.pid != old_pid
    begin
      # 古いマスターがいたら死んでもらう
      Process.kill("QUIT", File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # someone else did our job for us
    end
  end
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection
end

