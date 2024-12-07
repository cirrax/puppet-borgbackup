#
# Internal class to setup the git repository to
# store passphrase and key
#
# @param packages
#   the packages to ensure
#   defautls to ['git','gnupg']
# @param gpg_keys
#   Hash of gpg public keys to use for the encryption of 
#   password and keyfile.
#   the key for a pgp key must match the first email mentioned in
#   the key. otherwise it will reencrypt with each puppet run!
#   defaults to {}
# @param gpg_home
#   gpg directory to store pgp keys.
#   defaults to "${borgbackup::configdir}/.gnupg"
# @param gitrepo
#   if set to a remote url, an existing git repo will be cloned and
#   commits will be pushed there. This gives the oportunity to have
#   a separate place to store the access keys to the backups.
#   defaults to undef which only creates a local git repo.
#   Remark: if you change this, you have localy adapt the 
#   git repo (or delete it).
# @param gitrepo_sshkey
#   ssh private key needed to access the gitrepo.
#   defaults to undef
#   if $gitrepo is not set this value is ignored.
# @param git_home
#   directory to clone or create the git repo for
#   keys and passphrases.
#   defaults to "${borgbackup::configdir}/git"
# @param git_author
#   String to be used as git author for commits.
#   defaults to 'borgbackup <root@${::fqdn}>'
# 
class borgbackup::git (
  Array               $packages       = ['git','gnupg'],
  Hash                $gpg_keys       = {},
  String              $gpg_home       = "${borgbackup::configdir}/.gnupg",
  Optional[String[1]] $gitrepo        = undef,
  Optional[String[1]] $gitrepo_sshkey = undef,
  String              $git_home       = "${borgbackup::configdir}/git",
  String              $git_author     = 'borgbackup <root@${::fqdn}>',  # lint:ignore:single_quote_string_with_variables
) inherits borgbackup {
  Package[$packages] -> Exec["create gpg private key for ${facts['networking']['fqdn']}"]
  Package[$packages] -> Exec['setup git repo']

  ensure_packages($packages)

  ##################
  #
  # setup gnupg
  #
  file { $gpg_home:
    ensure => 'directory',
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  exec { "create gpg private key for ${facts['networking']['fqdn']}":
    environment => ["GNUPGHOME=${gpg_home}"],
    path        => '/usr/bin:/usr/sbin:/bin',
    command     => "gpg --quick-generate-key --batch --passphrase '' 'borg ${facts['networking']['fqdn']}'",
    unless      => "gpg --list-keys 'borg ${facts['networking']['fqdn']}'",
    require     => File[$gpg_home],
  }

  $gpg_keys.each | $name, $gpgkey | {
    exec { "add gpg key ${name}":
      environment => ["GNUPGHOME=${gpg_home}"],
      path        => '/usr/bin:/usr/sbin:/bin',
      command     => "echo \"${gpgkey}\"| gpg --import",
      unless      => "gpg --list-keys ${name}",
      require     => [File[$gpg_home], Exec["create gpg private key for ${facts['networking']['fqdn']}"]],
    }
  }

  ###################
  #
  # setup git repo
  #

  if $gitrepo {
    # we have a gitrepo url, lets clone
    file { "${borgbackup::configdir}/.ssh/gitrepo_key":
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => pick_default($gitrepo_sshkey,''),
    }

    exec { 'setup git repo':
      environment => ["GIT_SSH_COMMAND=ssh -i ${borgbackup::configdir}/.ssh/gitrepo_key"],
      path        => '/usr/bin:/usr/sbin:/bin',
      command     => "git clone ${gitrepo} ${git_home}",
      creates     => $git_home,
      require     => File["${borgbackup::configdir}/.ssh/gitrepo_key"],
    }

    exec { 'pull git repo':
      environment => ["GIT_SSH_COMMAND=ssh -i ${borgbackup::configdir}/.ssh/gitrepo_key"],
      path        => '/usr/bin:/usr/sbin:/bin',
      cwd         => $git_home,
      command     => 'git pull --rebase',
      refreshonly => true,
      subscribe   => Exec['commit git repo'],
      require     => Exec['commit git repo'],
    }

    exec { 'push git repo':
      environment => ["GIT_SSH_COMMAND=ssh -i ${borgbackup::configdir}/.ssh/gitrepo_key"],
      path        => '/usr/bin:/usr/sbin:/bin',
      cwd         => $git_home,
      command     => 'git push',
      require     => Exec['pull git repo'],
      subscribe   => Exec['commit git repo'],
      refreshonly => true,
    }
  } else {
    # since no repo url, create with git init
    exec { 'setup git repo':
      path    => '/usr/bin:/usr/sbin:/bin',
      command => "git init ${git_home}",
      creates => $git_home,
    }
  }

  file { "${git_home}/${facts['networking']['fqdn']}":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Exec['setup git repo'],
  }

  exec { 'commit git repo':
    environment => ["GIT_SSH_COMMAND=ssh -i ${borgbackup::configdir}/.ssh/gitrepo_key"],
    path        => '/usr/bin:/usr/sbin:/bin',
    cwd         => $git_home,
    command     => "git add .;git commit --message 'autocommit on ${facts['networking']['fqdn']}' --author='${git_author}'",
    refreshonly => true,
    require     => Exec['setup git repo'],
  }
}
