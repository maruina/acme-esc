{% from 'elasticsearch/map.jinja' import elasticsearch with context %}

include:
  - elasticsearch.install

Ensure Elasticsearch is running:
  service.running:
    - name: {{ elasticsearch.lookup.service }}
    - enable: True
    - require:
      - sls: elasticsearch.install