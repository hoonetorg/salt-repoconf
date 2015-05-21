{% set repoconfstate = salt['grains.filter_by']({
    'RedHat': 'yum',
    'Debian': 'apt',
    'none': '',
}, default='none') %}

{% if repoconfstate is defined and repoconfstate != "" %}
include: 
  - .{{repoconfstate}}
{% endif %}

# do not create and empty sls 
# an sls with only include !is! empty for special cases
# f.e. require: - sls: <empty_only_include_sls> will fail
# require: 
#   - sls: <empty_or_only_include_sls> 
# will fail
# that's why we create an a state (now this sls is not empty anymore)
repoconf__cmd_echo_hello_world:
  cmd.run:
    - name: echo "Hello world"
    - unless: echo "Hello world"
