# Create SSH Tunnel to connect algorithms to external data sources. The
# `hostname` and `tunnel:bind:port` can be used by the algorithm
# container to connect to the external data source. This is the address
# you need to use in the `databases` section of the configuration file!
ssh-tunnels:

  # Hostname to be used within the internal network. I.e. this is the
  # hostname that the algorithm uses to connect to the data source. Make
  # sure this is unique and the same as what you specified in the
  # `databases` section of the configuration file.
  - hostname: ${TUNNEL_HOSTNAME}

    # SSH configuration of the remote machine
    ssh:

      # Hostname or ip of the remote machine, in case it is the docker
      # host you can use `host.docker.internal` for Windows and MacOS.
      # In the case of Linux you can use `172.17.0.1` (the ip of the
      # docker bridge on the host)
      host: ${SSH_HOST}
      port: ${SSH_PORT}

      # fingerprint of the remote machine. This is used to verify the
      # authenticity of the remote machine.
      fingerprint: ${SSH_HOST_FINGERPRINT}

      # Username and private key to use for authentication on the remote
      # machine
      identity:
        username: ${SSH_USERNAME}
        key: ${SSH_KEY}

    # Once the SSH connection is established, a tunnel is created to
    # forward traffic from the local machine to the remote machine.
    tunnel:

      # The port and ip on the tunnel container. The ip is always
      # 0.0.0.0 as we want the algorithm container to be able to
      # connect.
      bind:
        ip: ${TUNNEL_BIND_IP}
        port: ${TUNNEL_BIND_PORT}
      # The port and ip on the remote machine. If the data source runs
      # on this machine, the ip most likely is 127.0.0.1.
      dest:
        ip: ${TUNNEL_REMOTE_IP}
        port: ${TUNNEL_REMOTE_PORT}