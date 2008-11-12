
require 'rake/contrib/sshpublisher'

task :staging do
  SITE.remote_dir = "/var/www/beta_blog"
end

task :production do
  raise
  SITE.remote_dir = ""
end

namespace :deploy do
  SITE.user       = "maduyb@uiuc.us"
  SITE.host       = "uiuc.us"
  SITE.remote_dir = "/var/www/beta_blog"
  SITE.rsync_args = %w( -av --delete )

  desc 'Deploy to the server using rsync'
  task :rsync do
    cmd = "rsync #{SITE.rsync_args.join(' ')} "
    cmd << "#{SITE.output_dir}/ #{SITE.user}@#{SITE.host}:#{SITE.remote_dir}"
    sh cmd
  end

  desc 'Deploy to the server using ssh'
  task :ssh do
    Rake::SshDirPublisher.new(
        "#{SITE.user}@#{SITE.host}", SITE.remote_dir, SITE.output_dir
    ).upload
  end

end  # deploy

# EOF