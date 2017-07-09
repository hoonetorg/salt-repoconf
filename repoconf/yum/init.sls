{% set yumconf = salt['pillar.get']('repoconf:yum:yumconf', {}) %}
{% if yumconf is defined and yumconf %}
repoconf_yum__file_/etc/yum.conf:
  augeas.change:
    - name: /etc/yum.conf
    - context: /files/etc/yum.conf
    - require_in: 
      - cmd: repoconf_yum__file_/etc/yum.conf_finished
    - changes:
{% for yumkey, yumvalue in yumconf.items() %}
      - set {{yumkey}} {{ yumvalue }}
{% endfor %}
{% endif %}

repoconf_yum__file_/etc/yum.conf_finished:
  cmd.run:
    - name: echo "repoconf_yum__file_/etc/yum.conf finished"
    - unless: true

{% for yumrepofile, yumrepofiledata in salt['pillar.get']('repoconf:yum:yumreposfile', {}).items() %}
repoconf_yum__file_{{yumrepofile}}:
  file.managed:
    - require:
      - cmd: repoconf_yum__file_/etc/yum.conf_finished
    - require_in:
      - cmd: repoconf_yum__cmd_yumreposfile_finished
    - user: root
    - group: root
    - mode: '0644'
    - name: {{yumrepofiledata.name|default('/etc/yum.repos.d/' + yumrepofile + '.repo')}}
    - contents: {{yumrepofiledata.contents|yaml}}
{% endfor %}

repoconf_yum__cmd_yumreposfile_finished:
  cmd.run:
    - name: true
    - unless: yum clean all || true

{% for yumrepourl, yumrepourldata in salt['pillar.get']('repoconf:yum:yumreposurl', {}).items() %}
repoconf_yum__pkg_{{yumrepourl}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'cmd' : 'repoconf_yum__cmd_yumreposfile_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumreposurl_finished' } ] } ] + yumrepourldata }}
{% endfor %}

repoconf_yum__cmd_yumreposurl_finished:
  cmd.run:
    - name: true
    - unless: yum clean all || true
    

{% for yumrepopkglocal, yumrepopkglocaldata in salt['pillar.get']('repoconf:yum:yumrepospkglocal', {}).items() %}
repoconf_yum__pkg_{{yumrepopkglocal}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'cmd' : 'repoconf_yum__cmd_yumreposurl_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumrepospkglocal_finished' } ] } ] + yumrepopkglocaldata }}
{% endfor %}

repoconf_yum__cmd_yumrepospkglocal_finished:
  cmd.run:
    - name: true
    - unless: yum clean all || true

{% for yumrepopkg, yumrepopkgdata in salt['pillar.get']('repoconf:yum:yumrepospkg', {}).items() %}
repoconf_yum__pkg_{{yumrepopkg}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'cmd' : 'repoconf_yum__cmd_yumrepospkglocal_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumrepospkg_finished' } ] } ] + yumrepopkgdata }}
{% endfor %}

repoconf_yum__cmd_yumrepospkg_finished:
  cmd.run:
    - name: true
    - unless: yum clean all || true

