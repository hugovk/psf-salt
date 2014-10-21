haproxy:
  domains:
    console.python.org:
      role: console-proxy
      port: 443
      external_backend: www.pythonanywhere.com

    docs.python.org:
      role: docs
      port: 9000

    hg.python.org:
      role: hg
      port: 9000

  listens:
    hg_ssh:
      bind: :20100
      mode: tcp
      role: hg
      port: 22
