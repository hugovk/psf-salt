/home/psf-users:
  file.directory:
    - mode: 755

{% for user_name, user_config in pillar["users"].iteritems() %}
{% set admin = user_config.get("admin", false) %}
{% set access = {} %}
{% for pat, data in user_config.get("access", {}).iteritems() if salt["match.grain"](pat) %}
  {% do access.update(data) %}
{% endfor %}

{% if access.get("allowed", false) or admin %}
{% set sudoer = admin or access.get("sudo", false) %}
{{ user_name }}-user:
  user.present:
    - name: {{ user_name }}
    - fullname: {{ user_config["fullname"] }}
    - home: /home/psf-users/{{ user_name }}
    - createhome: True
    - shell: {{ user_config.get("shell", "/bin/bash") }}
{% set groups = access.get("groups", []) %}
{% if sudoer %}
  {% do groups.extend(pillar["sudoer_groups"]) %}
{% endif %}
    - groups: {{ groups }}
    - require:
      - file: /home/psf-users
{% for group in groups %}
      - group: {{ group }}
{% endfor %}

{{ user_name }}-ssh_dir:
  file.directory:
    - name: /home/psf-users/{{ user_name }}/.ssh
    - user: {{ user_name }}
    - mode: 700
    - require:
      - user: {{ user_name }}

{{ user_name }}-ssh_key:
  file.managed:
    - name: /home/psf-users/{{ user_name }}/.ssh/authorized_keys
    - user: {{ user_name }}
    - mode: 600
    - source: salt://users/config/authorized_keys.jinja
    - template: jinja
    - context:
      ssh_keys: {{ user_config["ssh_keys"] }}
    - require:
      - user: {{ user_name }}
{% else %}
{{ user_name }}-user:
  user.absent:
    - name: {{ user_name }}
    - purge: True
{% endif %}

{% endfor %}