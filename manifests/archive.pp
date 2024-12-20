#
# This class creates an archive in a repo
# 
# @param reponame
#   The name of the repo to add the archive
#   defaults to $::fqdn, the default repo created
#   by including borgbackup without parameters
# @param archive_name
#   The name of the archive.
#   Defaults to $title
# @param pre_commands
#   Array of commands to run before the backup run
#   Defaults to []
# @param post_commands
#   Array of commands to run after the backup run
#   Defaults to []
# @param create_compression
#   the compression to use for create. 
#   Set to '' if no compresseion should be applied.
#   Defaults to 'lz4'
# @param create_filter
#   Filter items to display for create commnd. 
#   Set to '' if no filter should be applied.
#   Defaults to 'AME' (show Added, Modified and Error files)
# @param create_options
#   Array of additional options to add to the create command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches']
# @param create_excludes
#   Array of excludes
#   Defaults to []
#   needs to be [] if stdin_cmd is used.
# @param create_includes
#   Array of file to include
#   Defaults to []
#   needs to be [] if stdin_cmd is used.
# @param stdin_cmd
#   command which is executed, stdout is used as
#   input to backup. defaults to undef
#   do not use together with $create_excludes and $create_includes
# @param do_prune
#   if true, prune will be run after the create command.
#   Defaults to true
# @param prune_options
#   Array of additional options to add to the prune command.
#   Each item will be prefixed with '--' (means use long name !)
#   Defaults to ['list', 'show-rc']
# @param keep_last
#   number of last archives to keep
#   Defaults to undef
# @param keep_hourly
#   number of hourly archives to keep
#   Defaults to undef
# @param keep_daily
#   number of daily archives to keep
#   Set to '' if this option should not be added
#   Defaults to 7
# @param keep_weekly
#   number of weekly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 4
# @param keep_monthly
#   number of monthly archives to keep
#   Set to '' if this option should not be added
#   Defaults to 6
# @param keep_yearly
#   number of yearly archives to keep
#   Defaults to undef (no yearly is kept)
#
define borgbackup::archive (
  String                                $reponame           = $facts['networking']['fqdn'],
  String                                $archive_name       = $title,
  Array                                 $pre_commands       = [],
  Array                                 $post_commands      = [],
  String                                $create_compression = 'lz4',
  String                                $create_filter      = 'AME',
  Array                                 $create_options     = ['verbose', 'list', 'stats', 'show-rc', 'exclude-caches'],
  Array                                 $create_excludes    = [],
  Array                                 $create_includes    = [],
  Optional[String[1]]                   $stdin_cmd          = undef,
  Boolean                               $do_prune           = true,
  Array                                 $prune_options      = ['list', 'show-rc'],
  Optional[Variant[String[1], Integer]] $keep_last          = undef,
  Optional[Variant[String[1], Integer]] $keep_hourly        = undef,
  Variant[String, Integer]              $keep_daily         = 7,
  Variant[String, Integer]              $keep_weekly        = 4,
  Variant[String, Integer]              $keep_monthly       = 6,
  Optional[Variant[String[1], Integer]] $keep_yearly        = undef,
) {
  if ( $stdin_cmd and $create_includes != []) or ( $stdin_cmd  and $create_excludes != []) {
    fail('borgbackup::archive $stdin_cmd cannot be used together with $create_includes or $create_exclude')
  }

  include borgbackup

  $configdir = $borgbackup::configdir

  concat::fragment { "borgbackup::archive ${reponame} create ${archive_name}":
    target  => "${configdir}/repo_${reponame}.sh",
    content => template('borgbackup/archive_create.erb'),
    order   => "20-${title}",
  }

  if $do_prune {
    concat::fragment { "borgbackup::archive ${reponame} prune ${archive_name}":
      target  => "${configdir}/repo_${reponame}.sh",
      content => template('borgbackup/archive_prune.erb'),
      order   => "70-${title}",
    }
  }
}
