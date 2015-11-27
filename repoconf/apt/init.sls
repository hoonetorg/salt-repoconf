#placeholder
repoconf_apt__cmd_aptreposfile_finished:
  cmd.run:
    - name: apt-get update
    - unless: apt-get update
