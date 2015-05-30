{% set proxy = salt['pillar.get']('repoconf:profiled:proxy') %}
{% set no_proxy = salt['pillar.get']('repoconf:profiled:no_proxy') %}

{% if proxy is defined and proxy != '' %}
repoconf_profiled__/etc/profile.d/01-proxy.sh:
  file.managed:
    - name: /etc/profile.d/01-proxy.sh
    - user: root
    - group: root
    - mode: 755
    - contents: |
        http_proxy="{{proxy}}"
        export http_proxy
{% if no_proxy is defined and no_proxy != '' %}
        no_proxy="{{no_proxy}}"
        export no_proxy
{% endif %}
{% endif %}
