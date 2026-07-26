FROM filebrowser/filebrowser:v2.63.21

# The stock image creates an admin/admin account on first boot and leaves it at
# that. This entrypoint sets the password from the environment instead, and
# refuses to start if one was not supplied.
COPY entrypoint.sh /entrypoint.sh

# Upstream runs as an unprivileged user, but a platform volume is mounted
# root-owned, so that user cannot write to it. Running as root is what the
# RAILWAY_RUN_UID=0 workaround amounts to; doing it here makes it visible, and
# Command Runner is disabled in the entrypoint to keep it from mattering.
USER root
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
