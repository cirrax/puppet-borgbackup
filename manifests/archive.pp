#
# This class creates an archive in a repo
# 
# Parameters:
#
# $reponame,
#   The name of the repo to add the archive
#   defaults to $::fqdn, the default repo created
#   by including borgbackup without parameters
# $archive_name
#   The name of the archive.
#   Defaults to $title
# $pre_commands
#   Array of commands to run before the backup run
#   Defaults to []
# $post_commands
#   Array of commands to run after the backup run
#   Defaults to []
# $create_compression
#   the compression to use for create. 
#   Set to '' if no compresseion should be applied.
#   Defaults to 'lz4'
# $create_filter
#   Filter items to display for create commnd. 
#   Set to '' if no filter should be applied.
#   Defaults to 'AME' (show Added, Modified and Error files)
# $create_options
#   Array of additional options to add to the create command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches']
# $create_excludes
#   Array of excludes
#   Defaults to []
# $create_includes
#   Array of file to include
#   Defaults to []
# $do_prune
#   if true, prune will be run after the create command.
#   Defaults to true
# $prune_options
#   Array of additional options to add to the prune command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['list', 'show-rc']
# $keep_last
#   number of last archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
# $keep_hourly
#   number of hourly archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
# $keep_daily
#   number of daily archives to keep
#   Set to '' if this option should not be added
#   Defaults to 7
# $keep_weekly
#   number of weekly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 4
# $keep_monthly
#   number of monthly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 6
# $keep_yearly
#   number of yearly archives to keep
#   Set to '' if this option should not be added
#   Defaults to ''
#
define borgbackup::archive (
  $reponame           = $::fqdn,
  $archive_name       = $title,
  $pre_commands       = [],
  $post_commands      = [],
  $create_compression = 'lz4',
  $create_filter      = 'AME',
  $create_options     = ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches'],
  $create_excludes    = [],
  $create_includes    = [],
  $do_prune           = true,
  $prune_options      = ['list', 'show-rc'],
  $keep_last          = '',
  $keep_hourly        = '',
  $keep_daily         = 7,
  $keep_weekly        = 4,
  $keep_monthly       = 6,
  $keep_yearly        = '',
){

  include ::borgbackup

  $configdir = $::borgbackup::configdir

  concat::fragment{ "borgbackup::archive ${reponame} create ${archive_name}":
    target  => "${configdir}/repo_${reponame}.sh",
    content => template('borgbackup/archive_create.erb'),
    order   => "20-${title}",
  }

  if $do_prune {
    concat::fragment{ "borgbackup::archive ${reponame} prune ${archive_name}":
      target  => "${configdir}/repo_${reponame}.sh",
      content => template('borgbackup/repo_footer.erb'),
      order   => "70-${title}",
    }
  }
}
