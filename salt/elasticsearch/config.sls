{% from 'elasticsearch/map.jinja' import elasticsearch with context %}

Ensure Elasticsearch config file is present:
  file.managed:
    - name: {{ elasticsearch.lookup.conf_file }}
    - source: salt://elasticsearch/files/elasticsearch.yml
    - user: root
    - group: root
    - mode: 644
    - template: jinja
    - watch_in:
      - service: {{ elasticsearch.lookup.service }}


Ensure Elasticsearch init file is present:
  file.managed:
    - name: /usr/share/elasticsearch/bin/elasticsearch.in.sh
    - source: salt://elasticsearch/files/elasticsearch.in.sh
    - user: root
    - group: root
    - mode: 755
    - template: jinja
    - watch_in:
      - service: {{ elasticsearch.lookup.service }}