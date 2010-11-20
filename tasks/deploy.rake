require 'rake/contrib/sshpublisher'

namespace :deploy do
  SITE.user       = "maduyb@uiuc.us"
  SITE.host       = "bitfission.com"
  SITE.rsync_args = %w( -av --delete )

  task :staging => [:clobber, :build] do
    SITE.remote_dir = "/var/www/beta_blog"
    Rake::Task["deploy:rsync"].execute
    puts "\nDeployed to BETA"
  end

  task :production => [:build] do
    SITE.remote_dir = "/var/www/bitfission"
    Rake::Task["deploy:rsync"].execute
    puts "\nDeployed to PRODUCTION!"
  end
  
  desc 'Deploy to the server using rsync'
  task :rsync do
    cmd = "rsync #{SITE.rsync_args.join(' ')} "
    cmd << "#{SITE.output_dir}/ #{SITE.user}@#{SITE.host}:#{SITE.remote_dir}"
    sh cmd
  end

  # desc 'Deploy to the server using ssh'
  # task :ssh do
  #   Rake::SshDirPublisher.new(
  #       "#{SITE.user}@#{SITE.host}", SITE.remote_dir, SITE.output_dir
  #   ).upload
  # end

end  # deploy

# EOF
