Ensure Java JDK is installed:
  cmd.script:
    - name: install_java.sh
    - source: salt://java/files/install_java.sh
    - user: root
    - group: root