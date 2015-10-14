{% set yumconf = salt['pillar.get']('repoconf:yum:yumconf', {}) %}
{% if yumconf is defined and yumconf %}
repoconf_yum__file_/etc/yum.conf:
  augeas.change:
    - name: /etc/yum.conf
    - context: /files/etc/yum.conf
    - changes:
{% for yumkey, yumvalue in yumconf.items() %}
      - set {{yumkey}} {{ yumvalue }}
{% endfor %}
{% set slsrequires =salt['pillar.get']('repoconf:yum:slsrequires', False) %}
{% if slsrequires is defined and slsrequires %}
    - require:
{% for slsrequire in slsrequires %}
      - {{slsrequire}}
{% endfor %}
{% endif %}
{% endif %}


{% for yumrepourl, yumrepourldata in salt['pillar.get']('repoconf:yum:yumreposurl', {}).items() %}
repoconf_yum__pkg_{{yumrepourl}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'augeas' : 'repoconf_yum__file_/etc/yum.conf' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumreposurl_finished' } ] } ] + yumrepourldata }}
{% endfor %}

repoconf_yum__cmd_yumreposurl_finished:
  cmd.run:
    - name: yum clean all
    - unless: yum clean all
    

{% for yumrepopkglocal, yumrepopkglocaldata in salt['pillar.get']('repoconf:yum:yumrepospkglocal', {}).items() %}
repoconf_yum__pkg_{{yumrepopkglocal}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'augeas' : 'repoconf_yum__file_/etc/yum.conf' },  { 'cmd' : 'repoconf_yum__cmd_yumreposurl_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumrepospkglocal_finished' } ] } ] + yumrepopkglocaldata }}
{% endfor %}

repoconf_yum__cmd_yumrepospkglocal_finished:
  cmd.run:
    - name: yum clean all
    - unless: yum clean all

{% for yumrepopkg, yumrepopkgdata in salt['pillar.get']('repoconf:yum:yumrepospkg', {}).items() %}
repoconf_yum__pkg_{{yumrepopkg}}:
  pkg.installed:
    {{ [ { 'require' : [ { 'augeas' : 'repoconf_yum__file_/etc/yum.conf' },  { 'cmd' : 'repoconf_yum__cmd_yumrepospkglocal_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumrepospkg_finished' } ] } ] + yumrepopkgdata }}
{% endfor %}

repoconf_yum__cmd_yumrepospkg_finished:
  cmd.run:
    - name: yum clean all
    - unless: yum clean all

{% for yumrepofile, yumrepofiledata in salt['pillar.get']('repoconf:yum:yumreposfile', {}).items() %}
repoconf_yum__file_{{yumrepofile}}:
  file.managed:
    {{ [ { 'require' : [ { 'augeas' : 'repoconf_yum__file_/etc/yum.conf' },  { 'cmd' : 'repoconf_yum__cmd_yumrepospkg_finished' } ] }, { 'require_in' : [ { 'cmd' : 'repoconf_yum__cmd_yumreposfile_finished' } ] } ] + yumrepofiledata }}
{% endfor %}

repoconf_yum__cmd_yumreposfile_finished:
  cmd.run:
    - name: yum clean all
    - unless: yum clean all
